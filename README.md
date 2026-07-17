# Camera Gimbal — 3-Axis Stabilization for Smartphones & Cameras


> Custom-built 3-axis camera gimbal (STorM32 BGC + ESP32) with a self-designed 3D-printed frame, wireless shutter control, and a web dashboard for battery/BLE monitoring. Built for a Mechatronics lab project at Jade University of Applied Sciences.

---

## 🇬🇧 English

### Overview
This project is a fully custom 3-axis camera gimbal for smartphones and small action cameras, developed as part of the "Komplexlabor Mechatronik" course at Jade Hochschule Wilhelmshaven (Summer 2026). The goal was to design, build, and validate a handheld gimbal that stabilizes roll, pitch, and yaw in real time, using a mechanically optimized 3D-printed frame and an open, configurable electronics stack instead of a proprietary commercial system (e.g. DJI RS5).

### Key Features
- **3-axis active stabilization** (roll, pitch, yaw) via three iPower GM3506 brushless gimbal motors with AS5048A encoders
- **STorM32 v4.1** BGC controller + **NT IMU v4.2** for orientation sensing and PID-based motor control
- **ESP32** microcontroller handling joystick input, buttons, status LED, and wireless connectivity
- **WLAN/Bluetooth bridge**: a companion phone connects to the ESP32 over Wi-Fi and relays Bluetooth shutter commands to the camera
- **Custom HTML web interface** showing live battery percentage/voltage and providing remote shutter + Bluetooth scan controls
- Self-designed 3D-printed frame (P430 ABS+), removable 11.1 V / 3000 mAh LiPo battery, IP54-rated enclosure target
- Requirements list, circuit diagram, energy-flow diagram, and full verification & validation (V&V) test protocol

### Test Results (summary)
| Test | Result |
|---|---|
| Battery life (215 g payload) | ~2 hours |
| Reaction time (90° step) | 2.46 s (≈36.6°/s) |
| IMU drift (roll/pitch) | No measurable drift |
| Motor thermal | Uncritical after 10–15 min continuous load |
| TRL | 4, approaching 5 |

### Hardware
STorM32 v4.1, NT IMU v4.2, 3× iPower GM3506 gimbal motors, ESP32 (NodeMCU), analog joystick module, 2-button module, RGB status LED, 11.1 V 3000 mAh LiPo + balance charger. Full bill of materials with suppliers and cost is included in the lab report.


### Status & Outlook
The mechanical and electrical integration is complete; PID tuning (especially on the yaw axis) and full closed-loop real-time stabilization are ongoing. Planned next steps include C++/PlatformIO code refactoring with auto-reconnect, mechanical load testing of the screw connections, and empirical battery-life validation under real load.

---

## 🇩🇪 Deutsch

### Überblick
Dieses Projekt ist ein vollständig selbst entwickeltes 3-Achsen-Kamera-Gimbal für Smartphones und kleine Actioncams, entstanden im Rahmen des Komplexlabors Mechatronik an der Jade Hochschule Wilhelmshaven (Sommersemester 2026). Ziel war die Konstruktion, der Aufbau und die Validierung eines Handheld-Gimbals, das Roll-, Pitch- und Yaw-Bewegungen in Echtzeit ausgleicht — mit einem mechanisch optimierten, selbst konstruierten 3D-Druck-Rahmen und einer offenen, konfigurierbaren Elektronik statt eines proprietären kommerziellen Systems (z. B. DJI RS5).

### Hauptmerkmale
- **Aktive 3-Achsen-Stabilisierung** (Roll, Pitch, Yaw) über drei bürstenlose iPower-GM3506-Kardanmotoren mit AS5048A-Encodern
- **STorM32 v4.1** BGC-Controller + **NT IMU v4.2** zur Lageerfassung und PID-basierten Motorregelung
- **ESP32**-Mikrocontroller für Joystick-Eingabe, Taster, Status-LED und drahtlose Kommunikation
- **WLAN/Bluetooth-Brücke**: Ein Mobiltelefon verbindet sich per WLAN mit dem ESP32 und leitet Bluetooth-Auslösebefehle an die Kamera weiter
- **Eigenes HTML-Web-Interface** mit Live-Anzeige von Akkustand/Spannung sowie Fernsteuerung von Auslöser und Bluetooth-Suchlauf
- Selbst konstruierter 3D-Druck-Rahmen (P430 ABS+), entnehmbarer 11,1 V / 3000 mAh LiPo-Akku, Gehäuse ausgelegt auf IP54
- Anforderungsliste, Schaltplan, Energieflussdiagramm sowie ein vollständiges Verifikations- und Validierungs-Testprotokoll (V+V)

### Testergebnisse (Zusammenfassung)
| Test | Ergebnis |
|---|---|
| Akkulaufzeit (215 g Nutzlast) | ca. 2 Stunden |
| Reaktionszeit (90°-Schwenk) | 2,46 s (≈36,6°/s) |
| IMU-Drift (Roll/Pitch) | Keine messbare Drift |
| Motorerwärmung | Unkritisch nach 10–15 Min Dauerbetrieb |
| TRL | 4, an der Schwelle zu 5 |

### Hardware
STorM32 v4.1, NT IMU v4.2, 3× iPower-GM3506-Kardanmotoren, ESP32 (NodeMCU), analoges Joystick-Modul, 2-Tasten-Modul, RGB-Status-LED, 11,1 V 3000 mAh LiPo-Akku mit Balance-Ladegerät. Die vollständige Stückliste mit Lieferanten und Kosten befindet sich im Laborbericht.


### Status & Ausblick
Der mechanische und elektronische Aufbau ist abgeschlossen; die PID-Feinabstimmung (insbesondere der Yaw-Achse) sowie die vollständige Echtzeit-Stabilisierung im geschlossenen Regelkreis sind noch in Arbeit. Geplante nächste Schritte: Code-Refactoring in C++/PlatformIO mit automatischer Wiederverbindung, mechanischer Belastungstest der Schraubverbindungen sowie empirische Validierung der Akkulaufzeit unter realer Last.
