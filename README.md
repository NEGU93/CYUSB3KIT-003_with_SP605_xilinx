# CYUSB3KIT-003 with SP605 xilinx

This project aim was to use the Cypress [CYUSB3KIT-003 EZ-USB FX3 SuperSpeed Explorer Kit](http://www.cypress.com/documentation/development-kitsboards/cyusb3kit-003-ez-usb-fx3-superspeed-explorer-kit)
to both **program** (upload the firmware of the FPGA using the kit) and **communicate** (make the FPGA send info and receive it with the PC and vice versa) with a Xilinx Spartan 6 FPGA embedded on the [SP605 Evaluation Kit](https://www.xilinx.com/products/boards-and-kits/ek-s6-sp605-g.html).

In order to connect both boards, the [CYUSB3ACC-005 FMC Interconnect Board](http://www.cypress.com/documentation/development-kitsboards/cyusb3acc-005-fmc-interconnect-board-ez-usb-fx3-superspeed) was used.

## 1. Project Structure
 - **fx3_manager_cpp_source**: Cpp project to communicate with FX3 device.
 - **com_fpga**: firmware for both FPGA and FX3 to be able to perform a loopback communication between CPU and FPGA via FX3.
 - **program_fpga**: Software needed to program the FPGA.
 - **doc**: usefull documentation from Cypress and Xilinx  

## 2. Getting Started
### 2.1. Installing Software
For this project, the following software was installed:
  1. [ISE Design Suite for Windows 10](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/design-tools.html): Will enable to compile the FPGA source code and to program the FPGA for the firsts steps
  2. [EZ-USB FX3 Software Development Kit](http://www.cypress.com/documentation/software-and-drivers/ez-usb-fx3-software-development-kit): To use the Cypress board

### 2.2. ISE linux

Because of the final application, I was forced to move to a linux distribution. In order to do that download the linux tar installer and follow the instructions on `fx3_firmware_linux.tar.gz/cyfx3sdk/FX3_SDK_Linux_Support.pdf`. Some bugs where found during the installation but they where easily fixed searching on the Cypress forum (I don recall all of them right now. Sorry).

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
iMPACT had some problems with drivers which I couldn't fix. What I did is install *Vivado_Lab* to upload the .bin generated with *ise* to the FPGA board. You cannot program the code directly on *Vivado_Lab* as it does not support Spartan 6. Although it seams as an ugly fix, doing this gets better programming time as Vivado's programmer greatelly outperforms the one fo iMPACT. I recommend to add the following lines to `.bashrc` file:
```
alias vivado='source /opt/Xilinx/Vivado_Lab/2018.2/settings64.sh && vivado_lab'
alias ise='source /opt/Xilinx/14.7/ISE_DS/settings64.sh && ise'
```
With those lines you can now run ise and vivado from the terminal in a simple way.
There's a *.bin* file on: `CYUSB3KIT-003_with_SP605_xilinx/fpga_source_code/tutorial/counter.bin` that could be used to test how to program the FPGA using *Vivado_Lab* directly.


### 2.3. Getting started with Xilinx and the SDK
As I had no experience with Xilinx FPGA's, I used some tutorials to practice and get to know the board:
  1. First check the board is working correctly: [Getting Started with SP605 Evaluation Kit](https://www.xilinx.com/support/documentation/boards_and_kits/ug525.pdf)
  2. Try to create/simulate and program a simple FPGA program and check it works: [ISE 10.1 QuickStart Tutorial](http://www.eng.ucy.ac.cy/theocharides/Courses/ECE408/qst.pdf)

  Some thing may be taken into account:
    - If the case (using SP605) when doing step 2 on the manual, just select the board disectly instead of selecting the Spartan 6 board.
    - If you have problems when doing the pin assignment: [How to assign physical pins of FPGA to Xilinx ISE Verilog modules?](https://electronics.stackexchange.com/questions/86961/how-to-assign-physical-pins-of-fpga-to-xilinx-ise-verilog-modules/406913#406913)

### 2.4. Playing with Cypress SuperSpeed Explorer Kit
  1. First check the board is working correcly: [EZ-USB FX3TM SUPERSPEED EXPLORER KIT QUICK START GUIDE](http://www.cypress.com/file/133831/download)
  2. Then follow a very good documented guide. Learn how to communicate, program and run UART and debugging tools [SuperSpeed Explorer Kit User Guide](http://www.cypress.com/file/133836/download)

#### 2.4.1 cyusb_linux

  Try to configure and get a loopback response with cyusb_linux.

  The following thread may help: https://community.cypress.com/thread/41993.

#### 2.4.2 Using compiled scripts

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

## 3. Communicating with the FPGA
This part uploads a firmware to the FPGA using the ISE software and then communicates the computer with the FPGA via the USB3 provided by the Cypress module.

The following documentation was used: [AN65974](http://www.cypress.com/documentation/application-notes/an65974-designing-ez-usb-fx3-slave-fifo-interface)

Although it was needed to addapt from the SP601 board to the SP605.
The pin assignment was changed using both [SP605 Hardware User Guide](https://www.xilinx.com/support/documentation/boards_and_kits/ug526.pdf)
and [SP601 Hardware User Guide](https://www.xilinx.com/support/documentation/boards_and_kits/ug518.pdf) to make the interface pin compatible with the Cypress Interconnect Board. This way, no change was done to the CYUSB3KIT firmware.

The following fragment of code shows the changes done to the ucf file to addapt the pinout to the SP605 board. (Xilinx project is on [CYUSB3KIT-003_with_SP605_xilinx/fpga_source_code/fpga_slavefifo2b_vhdl/](https://github.com/NEGU93/CYUSB3KIT-003_with_SP605_xilinx/tree/master/fpga_source_code/fpga_slavefifo2b_vhdl))

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

### 3.1. Linux distribution

As it was more of interest on how to make it work for the linux case. Here it is a detail description on how to do it.

1. With the FPGA board OFF. Connect the FX3 device and program it with the code from the official documentation ([AN65974](http://www.cypress.com/documentation/application-notes/an65974-designing-ez-usb-fx3-slave-fifo-interface)).
<p align="center">
<img src="/img/fpga_com/linux/step1.png" width="400"/>
</p>

<p align="center">
<img src="/img/fpga_com/linux/step2.png" width="400"/>
</p>

<p align="center">
<img src="/img/fpga_com/linux/step3.png" width="400"/>
</p>
2. Program the FPGA with the bin file of the changed code.
<p align="center">
<img src="/img/fpga_com/linux/step4.png" width="400"/>
</p>
3. Select 'Auto connect' to detect the board.
<p align="center">
<img src="/img/fpga_com/linux/step5.png" width="500"/>
</p>

<p align="center">
<img src="/img/fpga_com/linux/step6.png" width="300"/>
</p>

<p align="center">
<img src="/img/fpga_com/linux/step7.png" width="500"/>
</p>

<p align="center">
<img src="/img/fpga_com/linux/step8.png" width="300"/>
</p>
4. Send the information
<p align="center">
<img src="/img/fpga_com/linux/step10.png" width="400"/>
</p>

<p align="center">
<img src="/img/fpga_com/linux/step11.png" width="400"/>
</p>

## 4. Program the FPGA

This section aim is to program the FPGA using the FX3 kit directly and not the JTAG. For it, the SPI x4 Flash is used and connected to the FX3 board.

The following documentation was used: [AN84868](http://www.cypress.com/documentation/application-notes/an84868-configuring-fpga-over-usb-using-cypress-ez-usb-fx3).

There are several options to configure an FPGA described on [Xilinx Spartan-6 FPGA Configuration User Guide](http://www.xilinx.com/support/documentation/user_guides/ug380.pdf). For this scenario we are using a Slave Serial Mode in which the FX3 device will act as a master.

### 4.1. Getting things ready

#### 4.1.1 Solding and connecting cables

First of all, because we are using the board SP605 and not SP601 the cables we have to sold are not the same as in the instruction. The LED's where measured with an ammeter to know the right side of the LED and the conclusion can be seen in the following images:

<img src="/img/fpga_prog/Where_to_sold/IMG_20190109_104748.jpg" width="400"/>
<img src="/img/fpga_prog/Where_to_sold/IMG_20190109_135850.jpg" width="400"/>

The cables will be connected as follow:

<img src="/img/fpga_prog/Where_to_sold/IMG_20190109_104715.jpg" width="400"/>
<img src="/img/fpga_prog/Where_to_sold/IMG_20190109_104735.jpg" width="400"/>
<img src="/img/fpga_prog/Where_to_sold/IMG_20190109_104743.jpg" width="400"/>

#### 4.1.2. Jumpers and switches

 * The SW1 switch on the SP605 board should have both M0 and M1 up (logic 1) as we are using the Slave Serial mode.
 <p align="center">
<img src="/img/fpga_prog/Datasheet_FPGA/M_table.png" width="400"/>
</p>

 * The FX3 J2, J3 and J4 jumpers must be connected and J5 disconnected  

### 4.2. Programming steps

1. Run FPGA Configuration Utility (`FPGA Configuration Utility\bin\Release\Template.exe`).
<p align="center">
<img src="/img/fpga_prog/Config_Program_Steps/Image1.png" width="400"/>
</p>
2. Connect the FX3 device. The message: "EZ-USB FX3 Bootloader Device connected" should appear.
<p align="center">
<img src="/img/fpga_prog/Config_Program_Steps/Image2.png" width="400"/>
</p>

 - If it doesn't appear the message, make sure the FPGA is turned off, if it was already off, check the driver is correctly installed:
    * To manually bind the driver, in Windows Device Manager, locate the FX3 device under "Other Devices". Right click the device and select Update Driver Sofware. Choose Browse my computer for driver software.
    * Browse on the location `<Install Directory>/Cypress/Superspeed Explorer Kit/1.0/Driver/bin`. The default 'Install Directory' is `C:\Program Files` for 32-bit OS and `C:\Program Files (x86)` for 64-bit OS.
    * Select a driver based on your OS and click on Next. For ex. the driver for Win10 64-bit is located at `C:/Program Files (x86)/Cypress/Superspeed Explorer Kit/1.0/Driver/bin/Win8.1/x64`.
 - If the following message appears **"FX3 - Xilinx Slave Serial Programmer detected"**. Check the J4 jumper is connected.

    <p align="center">
    <img src="/img/fpga_prog/Image1.png" width="300"/>
    </p>

3. Click on "Download Firmware" and select the firmware: `ConfigFpgaSlaveFifoSync.img` located on `FX3 Firmware\ConfigFpgaSlaveFifoSync\Release`.
<p align="center">
<img src="/img/fpga_prog/Config_Program_Steps/Image4.png" width="400"/>
</p>
4. Click on "Select Bitstream" and search for your bin file you want to upload to the board.
  - To generate a bin file with ISE instead of the bit file refer to: [Convert bit to bin](https://electronics.stackexchange.com/questions/407801/convert-bit-to-bin-xilinx-file).
5. Power up the FPGA.
6. Select the "Configure" button.
<p align="center">
<img src="/img/fpga_prog/Config_Program_Steps/Image5.png" width="400"/>
</p>
7. Done! The following screen should appear and you must have the following result:
<p align="center">
<img src="/img/fpga_prog/Config_Program_Steps/Image7.png" width="400"/>
</p>

### 4.3 debugging via UART

The programming firmware was modified to print debugging messages over a UART interface using GPIO[46..49] of the FX3 device.
To see those messages you must connect those pins to a UART device and use a program like *putty* or *Tera Term* to display the messages in question.

Example of *Tera Term* screen:
```
Firmware version modified by J. Agustin Barrachina:
Warning: USB 2.0 HIGH SPEED detected.
        Consider connecting the board to a USB3 interface for better performance
Vendor Request received: B2
        bReqType: 40
        bType: 40
        bTarget: 0
        bRequest: B2
        wValue: 0
        wIndex: 1
        wLength: 16
    VND_CMD_SLAVESER_CFGLOAD
    filelen = 1484404
Start Configuration of FPGA
Standard Request received: B
         bReqType: 1
         bType: 0
         bTarget: 1
         bRequest: B
         wValue: 0
         wIndex: 0
         wLength: 0

 1. Pulling PROG_B line to reset FPGA
 2. Releasing PROG_B line
 3. Checking FPGA_Init_B to know if FPGA is ready.
 4. Start shifting configuration data...
 5. Checking DONE signal
FPGA was programmed successfully. Status code = 0
  Data tracker: buffers received: 0, buffers sent: 0.
```

## 5. Program and communicate with the FPGA

To do both program and communicate with the FPGA, just follow the steps of section [4.2. Programming Steps](#4.2.-programming-steps) but when selecting the Bitstream one must choose the following `CYUSB3KIT-003_with_SP605_xilinx\com_fpga\FPGA_firmware\slaveFIFO2b_fpga_top.bin`. After successfully programming the FPGA, open *Control Center* program and follow the images that follows.

<p align="center">
<img src="/img/prog_com/Image6.5.png" width="400"/>
</p>

<p align="center">
<img src="/img/prog_com/Image7.png" width="400"/>
</p>

<p align="center">
<img src="/img/prog_com/Image8.png" width="400"/>
</p>

<p align="center">
<img src="/img/prog_com/Image8.5.png" width="400"/>
</p>

<p align="center">
<img src="/img/prog_com/Image9.png" width="400"/>
</p>

## 6. cpp Class for communicating with FX3

Inside [testing_cpp_code](https://github.com/NEGU93/CYUSB3KIT-003_with_SP605_xilinx/tree/master/testing_cpp_code) there's a project that enables communication with the PC with the FX3. It performs download of firmware, programs the FPGA, prints descriptions and run performance tests between other things.

If you run the code it automatically programs the FX3 devices. It waits for the user to turn on the FPGA and press enter.
Then it programs the FPGA.

## 7. Citations

I would like to know if this explanations or code was useful to somebody so if it's the case let me know (star the project for ex.)
Just use this as you need!

## Note:
This project is still under development. It started on Nov 2018.
