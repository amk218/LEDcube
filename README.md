# 4x4x4 Programmable LED Cube
This project involves a 4x4x4 LED matrix built by soldering individual LEDs together. The code in this repository allows the microcontroller to light up the LEDs, creating static and moving light patterns on it. In addition, the device is programmed with the following functionalities:
- Input from a button changes between light modes
- Input from an external ambient light sensor (Mikroelectronika light click) determines the on/off state of the cube, so that lights are only on when the room is sufficiently dark

The code is written for EasyPIC pro V7 with PIC18F.
The project contains the following files:
- main.s  - main project file
- Patterns.s - routines for creating static and animated light modes
- Pattern_table.s - data for light patterns and a routine for loading the data to RAM for easy access with the FSR
- Interrupts.s  - this file handles the interrupt triggered by the button RB1
- Light_Sensor.s  - this file handles communications with the light sensor and determining if the current light level is below the threshold

In order to run the project, all files must be in the project same project folder. Running main.s will operate the whole device with all functionality, and the program will keep running until the device is manually switched off.

A video demonstration of the operation of the device can be found here: https://youtu.be/FoGqwxilCHo

A full circuit diagram of the hardware construction can be seen below:
[LED_Cube_Schematic.pdf](https://github.com/amk218/LEDcube/files/6417274/LED_Cube_Schematic.pdf)
