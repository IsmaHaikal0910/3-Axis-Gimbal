#include <Arduino.h>
#include <HardwareSerial.h>
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEScan.h>
#include <BLEAdvertisedDevice.h>
#include <BLEClient.h>
#include <BLESecurity.h>
#include <WiFi.h>
#include <WebServer.h>
#include <Preferences.h>
#include <nvs_flash.h>
#include "STorM32_lib.h"

HardwareSerial storm32(1);
Preferences    prefs;

// ── Battery ────────────────────────────────────────────────
#define VOLT_OFFSET  12
#define PACKET_LEN   67

// ── RGB LED ────────────────────────────────────────────────
#define PIN_R        25
#define PIN_G        26
#define PIN_B        27

// ── Buttons ────────────────────────────────────────────────
#define BTN_MODE     18   // WiFi hotspot toggle
#define BTN_ACTION   19   // BLE shutter
#define DEBOUNCE_MS  20

// ── Joystick ───────────────────────────────────────────────
#define PIN_JOY_X    34   // ADC input-only
#define PIN_JOY_Y    35   // ADC input-only (adjacent to 34)
#define PIN_JOY_BTN  33   // Joystick push — toggles manual control

// ── STorM32 UART ───────────────────────────────────────────
#define STORM32_RX_PIN  16
#define STORM32_TX_PIN  17
#define STORM32_BAUD    115200

// ── WiFi Hotspot ───────────────────────────────────────────
#define WIFI_SSID    "ESP32-Gimbal"
#define WIFI_PASS    "gimbal1234"

// ── Sony BLE UUIDs ─────────────────────────────────────────
static BLEUUID SONY_SERVICE_UUID("8000FF00-FF00-FFFF-FFFF-FFFFFFFFFFFF");
static BLEUUID SONY_CHAR_UUID   ((uint16_t)0xFF01);

// ── HID UUIDs ─────────────────────────────────────────────
static BLEUUID HID_SERVICE_UUID ((uint16_t)0x1812);
static BLEUUID HID_REPORT_UUID  ((uint16_t)0x2A4D);

// ── Sony shutter commands ──────────────────────────────────
uint8_t CMD_FOCUS_DOWN[]   = { 0x01, 0x07 };
uint8_t CMD_SHUTTER_DOWN[] = { 0x01, 0x09 };
uint8_t CMD_SHUTTER_UP[]   = { 0x01, 0x08 };
uint8_t CMD_FOCUS_UP[]     = { 0x01, 0x06 };

// ── State ──────────────────────────────────────────────────
enum Mode       { MODE_BLUETOOTH, MODE_WIFI };
enum CameraType { CAM_SONY, CAM_HID, CAM_UNKNOWN };

Mode       currentMode = MODE_BLUETOOTH;
CameraType camType     = CAM_UNKNOWN;

String targetCameraName = "";
String connectedCamName = "";

float   batteryVoltage = 0.0f;
int     batteryPercent = -1;
uint8_t rxBuf[256];
int     rxLen          = 0;

// ── BLE ────────────────────────────────────────────────────
BLEClient*               pClient     = nullptr;
BLERemoteCharacteristic* pRemoteChar = nullptr;
BLEAdvertisedDevice*     myCamera    = nullptr;
bool bleConnected = false;
bool doConnect    = false;
bool doScan       = false;

// ── Web Server ─────────────────────────────────────────────
WebServer server(80);

// ── Debounce ───────────────────────────────────────────────
unsigned long lastPressMODE   = 0;
unsigned long lastPressACTION = 0;

// ── Scanned devices ────────────────────────────────────────
struct BLEDeviceInfo {
  String name;
  String address;
};
std::vector<BLEDeviceInfo> scannedDevices;

// ── Gimbal State ───────────────────────────────────────────
static bool     manual_control_enabled = false;
static uint16_t last_pitch_pwm         = 1500;
static uint16_t last_yaw_pwm           = 1500;
static uint16_t last_sent_raw_x        = 512;
static uint16_t last_sent_raw_y        = 512;

// Joystick button toggle state
static bool     joy_btn_held           = false;
static uint32_t joy_btn_press_ms       = 0;

static uint32_t debug_last_ms          = 0;

// ──────────────────────────────────────────────────────────
// BLE security callbacks
// ──────────────────────────────────────────────────────────
class SecurityCallbacks : public BLESecurityCallbacks {
  uint32_t onPassKeyRequest() {
    Serial.println("BLE: PassKey requested — returning 0");
    return 0;
  }
  void onPassKeyNotify(uint32_t pass_key) {
    Serial.printf("BLE: PassKey notify: %d\n", pass_key);
  }
  bool onConfirmPIN(uint32_t pass_key) {
    Serial.printf("BLE: Confirm PIN: %d — auto confirming\n", pass_key);
    return true;
  }
  bool onSecurityRequest() {
    Serial.println("BLE: Security request — accepting");
    return true;
  }
  void onAuthenticationComplete(esp_ble_auth_cmpl_t cmpl) {
    if (cmpl.success) {
      Serial.println("BLE: Pairing/bonding successful!");
    } else {
      Serial.printf("BLE: Pairing failed, reason: %d\n", cmpl.fail_reason);
    }
  }
};

// ──────────────────────────────────────────────────────────
// BLE client callbacks
// ──────────────────────────────────────────────────────────
class ClientCallbacks : public BLEClientCallbacks {
  void onConnect(BLEClient* pclient) {
    Serial.println("BLE: Client connected");
  }
  void onDisconnect(BLEClient* pclient) {
    bleConnected = false;
    pRemoteChar  = nullptr;
    Serial.println("BLE: Disconnected — will retry on next scan");
  }
};

// ──────────────────────────────────────────────────────────
// BLE scan callbacks
// ──────────────────────────────────────────────────────────
class ScanCallbacks : public BLEAdvertisedDeviceCallbacks {
  void onResult(BLEAdvertisedDevice device) {
    String name = device.getName().c_str();

    if (name.length() > 0) {
      bool exists = false;
      for (auto& d : scannedDevices) {
        if (d.address == device.getAddress().toString().c_str()) {
          exists = true;
          break;
        }
      }
      if (!exists) {
        BLEDeviceInfo info;
        info.name    = name;
        info.address = device.getAddress().toString().c_str();
        scannedDevices.push_back(info);
        Serial.printf("BLE found: %s (%s)\n", name.c_str(), info.address.c_str());
      }
    }

    bool nameMatch = targetCameraName.length() > 0 &&
                     name.equalsIgnoreCase(targetCameraName);

    bool sonyPairingOpen = false;
    if (device.haveManufacturerData()) {
      std::string mfr = device.getManufacturerData();
      if (mfr.length() >= 4 &&
          (uint8_t)mfr[0] == 0x2D && (uint8_t)mfr[1] == 0x01 &&
          (uint8_t)mfr[2] == 0x03 && (uint8_t)mfr[3] == 0x00) {
        for (size_t i = 4; i < mfr.length() - 1; i++) {
          if ((uint8_t)mfr[i] == 0x22 && (uint8_t)mfr[i+1] == 0xEF) {
            sonyPairingOpen = true;
            Serial.printf("Sony camera in pairing mode: %s\n", name.c_str());
            break;
          }
        }
      }
    }

    if (nameMatch || sonyPairingOpen) {
      BLEDevice::getScan()->stop();
      myCamera  = new BLEAdvertisedDevice(device);
      doConnect = true;
    }
  }
};

// ──────────────────────────────────────────────────────────
// Detect camera type
// ──────────────────────────────────────────────────────────
CameraType detectCameraType(String name) {
  name.toLowerCase();
  if (name.startsWith("ilce") || name.startsWith("zv-") ||
      name.startsWith("dsc-") || name.indexOf("sony") >= 0) {
    return CAM_SONY;
  }
  return CAM_HID;
}

// ──────────────────────────────────────────────────────────
// Connect to camera
// ──────────────────────────────────────────────────────────
bool connectToCamera() {
  Serial.printf("BLE: Connecting to %s...\n", myCamera->getName().c_str());

  BLEDevice::setSecurityCallbacks(new SecurityCallbacks());
  BLEDevice::setEncryptionLevel(ESP_BLE_SEC_ENCRYPT);

  BLESecurity* pSecurity = new BLESecurity();
  pSecurity->setAuthenticationMode(ESP_LE_AUTH_REQ_SC_BOND);
  pSecurity->setCapability(ESP_IO_CAP_NONE);
  pSecurity->setInitEncryptionKey(ESP_BLE_ENC_KEY_MASK | ESP_BLE_ID_KEY_MASK);
  pSecurity->setRespEncryptionKey(ESP_BLE_ENC_KEY_MASK | ESP_BLE_ID_KEY_MASK);

  pClient = BLEDevice::createClient();
  pClient->setClientCallbacks(new ClientCallbacks());

  if (!pClient->connect(myCamera)) {
    Serial.println("BLE: Connection failed");
    bleConnected = false;
    return false;
  }

  Serial.println("BLE: Connected — waiting for bonding to complete...");
  delay(2000);

  connectedCamName = myCamera->getName().c_str();
  camType          = detectCameraType(connectedCamName);

  if (camType == CAM_SONY) {
    BLERemoteService* pService = pClient->getService(SONY_SERVICE_UUID);
    if (!pService) {
      Serial.println("BLE: Sony service not found");
      Serial.println("     → Menu → Network → Bluetooth → Pairing");
      pClient->disconnect();
      bleConnected = false;
      return false;
    }
    pRemoteChar = pService->getCharacteristic(SONY_CHAR_UUID);
    if (!pRemoteChar) {
      Serial.println("BLE: Sony characteristic not found");
      pClient->disconnect();
      bleConnected = false;
      return false;
    }
    bleConnected = true;
    Serial.println("BLE: Sony camera ready!");
  } else {
    BLERemoteService* pService = pClient->getService(HID_SERVICE_UUID);
    if (!pService) {
      Serial.println("BLE: HID service not found");
      pClient->disconnect();
      bleConnected = false;
      return false;
    }
    pRemoteChar = pService->getCharacteristic(HID_REPORT_UUID);
    if (!pRemoteChar) {
      Serial.println("BLE: HID characteristic not found");
      pClient->disconnect();
      bleConnected = false;
      return false;
    }
    bleConnected = true;
    Serial.println("BLE: HID device ready!");
  }

  if (bleConnected && connectedCamName != targetCameraName) {
    targetCameraName = connectedCamName;
    prefs.begin("gimbal", false);
    prefs.putString("camname", targetCameraName);
    prefs.end();
    Serial.printf("Saved camera: %s\n", targetCameraName.c_str());
  }

  return bleConnected;
}

// ──────────────────────────────────────────────────────────
// Trigger shutter
// ──────────────────────────────────────────────────────────
void triggerShutter() {
  if (!bleConnected || pRemoteChar == nullptr) {
    Serial.println("BLE: Not connected");
    if (myCamera != nullptr || targetCameraName.length() > 0) {
      Serial.println("Retrying scan...");
      doScan = true;
    }
    return;
  }

  if (camType == CAM_SONY) {
    Serial.println("Shutter: Sony");
    pRemoteChar->writeValue(CMD_FOCUS_DOWN,   2, true); delay(50);
    pRemoteChar->writeValue(CMD_SHUTTER_DOWN, 2, true); delay(100);
    pRemoteChar->writeValue(CMD_SHUTTER_UP,   2, true); delay(50);
    pRemoteChar->writeValue(CMD_FOCUS_UP,     2, true);
    Serial.println("Shutter done");
  } else {
    Serial.println("Shutter: HID volume down");
    uint8_t keyDown[] = { 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
    uint8_t keyUp[]   = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
    pRemoteChar->writeValue(keyDown, 8, true); delay(100);
    pRemoteChar->writeValue(keyUp,   8, true);
    Serial.println("Shutter done");
  }
}

// ──────────────────────────────────────────────────────────
// Start BLE scan
// ──────────────────────────────────────────────────────────
void startScan() {
  scannedDevices.clear();
  Serial.println("BLE: Scanning...");
  BLEScan* pScan = BLEDevice::getScan();
  pScan->setAdvertisedDeviceCallbacks(new ScanCallbacks(), true);
  pScan->setActiveScan(true);
  pScan->start(5, false);
  Serial.printf("BLE: Scan done, found %d devices\n", scannedDevices.size());
}

// ──────────────────────────────────────────────────────────
// LiPo percentage lookup
// ──────────────────────────────────────────────────────────
float lipoPercent(float voltage) {
  float v = voltage / 3.0f;
  if (v >= 4.20f) return 100.0f;
  if (v >= 4.15f) return  95.0f;
  if (v >= 4.11f) return  90.0f;
  if (v >= 4.08f) return  85.0f;
  if (v >= 4.02f) return  80.0f;
  if (v >= 3.98f) return  75.0f;
  if (v >= 3.95f) return  70.0f;
  if (v >= 3.91f) return  65.0f;
  if (v >= 3.87f) return  60.0f;
  if (v >= 3.83f) return  55.0f;
  if (v >= 3.79f) return  50.0f;
  if (v >= 3.75f) return  45.0f;
  if (v >= 3.71f) return  40.0f;
  if (v >= 3.67f) return  35.0f;
  if (v >= 3.63f) return  30.0f;
  if (v >= 3.59f) return  25.0f;
  if (v >= 3.55f) return  20.0f;
  if (v >= 3.51f) return  15.0f;
  if (v >= 3.45f) return  10.0f;
  if (v >= 3.40f) return   5.0f;
  return 0.0f;
}

// ──────────────────────────────────────────────────────────
// RGB LED
// ──────────────────────────────────────────────────────────
void setColor(int r, int g, int b) {
  analogWrite(PIN_R, r);
  analogWrite(PIN_G, g);
  analogWrite(PIN_B, b);
}

void updateLED() {
  if (batteryPercent < 0) { setColor(0, 0, 0); return; }
  if (batteryPercent >= 50) {
    setColor(0, 255, 0);
  } else if (batteryPercent >= 20) {
    setColor(255, 150, 0);
  } else {
    static bool          blinkState = false;
    static unsigned long lastBlink  = 0;
    if (millis() - lastBlink > 500) {
      blinkState = !blinkState;
      lastBlink  = millis();
    }
    blinkState ? setColor(255, 0, 0) : setColor(0, 0, 0);
  }
}

// ──────────────────────────────────────────────────────────
// STorM32 gimbal commands
// ──────────────────────────────────────────────────────────
static void send_recenter() {
  if (Serial2.availableForWrite() <= 0) return;
  tSTorM32CmdSetAngles t;
  t.pitch = 0.0f;
  t.roll  = 0.0f;
  t.yaw   = 0.0f;
  t.flags = 0;
  t.type  = 0;
  storm32_finalize_CmdSetAngles(&t);
  Serial2.write((uint8_t*)&t, sizeof(t));
  Serial.println("[Gimbal] Sent RECENTER command.");
}

static void hold_last_position() {
  if (Serial2.availableForWrite() <= 0) return;
  tSTorM32CmdSetPitchRollYaw t;
  t.pitch = last_pitch_pwm;
  t.roll  = 1500;
  t.yaw   = last_yaw_pwm;
  storm32_finalize_CmdSetPitchRollYaw(&t);
  Serial2.write((uint8_t*)&t, sizeof(t));
  Serial.println("[Gimbal] Holding last manual position.");
}

static void send_joystick() {
  if (Serial2.availableForWrite() <= 0) return;

  uint16_t raw_x = analogRead(PIN_JOY_X);
  uint16_t raw_y = analogRead(PIN_JOY_Y);

  const uint16_t HYSTERESIS = 30;
  if (abs((int16_t)raw_x - (int16_t)last_sent_raw_x) < HYSTERESIS &&
      abs((int16_t)raw_y - (int16_t)last_sent_raw_y) < HYSTERESIS) {
    return;
  }

  uint16_t yaw_pwm   = 1350 + ((uint32_t)raw_y * 300) / 1023;
  uint16_t pitch_pwm = 1250 + ((uint32_t)raw_x * 500) / 1023;

  tSTorM32CmdSetPitchRollYaw t;
  t.pitch = pitch_pwm;
  t.roll  = 1500;
  t.yaw   = yaw_pwm;
  storm32_finalize_CmdSetPitchRollYaw(&t);
  Serial2.write((uint8_t*)&t, sizeof(t));

  last_sent_raw_x = raw_x;
  last_sent_raw_y = raw_y;
  last_pitch_pwm  = pitch_pwm;
  last_yaw_pwm    = yaw_pwm;
}

// ──────────────────────────────────────────────────────────
// Joystick button — press to toggle manual control on/off
// ──────────────────────────────────────────────────────────
static void handle_joy_btn() {
  bool pressed = (digitalRead(PIN_JOY_BTN) == LOW);
  uint32_t now = millis();

  if (pressed && !joy_btn_held) {
    joy_btn_held     = true;
    joy_btn_press_ms = now;
  }

  if (!pressed && joy_btn_held) {
    if ((now - joy_btn_press_ms) >= DEBOUNCE_MS) {
      manual_control_enabled = !manual_control_enabled;
      if (manual_control_enabled) {
        Serial.println("[Gimbal] Joystick btn -> MANUAL CONTROL ON");
      } else {
        hold_last_position();
        Serial.println("[Gimbal] Joystick btn -> MANUAL CONTROL OFF — holding position");
      }
    }
    joy_btn_held = false;
  }
}

static void debug_gimbal_status() {
  uint32_t now = millis();
  if (now - debug_last_ms < 500) return;
  debug_last_ms = now;
  uint16_t raw_x = analogRead(PIN_JOY_X);
  uint16_t raw_y = analogRead(PIN_JOY_Y);
  Serial.printf("[Gimbal] X=%4u Y=%4u | PITCH=%4u YAW=%4u | MANUAL=%s | TX_FREE=%u\n",
                raw_x, raw_y,
                (uint16_t)(1250 + ((uint32_t)raw_x * 500) / 1023),
                (uint16_t)(1350 + ((uint32_t)raw_y * 300) / 1023),
                manual_control_enabled ? "ON" : "OFF",
                Serial2.availableForWrite());
}

// ──────────────────────────────────────────────────────────
// Web server
// ──────────────────────────────────────────────────────────
void setupWebServer() {

  server.on("/", []() {
    int    pct       = max(0, batteryPercent);
    String volt      = batteryPercent < 0 ? "--" : String(batteryVoltage, 2);
    String ringClr   = pct >= 50 ? "#22d68a" : pct >= 20 ? "#f5a623" : "#ff4f6a";
    String battIcon  = pct >= 50 ? "&#x1F50B;" : pct >= 20 ? "&#x1FAAB;" : "&#x26A0;";
    String statusIcon= pct >= 50 ? "&#x2705;" : pct >= 20 ? "&#x26A0;" : "&#x1F534;";
    String statusText= pct >= 50 ? "Good &mdash; fully operational" :
                       pct >= 20 ? "Low &mdash; recharge soon" :
                                   "Critical &mdash; recharge now!";
    String pctStr    = batteryPercent < 0 ? "--" : String(pct);
    String connClass = bleConnected ? "connected" : "disconnected";
    String connLabel = bleConnected ? "Connected to:" : "Not connected";
    String connName  = bleConnected ? connectedCamName : "";
    String dashOff   = String(220 - (220 * pct / 100));
    String manualStr = manual_control_enabled ? "ON" : "OFF";

    String devHtml = "";
    if (scannedDevices.size() > 0) {
      devHtml += "<div class='section-header'>"
                 "<span class='section-title'>Available Devices</span>"
                 "<span class='found-badge'><span class='found-dot'></span>" +
                 String(scannedDevices.size()) + " found</span></div>"
                 "<div class='device-list'>";
      for (auto& d : scannedDevices) {
        String ln = d.name; ln.toLowerCase();
        String ac = "avatar-default", em = "&#x1F4E1;";
        if (ln.indexOf("ilce")>=0||ln.indexOf("sony")>=0||ln.indexOf("zv")>=0)
          { ac="avatar-camera"; em="&#x1F4F7;"; }
        else if (ln.indexOf("laptop")>=0||ln.indexOf("pc")>=0||ln.indexOf("mac")>=0)
          { ac="avatar-laptop"; em="&#x1F4BB;"; }
        else if (ln.indexOf("watch")>=0||ln.indexOf("band")>=0)
          { ac="avatar-watch"; em="&#x231A;"; }
        bool active = bleConnected && d.name == connectedCamName;
        devHtml += "<a class='device-item" + String(active?" active-device":"") +
                   "' href='/connect?name=" + d.name + "'>" +
                   "<div class='device-avatar " + ac + "'>" + em + "</div>" +
                   "<div class='device-info'>" +
                   "<div class='device-name'>" + d.name + "</div>" +
                   "<div class='device-addr'>" + d.address + "</div>" +
                   "</div><div class='device-chevron'>&#x203A;</div></a>";
      }
      devHtml += "</div>";
    }

    server.setContentLength(CONTENT_LENGTH_UNKNOWN);
    server.send(200, "text/html", "");

    server.sendContent(R"rawhtml(<!DOCTYPE html>
<html lang="en"><head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>ESP32 Gimbal Remote</title>
<link href="https://fonts.googleapis.com/css2?family=Syne:wght@700;800&family=DM+Sans:wght@400;500&display=swap" rel="stylesheet">
<style>
:root{--bg:#0d0f1a;--surface:#13162a;--surface2:#181c32;--border:rgba(255,255,255,0.07);--accent:#4f8aff;--green:#22d68a;--yellow:#f5a623;--red:#ff4f6a;--text:#e8eaf6;--muted:#6b7099;}
*{box-sizing:border-box;margin:0;padding:0;}
body{font-family:'DM Sans',sans-serif;background:var(--bg);color:var(--text);max-width:430px;margin:0 auto;padding-bottom:24px;overflow-x:hidden;}
.header{display:flex;align-items:center;justify-content:space-between;padding:20px 24px 10px;}
.header-icon{width:38px;height:38px;background:var(--surface2);border-radius:12px;display:flex;align-items:center;justify-content:center;border:1px solid var(--border);}
.refresh-btn{background:none;border:none;cursor:pointer;width:38px;height:38px;display:flex;align-items:center;justify-content:center;color:var(--muted);border-radius:12px;font-size:18px;}
.hero{text-align:center;padding:10px 24px 24px;}
.hero-icon{width:64px;height:64px;margin:0 auto 14px;background:linear-gradient(135deg,var(--surface2),#1e2240);border-radius:20px;display:flex;align-items:center;justify-content:center;border:1px solid var(--border);font-size:30px;}
.hero h1{font-family:'Syne',sans-serif;font-size:24px;font-weight:800;letter-spacing:-0.5px;color:#fff;}
.hero p{font-size:13px;color:var(--muted);margin-top:4px;}
.card{background:var(--surface);border:1px solid var(--border);border-radius:20px;margin:0 16px 12px;padding:20px;position:relative;overflow:hidden;}
.card::before{content:'';position:absolute;top:0;left:0;right:0;height:1px;background:linear-gradient(90deg,transparent,rgba(255,255,255,0.12),transparent);}
.battery-card{display:flex;align-items:center;gap:20px;}
.battery-ring{position:relative;width:90px;height:90px;flex-shrink:0;}
.battery-ring svg{width:90px;height:90px;transform:rotate(-90deg);}
.ring-bg{fill:none;stroke:rgba(255,255,255,0.06);stroke-width:6;}
.ring-fill{fill:none;stroke-width:6;stroke-linecap:round;stroke-dasharray:220;}
.battery-icon{position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);font-size:24px;}
.battery-info{flex:1;}
.battery-pct{font-family:'Syne',sans-serif;font-size:42px;font-weight:800;line-height:1;color:#fff;}
.battery-pct span{font-size:22px;font-weight:600;opacity:0.7;}
.battery-status{display:flex;align-items:center;gap:6px;margin-top:6px;font-size:13px;font-weight:500;}
.battery-voltage{font-size:12px;color:var(--muted);margin-top:4px;}
.connection-status{display:flex;align-items:center;gap:8px;font-size:14px;font-weight:500;margin-bottom:16px;}
.dot{width:9px;height:9px;border-radius:50%;flex-shrink:0;}
.dot.connected{background:var(--green);box-shadow:0 0 8px var(--green);animation:pulse 2s infinite;}
.dot.disconnected{background:var(--red);}
.cam-name{color:var(--accent);font-weight:600;}
.action-btns{display:grid;grid-template-columns:1fr 1fr;gap:12px;}
.action-btn{border:none;border-radius:16px;padding:22px 16px;display:flex;flex-direction:column;align-items:center;gap:8px;cursor:pointer;font-family:'DM Sans',sans-serif;font-size:13px;font-weight:500;transition:transform 0.12s;text-decoration:none;}
.action-btn:active{transform:scale(0.96);}
.btn-icon{font-size:28px;width:52px;height:52px;border-radius:50%;display:flex;align-items:center;justify-content:center;}
.btn-shutter{background:linear-gradient(135deg,#2a5fff,#4f8aff);color:#fff;box-shadow:0 8px 24px rgba(79,138,255,0.35);}
.btn-shutter .btn-icon{background:rgba(255,255,255,0.15);}
.btn-scan{background:linear-gradient(135deg,#6b2fb0,#9b5de5);color:#fff;box-shadow:0 8px 24px rgba(155,93,229,0.35);}
.btn-scan .btn-icon{background:rgba(255,255,255,0.15);}
.btn-recenter{background:linear-gradient(135deg,#1a7a4a,#22d68a);color:#fff;box-shadow:0 8px 24px rgba(34,214,138,0.3);}
.btn-recenter .btn-icon{background:rgba(255,255,255,0.15);}
.gimbal-row{font-size:13px;color:var(--muted);margin-top:14px;padding-top:14px;border-top:1px solid var(--border);display:flex;justify-content:space-between;align-items:center;}
.gimbal-row b{color:var(--text);}
.manual-on{color:var(--green);font-weight:700;}
.manual-off{color:var(--muted);}
.section-header{display:flex;align-items:center;justify-content:space-between;padding:8px 24px 12px;}
.section-title{font-family:'Syne',sans-serif;font-size:16px;font-weight:700;color:#fff;}
.found-badge{display:flex;align-items:center;gap:6px;font-size:12px;color:var(--muted);}
.found-dot{width:7px;height:7px;border-radius:50%;background:var(--green);box-shadow:0 0 6px var(--green);}
.device-list{padding:0 16px;}
.device-item{display:flex;align-items:center;gap:14px;padding:14px 16px;background:var(--surface);border:1px solid var(--border);border-radius:14px;margin-bottom:8px;cursor:pointer;text-decoration:none;color:var(--text);transition:background 0.15s,transform 0.1s;}
.device-item:active{transform:scale(0.98);}
.device-item.active-device{border-color:var(--accent);}
.device-avatar{width:44px;height:44px;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:20px;flex-shrink:0;}
.avatar-laptop{background:rgba(79,138,255,0.15);}
.avatar-watch{background:rgba(255,79,106,0.15);}
.avatar-camera{background:rgba(34,214,138,0.15);}
.avatar-default{background:rgba(255,255,255,0.08);}
.device-info{flex:1;min-width:0;}
.device-name{font-size:14px;font-weight:600;color:#fff;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.device-addr{font-size:11px;color:var(--muted);margin-top:2px;font-family:monospace;}
.device-chevron{color:var(--muted);flex-shrink:0;font-size:20px;}
.connect-form{margin:12px 16px;}
.input-label{font-size:12px;color:var(--muted);margin-bottom:8px;text-align:center;}
.input-wrap{position:relative;display:flex;align-items:center;}
.input-icon{position:absolute;left:14px;font-size:14px;color:var(--muted);}
.text-input{width:100%;background:var(--surface);border:1px solid var(--border);border-radius:14px;padding:14px 14px 14px 40px;color:var(--text);font-family:'DM Sans',sans-serif;font-size:14px;outline:none;}
.text-input:focus{border-color:var(--accent);}
.text-input::placeholder{color:var(--muted);}
.connect-btn{display:flex;align-items:center;justify-content:center;gap:8px;width:100%;padding:16px;margin-top:10px;background:linear-gradient(135deg,#22d68a,#4f8aff);border:none;border-radius:14px;color:#fff;font-family:'Syne',sans-serif;font-size:16px;font-weight:700;cursor:pointer;}
.save-note{text-align:center;font-size:12px;color:var(--green);margin-top:10px;}
.danger-btn{display:block;text-align:center;margin:0 16px 24px;padding:12px;background:rgba(255,79,106,0.08);border:1px solid rgba(255,79,106,0.2);border-radius:12px;color:var(--red);font-size:13px;font-weight:500;text-decoration:none;}
@keyframes pulse{0%,100%{opacity:1;}50%{opacity:0.4;}}
@keyframes fadeUp{from{opacity:0;transform:translateY(12px);}to{opacity:1;transform:translateY(0);}}
.card{animation:fadeUp 0.4s ease both;}
</style></head><body>
<div class="header">
  <div class="header-icon">&#x2630;</div>
  <button class="refresh-btn" onclick="location.reload()">&#x21BB;</button>
</div>
<div class="hero">
  <div class="hero-icon">&#x1F3AC;</div>
  <h1>ESP32 Gimbal Remote</h1>
  <p>BLE camera + joystick gimbal control</p>
</div>
)rawhtml");

    server.sendContent(
      "<div class='card battery-card'>"
      "<div class='battery-ring'>"
      "<svg viewBox='0 0 90 90'>"
      "<circle class='ring-bg' cx='45' cy='45' r='35'/>"
      "<circle class='ring-fill' cx='45' cy='45' r='35' style='stroke:" +
      ringClr + ";stroke-dashoffset:" + dashOff + "px;'/>"
      "</svg>"
      "<div class='battery-icon'>" + battIcon + "</div>"
      "</div>"
      "<div class='battery-info'>"
      "<div class='battery-pct'>" + pctStr + "<span>%</span></div>"
      "<div class='battery-status'>" + statusIcon + " " + statusText + "</div>"
      "<div class='battery-voltage'>" + volt + " V</div>"
      "</div></div>"
    );

    String manualClass = manual_control_enabled ? "manual-on" : "manual-off";

    server.sendContent(
      "<div class='card'>"
      "<div class='connection-status'>"
      "<div class='dot " + connClass + "'></div>"
      "<span>" + connLabel + " <span class='cam-name'>" + connName + "</span></span>"
      "</div>"
      "<div class='action-btns'>"
      "<a class='action-btn btn-shutter' href='/shutter'>"
      "<div class='btn-icon'>&#x1F4F7;</div>Shutter</a>"
      "<a class='action-btn btn-scan' href='/scan'>"
      "<div class='btn-icon'>&#x1F4F6;</div>Scan</a>"
      "<a class='action-btn btn-recenter' href='/recenter'>"
      "<div class='btn-icon'>&#x1F3AF;</div>Recenter</a>"
      "</div>"
      "<div class='gimbal-row'>"
      "<span>Joystick manual: <b class='" + manualClass + "'>" + manualStr + "</b></span>"
      "<span style='font-size:11px;'>press stick to toggle</span>"
      "</div>"
      "</div>"
    );

    if (devHtml.length() > 0) server.sendContent(devHtml);

    server.sendContent(
      "<div class='connect-form'>"
      "<div class='input-label'>Enter device name manually</div>"
      "<form action='/connect' method='get'>"
      "<div class='input-wrap'>"
      "<span class='input-icon'>&#x270F;</span>"
      "<input class='text-input' type='text' name='name' "
      "placeholder='e.g. ILCE-6400' value='" + targetCameraName + "'>"
      "</div>"
      "<button class='connect-btn' type='submit'>&#x1F517; Connect</button>"
      "</form>"
      "<div class='save-note'>&#x2705; Name saved — auto-reconnects on restart</div>"
      "</div>"
      "<a class='danger-btn' href='/clearbond'>&#x1F5D1; Clear Pairing Data</a>"
      "</body></html>"
    );
  });

  server.on("/scan", []() {
    startScan();
    server.sendHeader("Location", "/");
    server.send(302, "text/plain", "");
  });

  server.on("/connect", []() {
    if (server.hasArg("name")) {
      targetCameraName = server.arg("name");
      targetCameraName.trim();
      prefs.begin("gimbal", false);
      prefs.putString("camname", targetCameraName);
      prefs.end();
      Serial.printf("Connecting to: %s\n", targetCameraName.c_str());
      startScan();
    }
    server.sendHeader("Location", "/");
    server.send(302, "text/plain", "");
  });

  server.on("/shutter", []() {
    triggerShutter();
    server.sendHeader("Location", "/");
    server.send(302, "text/plain", "");
  });

  server.on("/recenter", []() {
    send_recenter();
    server.sendHeader("Location", "/");
    server.send(302, "text/plain", "");
  });

  server.on("/clearbond", []() {
    Serial.println("Clearing BLE bonding data...");
    nvs_flash_erase();
    nvs_flash_init();
    bleConnected     = false;
    pRemoteChar      = nullptr;
    connectedCamName = "";
    server.sendHeader("Location", "/");
    server.send(302, "text/plain", "");
    delay(500);
    ESP.restart();
  });

  server.begin();
  Serial.println("Web server: http://192.168.4.1");
}

// ──────────────────────────────────────────────────────────
// Setup
// ──────────────────────────────────────────────────────────
void setup() {
  Serial.begin(115200);

  // UART1 — battery telemetry from STorM32
  storm32.begin(STORM32_BAUD, SERIAL_8N1, STORM32_RX_PIN, STORM32_TX_PIN);

  // UART2 — gimbal control commands to STorM32
  Serial2.begin(STORM32_BAUD, SERIAL_8N1, STORM32_RX_PIN, STORM32_TX_PIN);
  delay(100);

  pinMode(PIN_R, OUTPUT);
  pinMode(PIN_G, OUTPUT);
  pinMode(PIN_B, OUTPUT);
  setColor(0, 0, 0);

  pinMode(BTN_MODE,    INPUT_PULLUP);
  pinMode(BTN_ACTION,  INPUT_PULLUP);
  pinMode(PIN_JOY_BTN, INPUT_PULLUP);

  analogReadResolution(10);

  prefs.begin("gimbal", true);
  targetCameraName = prefs.getString("camname", "");
  prefs.end();

  BLEDevice::init("ESP32-Gimbal");

  if (targetCameraName.length() > 0) {
    Serial.printf("Saved camera: %s — scanning...\n", targetCameraName.c_str());
    doScan = true;
  } else {
    Serial.println("No saved camera.");
    Serial.println("Press GPIO18 to start WiFi hotspot.");
    Serial.printf("WiFi: %s / %s\n", WIFI_SSID, WIFI_PASS);
    Serial.println("Then open http://192.168.4.1 to configure.");
  }

  Serial.println("──────────────────────────────────────");
  Serial.println("GPIO18      = WiFi hotspot toggle");
  Serial.println("GPIO19      = BLE Shutter");
  Serial.printf ("GPIO34/35   = Joystick X/Y (pitch/yaw)\n");
  Serial.println("GPIO33      = Joystick push — toggle manual control");
  Serial.println("──────────────────────────────────────");
  Serial.println("To pair Sony a6400:");
  Serial.println("Menu → Network → Bluetooth → Pairing");
  Serial.println("──────────────────────────────────────");
}

// ──────────────────────────────────────────────────────────
// Loop
// ──────────────────────────────────────────────────────────
void loop() {
  // ── BLE scan ──────────────────────────────────────────
  if (doScan) {
    doScan = false;
    startScan();
  }

  // ── BLE connect ───────────────────────────────────────
  if (doConnect) {
    doConnect = false;
    connectToCamera();
  }

  // ── Mode button (GPIO18) — toggle WiFi hotspot ────────
  if (digitalRead(BTN_MODE) == LOW &&
      millis() - lastPressMODE > DEBOUNCE_MS) {
    lastPressMODE = millis();
    if (currentMode == MODE_BLUETOOTH) {
      WiFi.mode(WIFI_AP);
      WiFi.softAP(WIFI_SSID, WIFI_PASS);
      setupWebServer();
      currentMode = MODE_WIFI;
      Serial.printf("WiFi hotspot on — SSID: %s\n", WIFI_SSID);
    } else {
      server.stop();
      WiFi.softAPdisconnect(true);
      currentMode = MODE_BLUETOOTH;
      Serial.println("WiFi off — BLE active");
    }
  }

  // ── Shutter button (GPIO19) ───────────────────────────
  if (digitalRead(BTN_ACTION) == LOW &&
      millis() - lastPressACTION > DEBOUNCE_MS) {
    lastPressACTION = millis();
    triggerShutter();
  }

  // ── WiFi web server ───────────────────────────────────
  if (currentMode == MODE_WIFI) {
    server.handleClient();
  }

  // ── Auto retry BLE ────────────────────────────────────
  static unsigned long lastRetry = 0;
  if (!bleConnected && targetCameraName.length() > 0 &&
      millis() - lastRetry > 15000) {
    lastRetry = millis();
    Serial.println("BLE: Auto-retry scan...");
    doScan = true;
  }

  // ── Battery reading from STorM32 ──────────────────────
  static unsigned long lastRequest = 0;
  static unsigned long lastByte    = 0;

  if (millis() - lastRequest > 1000) {
    rxLen = 0;
    storm32.write('d');
    lastRequest = millis();
  }

  while (storm32.available() && rxLen < 255) {
    rxBuf[rxLen++] = storm32.read();
    lastByte = millis();
  }

  if (rxLen > 0 && millis() - lastByte > 50) {
    if (rxLen == PACKET_LEN) {
      uint16_t raw = rxBuf[VOLT_OFFSET] | (rxBuf[VOLT_OFFSET + 1] << 8);
      batteryVoltage = raw / 1000.0f;
      if (batteryVoltage >= 10.5f && batteryVoltage <= 13.0f) {
        batteryPercent = (int)lipoPercent(batteryVoltage);
        Serial.printf("Voltage: %.3fV | Battery: %d%%\n",
                      batteryVoltage, batteryPercent);
      } else {
        Serial.println("Invalid battery reading — check connection");
        batteryPercent = -1;
      }
    } else {
      Serial.printf("Wrong packet length: %d (expected %d)\n",
                    rxLen, PACKET_LEN);
    }
    rxLen = 0;
  }

  // ── Gimbal joystick ───────────────────────────────────
  handle_joy_btn();
  if (manual_control_enabled) {
    send_joystick();
  }
  debug_gimbal_status();

  // ── RGB status LED ────────────────────────────────────
  updateLED();

  delay(10);
}