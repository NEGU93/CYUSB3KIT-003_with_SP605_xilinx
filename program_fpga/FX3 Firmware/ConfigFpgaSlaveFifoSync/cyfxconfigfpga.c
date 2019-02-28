/*
 * cyfxconfigfpga.c
 *
 *  Created on: Nov 26, 2012
 *      Author: rskv
 *  Edited on: Jan 2019
 *  	Author: Negu - Mimac - CNRS
 */

#include "cyu3system.h"
#include "cyu3os.h"
#include "cyu3dma.h"
#include "cyu3error.h"
#include "cyu3usb.h"
#include "cyu3gpio.h"
#include "cyu3spi.h"
#include "cyu3uart.h"
#include "cyfxslfifosync.h"
#include "cyu3gpif.h"
#include "cyu3pib.h"
#include "pib_regs.h"
#include "cyfxconfigfpga.h"

/* This file illustrates the configure FPGA in Slave Serial mode example */
CyU3PDmaChannel glChHandleUtoCPU;   	/* DMA Channel handle for U2CPU transfer. */
CyBool_t glConfigDone = CyTrue;			/* Flag to indicate that FPGA configuration is done */
uint32_t filelen = 0;					/* length of Configuration file (.bin) */
CyU3PEvent glFxConfigFpgaAppEvent;    	/* Configure FPGA event group. */
uint16_t uiPacketSize = 0;

/* This function writes configuration data to the xilinx FPGA */
CyU3PReturnStatus_t CyFxConfigFpga(uint32_t uiLen) {
      uint32_t uiIdx;

      CyU3PReturnStatus_t apiRetStatus;
      CyU3PDmaBuffer_t inBuf_p;
      CyBool_t xFpga_Done, xFpga_Init_B;

      CyU3PDebugPrint (6, "\r\tfile length: %d\r\n", uiLen);

      /* Checking PROG_B signal */
      CyU3PGpioSimpleGetValue(FPGA_INIT_B, &xFpga_Init_B);
      if (!xFpga_Init_B) {
    	  CyU3PDebugPrint(CY_FX_DEBUG_PRIORITY, "\rERROR: FPGA_Init_B down. Is the FPGA on?\r\n");
          glConfigDone = CyFalse;
          return apiRetStatus;
      }

      /* Pull PROG_B line to reset FPGA */
      CyU3PDebugPrint (CY_FX_DEBUG_PRIORITY, "\r 1. Pulling PROG_B line to reset FPGA\r\n");
      apiRetStatus = CyU3PSpiSetSsnLine (CyFalse);

      //CyU3PGpioSimpleGetValue (FPGA_INIT_B, &xFpga_Init_B);	// TODO: 2 times this line?
      CyU3PGpioSimpleGetValue(FPGA_INIT_B, &xFpga_Init_B);
      if (xFpga_Init_B) {
    	  CyU3PDebugPrint(CY_FX_DEBUG_PRIORITY, "\rERROR: FPGA_Init_B was not reseted. Error code = %d\r\n", apiRetStatus);
    	  glConfigDone = CyFalse;
          return apiRetStatus;
      }
      CyU3PThreadSleep(10);
      /* Release PROG_B line */
      CyU3PDebugPrint (CY_FX_DEBUG_PRIORITY, "\r 2. Releasing PROG_B line\r\n");
      apiRetStatus |= CyU3PSpiSetSsnLine (CyTrue);
      CyU3PThreadSleep(10);   // Allow FPGA to startup

      /* Check if FPGA is now ready by testing the FPGA_Init_B signal */
      CyU3PDebugPrint(CY_FX_DEBUG_PRIORITY, "\r 3. Checking FPGA_Init_B to know if FPGA is ready.\r\n");
      apiRetStatus |= CyU3PGpioSimpleGetValue (FPGA_INIT_B, &xFpga_Init_B);
      if( (xFpga_Init_B != CyTrue) || (apiRetStatus != CY_U3P_SUCCESS) ){
    	  CyU3PDebugPrint(CY_FX_DEBUG_PRIORITY, "\rERROR: FPGA not ready. Error code = %d\r\n", apiRetStatus);
          return apiRetStatus;
      }

      /* Start shifting out configuration data */
      CyU3PDebugPrint(CY_FX_DEBUG_PRIORITY, "\r 4. Start shifting configuration data...\r\n");
      for(uiIdx = 0; (uiIdx < uiLen) && glIsApplnActive; uiIdx += uiPacketSize ){
    	  apiRetStatus = CyU3PDmaChannelGetBuffer(&glChHandleUtoCPU, &inBuf_p, 2000);	// Get data from CPU
    	  if(apiRetStatus != CY_U3P_SUCCESS){ // Wait 2000 ms(?)
    		  glConfigDone = CyFalse;
    		  if(apiRetStatus == CY_U3P_ERROR_TIMEOUT) {
    			  CyU3PDebugPrint(CY_FX_DEBUG_PRIORITY, "\rERROR: Timeout waiting for FPGA's firmware from CPU. Error code = %d\r\n", apiRetStatus);
    		  }
    		  else {
    			  CyU3PDebugPrint(CY_FX_DEBUG_PRIORITY, "\rError getting the FPGA's firmware. Error code = %d\r\n", apiRetStatus);
    		  }
    		  //break;
    		  return apiRetStatus;
    	  }

    	  apiRetStatus = CyU3PSpiTransmitWords(inBuf_p.buffer , uiPacketSize);	// Send data to FPGA
    	  if (apiRetStatus != CY_U3P_SUCCESS){
    		  glConfigDone = CyFalse;
    		  CyU3PDebugPrint(CY_FX_DEBUG_PRIORITY, "\r\tFailed to send data to FPGA. Error code = %d\r\n", apiRetStatus);
    		  //break;
    		  return apiRetStatus;
    	  }
          if(CyU3PDmaChannelDiscardBuffer(&glChHandleUtoCPU) != CY_U3P_SUCCESS){ // Wait 2000 ms(?)
        	  glConfigDone = CyFalse;
        	  apiRetStatus = CY_U3P_ERROR_TIMEOUT;
        	  CyU3PDebugPrint(CY_FX_DEBUG_PRIORITY, "\rERROR: Timeout discarding buffer. Error code = %d\r\n", apiRetStatus);
        	  //break;
        	  return apiRetStatus;
          }
      }
      CyU3PThreadSleep(1);
      CyU3PDebugPrint (CY_FX_DEBUG_PRIORITY, "\r 4. Checking DONE signal\r\n");
      apiRetStatus |= CyU3PGpioSimpleGetValue (FPGA_DONE, &xFpga_Done);
      if( (xFpga_Done != CyTrue) ){
    	  glConfigDone = CyFalse;
    	  apiRetStatus = CY_U3P_ERROR_FAILURE;
    	  CyU3PDebugPrint(CY_FX_DEBUG_PRIORITY, "\rERROR: FPGA_DONE signal. Error code = %d\r\n", apiRetStatus);
      }
      if (apiRetStatus == CY_U3P_SUCCESS) {
    	  CyU3PDebugPrint(CY_FX_DEBUG_PRIORITY, "\rFPGA was programmed successfully. Status code = %d\r\n", apiRetStatus);
      }
      else {
    	  CyU3PDebugPrint(CY_FX_DEBUG_PRIORITY, "\rFPGA configuration failed. Status code = %d\r\n", apiRetStatus);
      }
      return apiRetStatus;
}

/*
 * CyFxConfigFpgaApplnStart:
 * Endpoint configuration for USB transfers and
 * DMA channel configuration for data transfers
 * from USB block to SPI block of FX3.
 * */
void CyFxConfigFpgaApplnStart (void) {
    uint16_t size = 0;
    CyU3PEpConfig_t epCfg;
    CyU3PDmaChannelConfig_t dmaCfg;
    CyU3PReturnStatus_t apiRetStatus = CY_U3P_SUCCESS;
    CyU3PUSBSpeed_t usbSpeed = CyU3PUsbGetSpeed();
    CyU3PDebugPrint (1, "\rFirmware version modified by J. Agustin Barrachina: \r\n");
    /* First identify the usb speed. Once that is identified,
     * create a DMA channel and start the transfer on this. */
    /* Based on the Bus Speed configure the endpoint packet size */
    switch (usbSpeed) {
        case CY_U3P_FULL_SPEED:
        	CyU3PDebugPrint(6, "\rWarning: USB 2.0 FULL SPEED detected.\n\r\tConsider connecting the board to a USB3 interface for better performance\r\n");
            size = 64;
            break;

        case CY_U3P_HIGH_SPEED:
        	CyU3PDebugPrint(6, "\rWarning: USB 2.0 HIGH SPEED detected.\n\r\tConsider connecting the board to a USB3 interface for better performance\r\n");
            size = 512;
            break;

        case  CY_U3P_SUPER_SPEED:
        	CyU3PDebugPrint(6, "\rUSB 3.0 SUPER SPEED detected\r\n");
            size = 1024;
            break;

        default:
            CyU3PDebugPrint (4, "\rError! Invalid USB speed.\r\n");
            CyFxAppErrorHandler (CY_U3P_ERROR_FAILURE);
            break;
    }

    CyU3PMemSet ((uint8_t *)&epCfg, 0, sizeof (epCfg));
    epCfg.enable = CyTrue;
    epCfg.epType = CY_U3P_USB_EP_BULK;
    epCfg.burstLen = 1;
    epCfg.streams = 0;
    epCfg.pcktSize = size;

    uiPacketSize = size;

    /* Producer endpoint configuration */
    apiRetStatus = CyU3PSetEpConfig(CY_FX_EP_PRODUCER, &epCfg);
    if (apiRetStatus != CY_U3P_SUCCESS) {
        CyU3PDebugPrint (CY_FX_DEBUG_PRIORITY, "\rCyU3PSetEpConfig failed, Error code = %d\r\n", apiRetStatus);
        CyFxAppErrorHandler (apiRetStatus);
    }

    /* Create a DMA MANUAL channel for U2CPU transfer.
     * DMA size is set based on the USB speed. */
    dmaCfg.size  = size;
    dmaCfg.count = CY_FX_SLFIFO_DMA_BUF_COUNT;
    dmaCfg.prodSckId = CY_FX_PRODUCER_USB_SOCKET;
    dmaCfg.consSckId = CY_U3P_CPU_SOCKET_CONS;
    dmaCfg.dmaMode = CY_U3P_DMA_MODE_BYTE;
    /* Enabling the callback for produce event. */
    dmaCfg.notification = 0;
    dmaCfg.cb = NULL;
    dmaCfg.prodHeader = 0;
    dmaCfg.prodFooter = 0;
    dmaCfg.consHeader = 0;
    dmaCfg.prodAvailCount = 0;

    apiRetStatus = CyU3PDmaChannelCreate(&glChHandleUtoCPU, CY_U3P_DMA_TYPE_MANUAL_IN, &dmaCfg);
    if (apiRetStatus != CY_U3P_SUCCESS) {
        CyU3PDebugPrint (CY_FX_DEBUG_PRIORITY, "\rCyU3PDmaChannelCreate failed, Error code = %d\r\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* Flush the Endpoint memory */
    CyU3PUsbFlushEp(CY_FX_EP_PRODUCER);

    /* Set DMA channel transfer size. */
    apiRetStatus = CyU3PDmaChannelSetXfer (&glChHandleUtoCPU, CY_FX_SLFIFO_DMA_TX_SIZE);
    if (apiRetStatus != CY_U3P_SUCCESS) {
        CyU3PDebugPrint (CY_FX_DEBUG_PRIORITY, "\rCyU3PDmaChannelSetXfer Failed, Error code = %d\r\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* Update the status flag. */
    glIsApplnActive = CyTrue;
}

/*
 * CyFxConfigFpgaApplnStop:
 * De-initializes the FX3 GPIO and SPI modules
 * to allow reconfiguration of the I/O matrix.
 * */
void CyFxConfigFpgaApplnStop (void) {
	CyU3PEpConfig_t epCfg;
	CyU3PReturnStatus_t apiRetStatus = CY_U3P_SUCCESS;


	CyU3PGpioDeInit();
	CyU3PSpiDeInit();

    /* Update the flag. */
    glIsApplnActive = CyFalse;

    CyU3PUsbGetEpSeqNum(CY_FX_EP_PRODUCER, &seqnum_p);

    /* Flush the endpoint memory */
    CyU3PUsbFlushEp(CY_FX_EP_PRODUCER);


    /* Destroy the channel */
    CyU3PDmaChannelDestroy(&glChHandleUtoCPU);
#if 0
    /* Disable endpoints. */
	CyU3PMemSet ((uint8_t *)&epCfg, 0, sizeof (epCfg));
	epCfg.enable = CyFalse;

        /* Producer endpoint configuration. */
	apiRetStatus = CyU3PSetEpConfig(CY_FX_EP_PRODUCER, &epCfg);
	if (apiRetStatus != CY_U3P_SUCCESS)
	{
		CyU3PDebugPrint (4, "\rCyU3PSetEpConfig failed, Error code = %d\r\n", apiRetStatus);
		CyFxAppErrorHandler (apiRetStatus);
	}
#endif
}

/*
 * CyFxConfigFpgaApplnInit:
 * 		1. Initializes the FX3 GPIO and SPI modules.
 * 		2. Configure GPIO[50] and GPIO[52] as input signals.
 * 		3. Initializes the FX3 USB block for enumeration.
 * */
void CyFxConfigFpgaApplnInit (void){
	CyU3PGpioClock_t gpioClock;
    CyU3PGpioSimpleConfig_t gpioConfig;
    CyU3PSpiConfig_t spiConfig;
    CyU3PReturnStatus_t apiRetStatus = CY_U3P_SUCCESS;

    apiRetStatus = CyU3PEventCreate(&glFxConfigFpgaAppEvent);
    if (apiRetStatus != CY_U3P_SUCCESS)	{
    	CyU3PDebugPrint (CY_FX_DEBUG_PRIORITY, "\rEvent create failed, Error Code = %d\r\n",apiRetStatus);
	}

    /* Start the SPI module and configure the master. */
    apiRetStatus = CyU3PSpiInit();
    if (apiRetStatus != CY_U3P_SUCCESS) {
    	CyU3PDebugPrint (CY_FX_DEBUG_PRIORITY, "\rSPI init failed, Error Code = %d\r\n",apiRetStatus);
    }

    /* Start the SPI master block. Run the SPI clock at 25MHz
     * and configure the word length to 8 bits. Also configure
     * the slave select using FW. */
    CyU3PMemSet ((uint8_t *)&spiConfig, 0, sizeof(spiConfig));
    spiConfig.isLsbFirst = CyFalse;
    spiConfig.cpol       = CyTrue;
    spiConfig.ssnPol     = CyFalse;
    spiConfig.cpha       = CyTrue;
    spiConfig.leadTime   = CY_U3P_SPI_SSN_LAG_LEAD_HALF_CLK;
    spiConfig.lagTime    = CY_U3P_SPI_SSN_LAG_LEAD_HALF_CLK;
    spiConfig.ssnCtrl    = CY_U3P_SPI_SSN_CTRL_FW;
    spiConfig.clock      = 25000000;
    spiConfig.wordLen    = 8;

    apiRetStatus = CyU3PSpiSetConfig (&spiConfig, NULL);
    if (apiRetStatus != CY_U3P_SUCCESS) {
    	CyU3PDebugPrint (CY_FX_DEBUG_PRIORITY, "\rSPI config failed, Error Code = %d\r\n",apiRetStatus);
    }

    /******************/
    /* Configure GPIO */
    /******************/

    /* Init the GPIO module */
    gpioClock.fastClkDiv = 2;
    gpioClock.slowClkDiv = 0;
    gpioClock.simpleDiv = CY_U3P_GPIO_SIMPLE_DIV_BY_2;
    gpioClock.clkSrc = CY_U3P_SYS_CLK;
    gpioClock.halfDiv = 0;

    /* Initialize Gpio interface */
    apiRetStatus = CyU3PGpioInit(&gpioClock, NULL);
    if (apiRetStatus != 0) {
    	/* Error Handling */
    	CyU3PDebugPrint (4, "\rGPIO Init failed, Error Code = %d\r\n",apiRetStatus);
    	CyFxAppErrorHandler(apiRetStatus);
    }

    /* Configure GPIO 52 as input */
    gpioConfig.outValue = CyTrue;
    gpioConfig.inputEn = CyTrue;
    gpioConfig.driveLowEn = CyFalse;
    gpioConfig.driveHighEn = CyFalse;
    gpioConfig.intrMode = CY_U3P_GPIO_INTR_BOTH_EDGE;
    apiRetStatus = CyU3PGpioSetSimpleConfig(FPGA_INIT_B, &gpioConfig);
    if (apiRetStatus != CY_U3P_SUCCESS) {
    	/* Error handling */
    	CyU3PDebugPrint (4, "\rCyU3PGpioSetSimpleConfig failed, error code = %d\r\n", apiRetStatus);
    	CyFxAppErrorHandler(apiRetStatus);
    }

    /* Configure GPIO 50 as input with interrupt enabled for both edges */
    apiRetStatus = CyU3PGpioSetSimpleConfig(FPGA_DONE, &gpioConfig);
    if (apiRetStatus != CY_U3P_SUCCESS) {
    	/* Error handling */
    	CyU3PDebugPrint (4, "\rCyU3PGpioSetSimpleConfig failed, error code = %d\r\n", apiRetStatus);
    	CyFxAppErrorHandler(apiRetStatus);
    }


    /************************/
    /* Configure GPIO end	*/
    /************************/

    /* Start the USB functionality. */
    apiRetStatus = CyU3PUsbStart();
    if (apiRetStatus != CY_U3P_SUCCESS) {
    	CyU3PDebugPrint (4, "\rCyU3PUsbStart failed to Start, Error code = %d\r\n", apiRetStatus);
    	CyFxAppErrorHandler(apiRetStatus);
    }

    /* The fast enumeration is the easiest way to setup a USB connection,
     * where all enumeration phase is handled by the library. Only the
     * class / vendor requests need to be handled by the application. */
    CyU3PUsbRegisterSetupCallback(CyFxSlFifoApplnUSBSetupCB, CyTrue);

    /* Setup the callback to handle the USB events. */
    CyU3PUsbRegisterEventCallback(CyFxSlFifoApplnUSBEventCB);

    /* Register a callback to handle LPM requests from the USB 3.0 host. */
    CyU3PUsbRegisterLPMRequestCallback(CyFxApplnLPMRqtCB);

    /* Set the USB Enumeration descriptors */

    /* Super speed device descriptor. */
    apiRetStatus = CyU3PUsbSetDesc(CY_U3P_USB_SET_SS_DEVICE_DESCR, NULL, (uint8_t *)CyFxUSB30DeviceDscr);
    if (apiRetStatus != CY_U3P_SUCCESS) {
        CyU3PDebugPrint (4, "\rUSB set device descriptor failed, Error code = %d\r\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* High speed device descriptor. */
    apiRetStatus = CyU3PUsbSetDesc(CY_U3P_USB_SET_HS_DEVICE_DESCR, NULL, (uint8_t *)CyFxUSB20DeviceDscr);
    if (apiRetStatus != CY_U3P_SUCCESS) {
        CyU3PDebugPrint (4, "\rUSB set device descriptor failed, Error code = %d\r\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* BOS descriptor */
    apiRetStatus = CyU3PUsbSetDesc(CY_U3P_USB_SET_SS_BOS_DESCR, NULL, (uint8_t *)CyFxUSBBOSDscr);
    if (apiRetStatus != CY_U3P_SUCCESS) {
        CyU3PDebugPrint (4, "\rUSB set configuration descriptor failed, Error code = %d\r\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* Device qualifier descriptor */
    apiRetStatus = CyU3PUsbSetDesc(CY_U3P_USB_SET_DEVQUAL_DESCR, NULL, (uint8_t *)CyFxUSBDeviceQualDscr);
    if (apiRetStatus != CY_U3P_SUCCESS) {
        CyU3PDebugPrint (4, "\rUSB set device qualifier descriptor failed, Error code = %d\r\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* Super speed configuration descriptor */
    apiRetStatus = CyU3PUsbSetDesc(CY_U3P_USB_SET_SS_CONFIG_DESCR, NULL, (uint8_t *)CyFxUSBSSConfigDscr);
    if (apiRetStatus != CY_U3P_SUCCESS) {
        CyU3PDebugPrint (4, "\rUSB set configuration descriptor failed, Error code = %d\r\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* High speed configuration descriptor */
    apiRetStatus = CyU3PUsbSetDesc(CY_U3P_USB_SET_HS_CONFIG_DESCR, NULL, (uint8_t *)CyFxUSBHSConfigDscr);
    if (apiRetStatus != CY_U3P_SUCCESS) {
        CyU3PDebugPrint (4, "\rUSB Set Other Speed Descriptor failed, Error Code = %d\r\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* Full speed configuration descriptor */
    apiRetStatus = CyU3PUsbSetDesc(CY_U3P_USB_SET_FS_CONFIG_DESCR, NULL, (uint8_t *)CyFxUSBFSConfigDscr);
    if (apiRetStatus != CY_U3P_SUCCESS) {
        CyU3PDebugPrint (4, "\rUSB Set Configuration Descriptor failed, Error Code = %d\r\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* String descriptor 0 */
    apiRetStatus = CyU3PUsbSetDesc(CY_U3P_USB_SET_STRING_DESCR, 0, (uint8_t *)CyFxUSBStringLangIDDscr);
    if (apiRetStatus != CY_U3P_SUCCESS) {
        CyU3PDebugPrint (4, "\rUSB set string descriptor failed, Error code = %d\r\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* String descriptor 1 */
    apiRetStatus = CyU3PUsbSetDesc(CY_U3P_USB_SET_STRING_DESCR, 1, (uint8_t *)CyFxUSBManufactureDscr);
    if (apiRetStatus != CY_U3P_SUCCESS) {
        CyU3PDebugPrint (4, "\rUSB set string descriptor failed, Error code = %d\r\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* String descriptor 2 */
    apiRetStatus = CyU3PUsbSetDesc(CY_U3P_USB_SET_STRING_DESCR, 2, (uint8_t *)CyFxUSBProductDscr);
    if (apiRetStatus != CY_U3P_SUCCESS) {
        CyU3PDebugPrint (4, "\rUSB set string descriptor failed, Error code = %d\r\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* Connect the USB Pins with super speed operation enabled. */
    apiRetStatus = CyU3PConnectState(CyTrue, CyTrue);
    if (apiRetStatus != CY_U3P_SUCCESS) {
        CyU3PDebugPrint (4, "\rUSB Connect failed, Error code = %d\r\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }
}

/*-------------------------------------------------------------*/
int main (void) {
    CyU3PIoMatrixConfig_t io_cfg;
    CyU3PReturnStatus_t status = CY_U3P_SUCCESS;
    CyU3PSysClockConfig_t clkCfg;

    /* setSysClk400 clock configurations */
    clkCfg.setSysClk400 = CyTrue;   /* FX3 device's master clock is set to a frequency > 400 MHz */
    clkCfg.cpuClkDiv = 2;           /* CPU clock divider */
    clkCfg.dmaClkDiv = 2;           /* DMA clock divider */
    clkCfg.mmioClkDiv = 2;          /* MMIO clock divider */
    clkCfg.useStandbyClk = CyFalse; /* device has no 32KHz clock supplied */
    clkCfg.clkSrc = CY_U3P_SYS_CLK; /* Clock source for a peripheral block  */

    /* Initialize the device */
    status = CyU3PDeviceInit (&clkCfg);
    if (status != CY_U3P_SUCCESS) {
        goto handle_fatal_error;
    }

    /* Initialize the caches. Enable instruction cache and keep data cache disabled.
     * The data cache is useful only when there is a large amount of CPU based memory
     * accesses. When used in simple cases, it can decrease performance due to large
     * number of cache flushes and cleans and also it adds to the complexity of the
     * code. */
    status = CyU3PDeviceCacheControl (CyTrue, CyFalse, CyFalse);
    if (status != CY_U3P_SUCCESS) {
        goto handle_fatal_error;
    }

    /* Configure the IO matrix for the device. On the FX3 DVK board, the COM port
     * is connected to the IO(53:56). This means that either DQ32 mode should be
     * selected or lppMode should be set to UART_ONLY. Here we are choosing
     * UART_ONLY configuration for 16 bit slave FIFO configuration and setting
     * isDQ32Bit for 32-bit slave FIFO configuration. */
    io_cfg.useUart   = CyTrue;
    io_cfg.useI2C    = CyFalse;
    io_cfg.useI2S    = CyFalse;
    io_cfg.useSpi    = CyTrue;
    io_cfg.isDQ32Bit = CyFalse;
    io_cfg.lppMode   = CY_U3P_IO_MATRIX_LPP_DEFAULT;
    /* GPIOs 50 and 52 are enabled. */
    io_cfg.gpioSimpleEn[0]  = 0x00000000;
    io_cfg.gpioSimpleEn[1]  = 0x00140000;
    io_cfg.gpioComplexEn[0] = 0;
    io_cfg.gpioComplexEn[1] = 0;
    status = CyU3PDeviceConfigureIOMatrix (&io_cfg);
    if (status != CY_U3P_SUCCESS) {
        goto handle_fatal_error;
    }

    /* This is a non returnable call for initializing the RTOS kernel */
    CyU3PKernelEntry ();

    // Should not get here NEVER
    return 0;
    handle_fatal_error:
    /* Cannot recover from this error. */
    while (1);
}

