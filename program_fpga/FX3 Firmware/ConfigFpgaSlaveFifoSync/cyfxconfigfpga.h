/*
 * cyfxconfigfpga.h
 *
 *  Created on: Nov 26, 2012
 *      Author: rskv
 */

#ifndef CYFXCONFIGFPGA_H_
#define CYFXCONFIGFPGA_H_

/*This file contains the constants and definitions used by the Configure FPGA application example */
// Priority Levels
#define CY_FX_DEBUG_PRIORITY			(4)							/* Sets the debug print priority level */

//Slave Serial Application FW specific defines
#define CY_FX_SLFIFO_DMA_BUF_COUNT      (16)                       /* Slave FIFO channel U to CPU buffer count */
#define FPGA_INIT_B 52
#define FPGA_DONE 50

//Vendor command code used in FPGA slave serial application
#define VND_CMD_SLAVESER_CFGLOAD 0xB2
#define VND_CMD_SLAVESER_CFGSTAT 0xB1

//Events
#define CY_FX_CONFIGFPGAAPP_START_EVENT    (1 << 0)   			/* event to initiate FPGA configuration */
#define CY_FX_CONFIGFPGAAPP_SW_TO_SLFIFO_EVENT     (1 << 1)   			/* event to initiate switch back to slave FIFO*/

extern CyU3PDmaChannel glChHandleUtoCPU;   	/* DMA Channel handle for U2CPU transfer. */
extern CyBool_t glConfigDone;				/* Flag to indicate the status of FPGA configuration  */
extern uint32_t filelen;					/* length of Configuration file (.bin) */
extern uint16_t uiPacketSize;
extern volatile CyBool_t glIsApplnActive;
extern CyU3PEvent glFxConfigFpgaAppEvent;    /* Configure FPGA event group. */
extern uint8_t *seqnum_p;

extern void CyFxAppErrorHandler(CyU3PReturnStatus_t apiRetStatus /* API return status */);
extern CyBool_t CyFxSlFifoApplnUSBSetupCB(uint32_t setupdat0, uint32_t setupdat1);
extern void CyFxSlFifoApplnUSBEventCB(CyU3PUsbEventType_t evtype, uint16_t evdata);
extern CyBool_t CyFxApplnLPMRqtCB(CyU3PUsbLinkPowerMode link_mode);
extern void CyFxConfigFpgaApplnStart(void);
extern void CyFxConfigFpgaApplnInit (void);
extern CyU3PReturnStatus_t CyFxConfigFpga(uint32_t uiLen);
extern void CyFxConfigFpgaApplnStop(void);


#endif /* CYFXCONFIGFPGA_H_ */
