#include "JoystickModule.h"

JoystickModule::JoystickModule(uint8_t xPin, uint8_t yPin, uint8_t swPin)
    : _xPin(xPin), _yPin(yPin), _swPin(swPin) {}        //Passing Variable from analog to header (Initialiser List)

void JoystickModule::begin() {                          //sets the button pin mode (needs digInput, X and Y just analogread directly)
    pinMode(_swPin, INPUT_PULLUP);                      //INPUT_PULLUP = Arduino internal pull-up resistor
}

JoystickData JoystickModule::read() {                   //returns Jostyick data
    JoystickData data;                                  //var data under JoystickData struct    
    data.x = analogRead(_xPin);                         //reads the value of the x-axis and assigns it to data.x
    data.y = analogRead(_yPin);                         //reads the value of the y-axis and assigns it to data.y
    data.pressed = (digitalRead(_swPin) == LOW);        //reads the value of the button and assigns it to data.pressed 
    return data;
}