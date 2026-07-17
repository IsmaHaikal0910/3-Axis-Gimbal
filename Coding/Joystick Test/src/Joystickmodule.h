#ifndef JOYSTICKMODULE_H
#define JOYSTICKMODULE_H

#include <Arduino.h>

struct JoystickData {
    int x;
    int y;
    bool pressed;
};

class JoystickModule {
private:
    uint8_t _xPin;
    uint8_t _yPin;
    uint8_t _swPin;

public:
    JoystickModule(uint8_t xPin, uint8_t yPin, uint8_t swPin);
    void begin();
    JoystickData read();
};

#endif