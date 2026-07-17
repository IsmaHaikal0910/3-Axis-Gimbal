#include <Arduino.h>
#include "JoystickModule.h"

// Joystick object
JoystickModule joystick(A0, A1, 2);

// LED pins
const uint8_t LED_RIGHT = 6;
const uint8_t LED_LEFT  = 7;
const uint8_t LED_UP    = 8;
const uint8_t LED_DOWN  = 9;

// Joystick center and dead zone
const int CENTER = 512;
const int DEADZONE = 80;

// Convert joystick distance from center into LED brightness (0 to 255)
int getBrightness(int value, int center, int deadzone, bool positiveDirection) {
    int distance;

    if (positiveDirection) {
        distance = value - center;   // right or up
    } else {
        distance = center - value;   // left or down
    }

    if (distance <= deadzone) {
        return 0;
    }

    distance = distance - deadzone;

    if (distance > (512 - deadzone)) {
        distance = 512 - deadzone;
    }

    return map(distance, 0, 512 - deadzone, 0, 255);
}

void setup() {
    Serial.begin(9600);
    Serial.println("THIS IS MY CURRENT PROJECT");
    joystick.begin();

    pinMode(LED_RIGHT, OUTPUT);
    pinMode(LED_LEFT, OUTPUT);
    pinMode(LED_UP, OUTPUT);
    pinMode(LED_DOWN, OUTPUT);
}

void loop() {
    JoystickData joy = joystick.read();

    // X axis controls left and right LEDs
    int rightBrightness = getBrightness(joy.x, CENTER, DEADZONE, true);
    int leftBrightness  = getBrightness(joy.x, CENTER, DEADZONE, false);

    // Y axis controls up and down LEDs
    // Some joystick modules are reversed on Y, so swap UP/DOWN if needed
    int upBrightness    = getBrightness(joy.y, CENTER, DEADZONE, true);
    int downBrightness  = getBrightness(joy.y, CENTER, DEADZONE, false);

    analogWrite(LED_RIGHT, rightBrightness);
    analogWrite(LED_LEFT, leftBrightness);
    analogWrite(LED_UP, upBrightness);
    analogWrite(LED_DOWN, downBrightness);

    Serial.print("X: ");
    Serial.print(joy.x);
    Serial.print(" Y: ");
    Serial.print(joy.y);
    Serial.print(" | R: ");
    Serial.print(rightBrightness);
    Serial.print(" L: ");
    Serial.print(leftBrightness);
    Serial.print(" U: ");
    Serial.print(upBrightness);
    Serial.print(" D: ");
    Serial.println(downBrightness);

    delay(20);
}