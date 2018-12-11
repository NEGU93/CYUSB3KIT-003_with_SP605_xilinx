# CYUSB3KIT-003 with SP605 xilinx

This project aim was to use the Cypress [CYUSB3KIT-003 EZ-USB FX3 SuperSpeed Explorer Kit](http://www.cypress.com/documentation/development-kitsboards/cyusb3kit-003-ez-usb-fx3-superspeed-explorer-kit)
to both **program** (upload the firmware of the FPGA using the kit) and **communicate** (make the FPGA send info and receive it with the PC and vice versa) with a Xilinx Spartan 6 FPGA embedded on the [SP605 Evaluation Kit](https://www.xilinx.com/products/boards-and-kits/ek-s6-sp605-g.html).

In order to connect both boards, the [CYUSB3ACC-005 FMC Interconnect Board](http://www.cypress.com/documentation/development-kitsboards/cyusb3acc-005-fmc-interconnect-board-ez-usb-fx3-superspeed) was used.

## Getting Started
### Installing Software
For this project, the following software was installed:
  1. [ISE Design Suite for Windows 10](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/design-tools.html): Will enable to compile the FPGA source code and to program the FPGA for the firsts steps
  2. [EZ-USB FX3 Software Development Kit](http://www.cypress.com/documentation/software-and-drivers/ez-usb-fx3-software-development-kit): To use the Cypress board

### Switching to Debian

Because of the final application, I was forced to move to a linux distribution. In order to do that download the linux tar installer and follow the instructions on `fx3_firmware_linux.tar.gz/cyfx3sdk/FX3_SDK_Linux_Support.pdf`. Some bugs where found during the installation but they where easily fixed searching on the Cypress forum (I don recall all of them right now. Sorry).

#### cyusb_linux

Try to configure and get a loopback response with cyusb_linux. The following thread may help: https://community.cypress.com/thread/41993.

#### Using compiled scripts

Go to `/Cypress/cyusb_linux_1.0.5/src` and run the make command. Many scripts will be compiled that may help you debug and test your board.

You can test the scripts using `cyusb_linux_1.0.5/docs/cyusb_linux_programmers_guide.pdf` document.

Problems encountered when running scripts:

1. `./04_kerneldriver`
```
This device has no kernel driver attached to this interface
Do you wish to attach/reattach a kernel driver ? (1=yes,0=no) : 1
Entity not found
```
2. `./06_setalternate`
```
Enter interface number you wish to claim : 0
Interface 0 claimed successfully
Enter alternate interface you wish to set : 1
Entity not found
```
 - When running `./05_claiminterface` with 1 as input it also fails. It seams I have issues with other interfaces (1-4).
3. `./08_cybulk`
```
Successfully claimed interface
Input/output error
libusb: error [submit_bulk_transfer] submiturb failed error -1 errno=9
Input/output error
Segmentation fault (core dumped)
```
 - I am not sure here the correct firmware I need to upload to make it work. I believe the issue is something like that.


### Getting started with Xilinx and the SDK
As I had no experience with Xilinx FPGA's, I used some tutorials to practice and get to know the board:
  1. First check the board is working correclty: [Getting Started with SP605 Evaluation Kit](https://www.xilinx.com/support/documentation/boards_and_kits/ug525.pdf)
  2. Try to create/simulate and program a simple FPGA program and check it works: [ISE 10.1 QuickStart Tutorial](http://www.eng.ucy.ac.cy/theocharides/Courses/ECE408/qst.pdf)

  Some thing may be taken into account:
    - If the case (using SP605) when doing step 2 on the manual, just select the board disectly instead of selecting the Spartan 6 board.
    - If you have problems when doing the pin assignment: [How to assign physical pins of FPGA to Xilinx ISE Verilog modules?](https://electronics.stackexchange.com/questions/86961/how-to-assign-physical-pins-of-fpga-to-xilinx-ise-verilog-modules/406913#406913)
    
   #### Installing for linux:
   Follow [ISE Design Suite: Installation and Licensing Guide](https://www.xilinx.com/support/documentation/sw_manuals/xilinx13_2/iil.pdf)
   Once installed for linux, you may run the following:
```
ise            - Project Navigator
xps            - EDK Platform Studio
planAhead      - PlanAhead
fpga_editor    - FPGA editor
coregen        - Core Generator
timingan       - Timing Analyzer
smartxplorer   - SmartXplorer
sysgen         - System Generator
analyzer       - Chipscope Analyzer
```

### Playing with Cypress SuperSpeed Explorer Kit
  1. First check the board is working correcly: [EZ-USB FX3TM SUPERSPEED EXPLORER KIT QUICK START GUIDE](http://www.cypress.com/file/133831/download)
  2. Then follow a very good documented guide. Learn how to communicate, program and run UART and debugging tools [SuperSpeed Explorer Kit User Guide](http://www.cypress.com/file/133836/download)

## Communicating with the FPGA
This part uploads a firmware to the FPGA using the ISE software and then communicates the computer with the FPGA via the USB3 provided by the Cypress module.

The following documentation was used: [AN65974](http://www.cypress.com/documentation/application-notes/an65974-designing-ez-usb-fx3-slave-fifo-interface)

Although it was needed to addapt from the SP601 board to the SP605.
The pin assignment was changed using both [SP605 Hardware User Guide](https://www.xilinx.com/support/documentation/boards_and_kits/ug526.pdf)
and [SP601 Hardware User Guide](https://www.xilinx.com/support/documentation/boards_and_kits/ug518.pdf) to make the interface pin compatible with the Cypress Interconnect Board. This way, no change was done to the CYUSB3KIT firmware.

The following fragment of code shows the changes done to the ucf file to addapt the pinout to the SP605 board.

```
NET "fdata[0]"  LOC = H12;  // C10; 	-> // J63 FMC LPC: H4
NET "fdata[1]"  LOC = G8;   // C15; 	-> // J63 FMC LPC: H7
NET "fdata[2]"  LOC = F9;   // A15; 	-> // J63 FMC LPC: H8
NET "fdata[3]"  LOC = C19;  // B16; 	-> // J63 FMC LPC: H10
NET "fdata[4]"  LOC = A19;  // A16; 	-> // J63 FMC LPC: H11
NET "fdata[5]"  LOC = B2;   // E7;  	-> // J63 FMC LPC: H13
NET "fdata[6]"  LOC = A2;   // E8;  	-> // J63 FMC LPC: H14
NET "fdata[7]"  LOC = H14;  // B12; 	-> // J63 FMC LPC: H16
NET "fdata[8]"  LOC = G15;  // A12; 	-> // J63 FMC LPC: H17
NET "fdata[9]"  LOC = D18;  // G9;  	-> // J63 FMC LPC: H19
NET "fdata[10]" LOC = G19;  // F9;  	-> // J63 FMC LPC: H20
NET "fdata[11]" LOC = R11;  // N6;  	-> // J63 FMC LPC: H22
NET "fdata[12]" LOC = T11;  // P7;  	-> // J63 FMC LPC: H23
NET "fdata[13]" LOC = V11;  // T4;  	-> // J63 FMC LPC: H25
NET "fdata[14]" LOC = W11;  // V4;  	-> // J63 FMC LPC: H26
NET "fdata[15]" LOC = AA14; // U8;  	-> // J63 FMC LPC: H28
NET "fdata[16]" LOC = AB14; // V8;  	-> // J63 FMC LPC: H29
NET "fdata[17]" LOC = AA16; // U11; 	-> // J63 FMC LPC: H31
NET "fdata[18]" LOC = AB16; // V11; 	-> // J63 FMC LPC: H32
NET "fdata[19]" LOC = Y15;  // T12; 	-> // J63 FMC LPC: H34
NET "fdata[20]" LOC = AB15; // V12; 	-> // J63 FMC LPC: H35
NET "fdata[21]" LOC = W17;  // U15; 	-> // J63 FMC LPC: H37
NET "fdata[22]" LOC = Y18;  // V15; 	-> // J63 FMC LPC: H38
NET "fdata[23]" LOC = E16;  // T9;  	-> // J63 FMC LPC: G2
NET "fdata[24]" LOC = F16;  // V9;  	-> // J63 FMC LPC: G3
NET "fdata[25]" LOC = B18;  // C13; 	-> // J63 FMC LPC: G9
NET "fdata[26]" LOC = A18;  // A13; 	-> // J63 FMC LPC: G10
NET "fdata[27]" LOC = B20;  // F11; 	-> // J63 FMC LPC: G12
NET "fdata[28]" LOC = A20;  // E11; 	-> // J63 FMC LPC: G13
NET "fdata[29]" LOC = H13;  // D6;  	-> // J63 FMC LPC: G15
NET "fdata[30]" LOC = G13;  // C6; 	-> // J63 FMC LPC: G16
NET "fdata[31]" LOC = C5;   // C7;  	-> // J63 FMC LPC: G18
NET "faddr[0]" LOC = Y17;   // N9 ;  -> // J63 FMC LPC: G36
NET "faddr[1]" LOC = AB17;  // M10;  -> // J63 FMC LPC: G37
//NET "sync" LOC = V13;
NET "clk" LOC     = AB13;   // V10; 	-> // X2 27 MHz OSC
NET "clk_out" LOC = G9;     // D9;	-> // J63 FMC LPC: G6
NET "slcs" LOC = A5;        // A7;	-> // J63 FMC LPC: G19
NET "sloe" LOC = R8;        // P8;	-> // J63 FMC LPC: G22
NET "slrd" LOC = V7;        // R7;	-> // J63 FMC LPC: G24
NET "slwr" LOC = R9;        // N7;	-> // J63 FMC LPC: G21
NET "flaga" LOC = W8;       // T7;	-> // J63 FMC LPC: G25
NET "flagb" LOC = W14;      // M11;	-> // J63 FMC LPC: G27
NET "flagc" LOC = Y14;      // N11;	-> // J63 FMC LPC: G28
NET "flagd" LOC = U15;      // N8;	-> // J63 FMC LPC: G31
NET "pktend" LOC = T15;     // M8;	-> // J63 FMC LPC: G30
// USER DIP SWITCH
NET "mode_p[0]" LOC = C18;  // D14;
NET "mode_p[1]" LOC = Y6;   // E12;	 
NET "mode_p[2]" LOC = W6;   // F12;  
//NET "PMODE_2" LOC = G11;
NET "PMODE[1]" LOC = A4;    // A14;	-> // J63 FMC LPC: D12
NET "PMODE[0]" LOC = C4;    // B14;	-> // J63 FMC LPC: D11
NET "RESET" LOC = G16;      // B11;	-> // J63 FMC LPC: D17
//NET "int_n" LOC = F10;
NET "reset_in_n" LOC = F8;  // F10; 	-> // J63 FMC LPC: D15
```

When following section 10.5 from [AN65974](http://www.cypress.com/documentation/application-notes/an65974-designing-ez-usb-fx3-slave-fifo-interface), the switch SW8 will not really exist. The USER DIP SWITCH must be used instead. For the rest just follow the instructions as needed. Configure the USER DIP SWITCH according to the following table:

![Dip Switch Config Table](/img/fpga_com/DS_conf_table.png)

Here some output examples of the code working correctly:

<img src="/img/fpga_com/StreamerIN.png" width="400"/> <img src="/img/fpga_com/ZLP.png" width="400"/>

## Program the FPGA

This section aim is to program the FPGA using the FX3 kit directly and not the JTAG. For it, the SPI x4 Flash is used and connected to the FX3 board.

The following documentation was used: [AN84868](http://www.cypress.com/documentation/application-notes/an84868-configuring-fpga-over-usb-using-cypress-ez-usb-fx3)

In order to do that, two cables must be sold to the FPGA. In this case, as the board is different, the image of the instruction won't be good enough so the LED's where measured with an ammeter to know the right side of the LED and the conclusion can be seen in the folliwng image:

![init_done_leds](/img/fpga_prog/where_to_sold.png)

[Convert bit to bin](https://electronics.stackexchange.com/questions/407801/convert-bit-to-bin-xilinx-file)

## Program and communicate with the FPGA
TODO: merge last two sections

## Citations

I would like to know if this explanatios or code was usefull to somebody so if it's the case let me know (star the project for ex.)
Just use this as you need!

## Note:
This project is still under development. It started on Nov 2018.
