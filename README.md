# CYUSB3KIT-003 with SP605 xilinx

This project aim was to use the Cypress [CYUSB3KIT-003 EZ-USB FX3 SuperSpeed Explorer Kit](http://www.cypress.com/documentation/development-kitsboards/cyusb3kit-003-ez-usb-fx3-superspeed-explorer-kit) 
to both **program** and **communicate** with a Xilinx Spartan 6 FPGA embedded on the [SP605 Evaluation Kit](https://www.xilinx.com/products/boards-and-kits/ek-s6-sp605-g.html).

In order to connect both boards, the [CYUSB3ACC-005 FMC Interconnect Board](http://www.cypress.com/documentation/development-kitsboards/cyusb3acc-005-fmc-interconnect-board-ez-usb-fx3-superspeed)
was used.

## Getting Started
### Installing Software
For this project, the following software was installed:
  1. [ISE Design Suite for Windows 10](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/design-tools.html): Will enable to compile the FPGA source code and to program the FPGA for the firsts steps
  2. [EZ-USB FX3 Software Development Kit](http://www.cypress.com/documentation/software-and-drivers/ez-usb-fx3-software-development-kit): To use the Cypress board

### Getting started with Xilinx and the SDK
As I had no experience with Xilinx FPGA's, I used some tutorials to practice and get to know the board:
  1. First check the board is working correclty: [Getting Started with SP605 Evaluation Kit](https://www.xilinx.com/support/documentation/boards_and_kits/ug525.pdf)
  2. Try to create/simulate and program a simple FPGA program and check it works: [ISE 10.1 QuickStart Tutorial](http://www.eng.ucy.ac.cy/theocharides/Courses/ECE408/qst.pdf)
   
  Some thing may be taken into account: 
    - If the case (using SP605) on step 2, just select the board disectly instead of selecting the Spartan 6 board.
    - If you have problems when doing the pin assignment: [How to assign physical pins of FPGA to Xilinx ISE Verilog modules?](https://electronics.stackexchange.com/questions/86961/how-to-assign-physical-pins-of-fpga-to-xilinx-ise-verilog-modules/406913#406913)

### Playing with Cypress SuperSpeed Explorer Kit
  1. First check the board is working correcly: [EZ-USB FX3TM SUPERSPEED EXPLORER KIT QUICK START GUIDE](http://www.cypress.com/file/133831/download)
  2. Then follow a very good documented guide. Learn how to communicate, program and run UART and debugging tools [SuperSpeed Explorer Kit User Guide](http://www.cypress.com/file/133836/download)
    
## Communicate with the FPGA
This part uploads a firmware to the FPGA using the ISE software and then communicates the computer with the FPGA via the USB3 provided by the Cypress module.

The following documentation was used: [AN65974](http://www.cypress.com/documentation/application-notes/an65974-designing-ez-usb-fx3-slave-fifo-interface)

Although it was needed to addapt from the SP601 board to the SP605. 
The pin assignment was changed using both [SP605 Hardware User Guide](https://www.xilinx.com/support/documentation/boards_and_kits/ug526.pdf)
and [SP601 Hardware User Guide](https://www.xilinx.com/support/documentation/boards_and_kits/ug518.pdf) to make the interface pin compatible with
the Cypress Interconnect Board. This way, no change was done to the CYUSB3KIT firmware.

## Program the FPGA

[Convert bit to bin](https://electronics.stackexchange.com/questions/407801/convert-bit-to-bin-xilinx-file)

## Program and communicate with the FPGA
TODO: merge last two sections

## Note:
This project is still under development. It started on Nov 2018.
