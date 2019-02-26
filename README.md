# CYUSB3KIT-003 with SP605 xilinx

This project aim was to use the Cypress [CYUSB3KIT-003 EZ-USB FX3 SuperSpeed Explorer Kit](http://www.cypress.com/documentation/development-kitsboards/cyusb3kit-003-ez-usb-fx3-superspeed-explorer-kit)
to both **program** (upload the firmware of the FPGA using the kit) and **communicate** (make the FPGA send info and receive it with the PC and vice versa) with a Xilinx Spartan 6 FPGA embedded on the [SP605 Evaluation Kit](https://www.xilinx.com/products/boards-and-kits/ek-s6-sp605-g.html).

The implementation had to be adapted to a C++ code in linux so every CPU tool was then simulated on an own C++ code.

In order to connect both boards, the [CYUSB3ACC-005 FMC Interconnect Board](http://www.cypress.com/documentation/development-kitsboards/cyusb3acc-005-fmc-interconnect-board-ez-usb-fx3-superspeed) was used.

**Note:**
For confidentiality issues the integration of the whole project could not be uploaded but I uploaded what may be useful for other people that does not conflict with confidential agreement. The FPGA code was also merged into an existing code but I couldn't upload anything of it.

## Valuable content of the project

1. This project displays in a very detailed way how to connect the CYUSB3KIT with SP605 board.
2. Provides a class that enables a easy to use interface with Cypress devices for other implementations.

## Project Structure
 - **docs**: Project's documentation like API functions.
 - **fx3_manager_cpp_source**: Cpp project to communicate with FX3 device.
 - **com_fpga**: firmware for both FPGA and FX3 to be able to perform a loopback communication between CPU and FPGA via FX3.
 - **program_fpga**: Software needed to program the FPGA.
 - **doc**: useful documentation from Cypress and Xilinx  

## cpp Class for communicating with FX3

 Inside [fx3_manager_cpp_source](https://github.com/NEGU93/CYUSB3KIT-003_with_SP605_xilinx/tree/master/fx3_manager_cpp_source) there's a cpp project that enables communication with the PC with the FX3. It gives and API that can be used for others to use a Cypress device in general. For information on how to use this class please refer to [API documentation](docs/API_Doc.md)

 It performs download of firmware, programs the FPGA, prints descriptions, run performance tests, sends and receives bulk data between other things.

 If you run the code (main function) it automatically programs the FX3 devices. It waits for the user to turn on the FPGA and press enter. Then it programs the FPGA and finally tries some loopback communication asserting the data sent is the same that the data received.

 The communication to the FX3 device is done through a Cpp class that manages all the FX3 connection using cyusb library, who uses libusb-1.0. If the user want's to do it's own function he can just change the main.cpp and use the class created.

## Citations

I would like to know if this explanations or code was useful to somebody so if it's the case let me know (star the project for ex.)
Just use this as you need!
