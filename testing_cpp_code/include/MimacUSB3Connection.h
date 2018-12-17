//
// Created by barrachina on 12/13/18.
//

#ifndef TESTING_CPP_CODE_MIMACUSB3CONNECTION_H
#define TESTING_CPP_CODE_MIMACUSB3CONNECTION_H

#include <cstdio>
#include <stdlib.h> // strol, calloc, free
#include "../include/cyusb.h"

using namespace std;

#define MAX_FWIMG_SIZE		(512 * 1024)    // Maximum size of the firmware binary.
#define MAX_WRITE_SIZE		(2 * 1024)      // Max. size of data that can be written through one vendor command.

#define VENDORCMD_TIMEOUT	(5000)		    // Timeout (in milliseconds) for each vendor command.

#define GET_LSW(v)	((unsigned short)((v) & 0xFFFF))	// Get Least Significant Word part of an integer.
#define GET_MSW(v)	((unsigned short)((v) >> 16))		// Get Most Significant Word part of an integer.

class ErrorOpeningLib : public exception {
public:
    char * what () {
        return const_cast<char *>("Error Opening Library");
    }
};

class NoDeviceFound : public exception {
public:
    char * what () {
        return const_cast<char *>("No Device Found");
    }
};

/* Enumeration representing the FX3 firmware target. */
typedef enum {
    FW_TARGET_NONE = 0,	// Invalid value
    FW_TARGET_RAM,		// Program to device RAM
    FW_TARGET_I2C,		// Program to I2C EEPROM
    FW_TARGET_SPI		// Program to SPI Flash
} fx3_fw_target;

/* Array representing physical size of EEPROM corresponding to each size encoding. */
const int i2c_eeprom_size[] =
        {
                1024,		// bImageCtl[2:0] = 'b000
                2048,		// bImageCtl[2:0] = 'b001
                4096,		// bImageCtl[2:0] = 'b010
                8192,		// bImageCtl[2:0] = 'b011
                16384,		// bImageCtl[2:0] = 'b100
                32768,		// bImageCtl[2:0] = 'b101
                65536,		// bImageCtl[2:0] = 'b110
                131072		// bImageCtl[2:0] = 'b111
        };

class MimacUSB3Connection {
public:

    MimacUSB3Connection();
    MimacUSB3Connection(bool user_input, unsigned short vid, unsigned short pid);
    ~MimacUSB3Connection();


    int print_device_descriptor();
    int print_config_descriptor();
    int claim_interface(int interface);
    int download_fx3_firmware(char *filename, char *tgt_str);
    int test_performance();

private:
    //! Variables
    int rStatus;
    unsigned short vid;
    unsigned short pid;
    FILE *fp;

    struct libusb_device_descriptor deviceDesc{};
    struct libusb_config_descriptor *configDesc;
    libusb_interface_descriptor *interfaceDesc;
    libusb_endpoint_descriptor *endpointDesc;
    libusb_ss_endpoint_companion_descriptor *companionDesc;

    static cyusb_handle *device_handle;

    // Transfer Performance
    static unsigned int endpoint;   //= 129;	// Endpoint to be tested
    static unsigned int reqsize;    //= 16;	// Request size in number of packets
    static unsigned int queuedepth; //= 16;	// Number of requests to queue
    static unsigned int duration;   //= 100;	// Duration of the test in seconds

    static unsigned char eptype;		// Type of endpoint (transfer type)
    static unsigned int pktsize;		// Maximum packet size for the endpoint

    static bool	stop_transfers;	        // Request to stop data transfers
    static int	rqts_in_flight;	        // Number of transfers that are in progress

    static unsigned int success_count;	    // Number of successful transfers
    static unsigned int failure_count;	    // Number of failed transfers
    static unsigned int transfer_size;	    // Size of data transfers performed so far
    static unsigned int transfer_index;	    // Write index into the transfer_size array

    static struct timeval	start_ts;	// Data transfer start time stamp.
    static struct timeval	end_ts;		// Data transfer stop time stamp.

    //! Methods
    int get_device_descriptor();
    int get_device_config();

    // Program FX3 functions
    int fx3_usbboot_download(const char *filename);
    int read_firmware_image (const char *filename, unsigned char *buf, int *romsize, int *filesize);
    int fx3_ram_write (unsigned char *buf, unsigned int ramAddress, unsigned short len);
    // Test performance
    void free_transfer_buffers(unsigned char **databuffers, struct libusb_transfer **transfers, unsigned int queuedepth);
    static void xfer_callback (struct libusb_transfer *transfer);
};


#endif //TESTING_CPP_CODE_MIMACUSB3CONNECTION_H
