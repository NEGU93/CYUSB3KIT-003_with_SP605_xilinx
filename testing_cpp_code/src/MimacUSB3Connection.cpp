//
// Created by barrachina on 12/13/18.
//

#include <exception>
#include <zconf.h>
#include <pthread.h>
#include <cstring>
#include <cerrno>
#include <sys/stat.h>
#include <fcntl.h>
#include "../include/MimacUSB3Connection.h"

//#define DEBUG

cyusb_handle *MimacUSB3Connection::device_handle;

unsigned int MimacUSB3Connection::endpoint;   //= 129;	// Endpoint to be tested
unsigned int MimacUSB3Connection::reqsize;    //= 16;	// Request size in number of packets
unsigned int MimacUSB3Connection::queuedepth; //= 16;	// Number of requests to queue
unsigned int MimacUSB3Connection::duration;   //= 100;	// Duration of the test in seconds

unsigned char MimacUSB3Connection::eptype;		// Type of endpoint (transfer type)
unsigned int MimacUSB3Connection::pktsize;		// Maximum packet size for the endpoint

bool	MimacUSB3Connection::stop_transfers;	        // Request to stop data transfers
int		MimacUSB3Connection::rqts_in_flight;	    // Number of transfers that are in progress

unsigned int MimacUSB3Connection::success_count;	    // Number of successful transfers
unsigned int MimacUSB3Connection::failure_count;	    // Number of failed transfers
unsigned int MimacUSB3Connection::transfer_size;	    // Size of data transfers performed so far
unsigned int MimacUSB3Connection::transfer_index;	    // Write index into the transfer_size array

struct timeval	MimacUSB3Connection::start_ts;	// Data transfer start time stamp.
struct timeval	MimacUSB3Connection::end_ts;		// Data transfer stop time stamp.


MimacUSB3Connection::MimacUSB3Connection() {
    fp = stdout;
    rStatus = cyusb_open();
    if ( rStatus < 0 ) { throw ErrorOpeningLib(); }
    else if ( rStatus == 0 ) { throw NoDeviceFound(); }
}

MimacUSB3Connection::MimacUSB3Connection(bool user_input, unsigned short vid, unsigned short pid) : vid(vid), pid(pid) {
    fp = stdout;
    if ( user_input ) { rStatus = cyusb_open(vid, pid); }
    else { rStatus = cyusb_open(); }
    if ( rStatus < 0 ) { throw ErrorOpeningLib(); }
    else if ( rStatus == 0 ) { throw NoDeviceFound(); }
}

MimacUSB3Connection::~MimacUSB3Connection() {
    cyusb_close();
}

/**
 * dump out the device descriptor for any USB device given its
 * VID/PID. The program itself accepts options : Either vid/pid on the command line OR first
 * VID/PID of interest in cyusb.conf
 * */
int MimacUSB3Connection::get_device_descriptor() {
    rStatus = cyusb_get_device_descriptor(cyusb_gethandle(0), &deviceDesc);
    if ( rStatus ) {
        printf("error getting device descriptor\n");
        return -2;
    }
    return rStatus;
}
int MimacUSB3Connection::print_device_descriptor(){
    if(!get_device_descriptor()) {
        fprintf(fp, "bLength             = %d\n", deviceDesc.bLength);
        fprintf(fp, "bDescriptorType     = %d\n", deviceDesc.bDescriptorType);
        fprintf(fp, "bcdUSB              = 0x%04x\n", deviceDesc.bcdUSB);
        fprintf(fp, "bDeviceClass        = 0x%02x\n", deviceDesc.bDeviceClass);
        fprintf(fp, "bDeviceSubClass     = 0x%02x\n", deviceDesc.bDeviceSubClass);
        fprintf(fp, "bDeviceProtocol     = 0x%02x\n", deviceDesc.bDeviceProtocol);
        fprintf(fp, "bMaxPacketSize      = %d\n", deviceDesc.bMaxPacketSize0);
        fprintf(fp, "idVendor            = 0x%04x\n", deviceDesc.idVendor);
        fprintf(fp, "idProduct           = 0x%04x\n", deviceDesc.idProduct);
        fprintf(fp, "bcdDevice           = 0x%04x\n", deviceDesc.bcdDevice);
        fprintf(fp, "iManufacturer       = %d\n", deviceDesc.iManufacturer);
        fprintf(fp, "iProduct            = %d\n", deviceDesc.iProduct);
        fprintf(fp, "iSerialNumber       = %d\n", deviceDesc.iSerialNumber);
        fprintf(fp, "bNumConfigurations  = %d\n", deviceDesc.bNumConfigurations);
        return 0;
    }
    else { return -2; }
}

/**This program is a CLI program to extract the current configuration of a device.*/
int MimacUSB3Connection::get_device_config() {
    int config = 0;

    rStatus = cyusb_get_configuration(cyusb_gethandle(0),&config);
    if( rStatus ) {
        cyusb_error(rStatus);
        cyusb_close();
        return rStatus;
    }

    if ( config == 0 ) {
        printf("The device is currently unconfigured\n");
    }
    else {
        printf("Device configured. Current configuration = %d\n", config);
    }

    rStatus = cyusb_get_active_config_descriptor(cyusb_gethandle(0), &configDesc);
    if ( rStatus ) {
        printf("Error retrieving config descriptor\n");
        return rStatus;
    }

    return 0;
}

int MimacUSB3Connection::print_config_descriptor() {
    char tbuf[64];

    if(!get_device_config()) {
        sprintf(tbuf, "bLength             = %d\n", configDesc->bLength);
        printf("%s", tbuf);
        sprintf(tbuf, "bDescriptorType     = %d\n", configDesc->bDescriptorType);
        printf("%s", tbuf);
        sprintf(tbuf, "TotalLength         = %d\n", configDesc->wTotalLength);
        printf("%s", tbuf);
        sprintf(tbuf, "Num. of interfaces  = %d\n", configDesc->bNumInterfaces);
        printf("%s", tbuf);
        sprintf(tbuf, "bConfigurationValue = %d\n", configDesc->bConfigurationValue);
        printf("%s", tbuf);
        sprintf(tbuf, "iConfiguration      = %d\n", configDesc->iConfiguration);
        printf("%s", tbuf);
        sprintf(tbuf, "bmAttributes        = %d\n", configDesc->bmAttributes);
        printf("%s", tbuf);
        sprintf(tbuf, "Max Power           = %04d\n", configDesc->MaxPower);
        printf("%s", tbuf);
        return 0;
    }
    else { return -2; }
    //cyusb_free_config_descriptor(configDesc);
}

/**
 * This program is a CLI program to claim an interface for a device which has an unclaimed
 * interface
 * */
int MimacUSB3Connection::claim_interface(int interface) {
    int kernel_attached = 0;

    rStatus = cyusb_kernel_driver_active(cyusb_gethandle(0), interface);
    if ( rStatus == 1 ) {
        printf("A kernel driver has already claimed this interface\n");
        kernel_attached = 1;
    }
    else if ( rStatus ) {
        cyusb_error(rStatus);
        cyusb_close();
        return rStatus;
    }
    if ( kernel_attached ) {
        rStatus = cyusb_detach_kernel_driver(cyusb_gethandle(0), interface);
        if ( rStatus == 0 ) {
            printf("Successfully detached kernel driver for this interface\n");
        }
        else {
            cyusb_error(rStatus);
            cyusb_close();
            return rStatus;
        }
    }
    rStatus = cyusb_claim_interface(cyusb_gethandle(0), interface);
    if ( rStatus == 0 ) {
        printf("Interface %d claimed successfully\n",interface);
    }
    else {
        cyusb_error(rStatus);
        cyusb_close();
        return rStatus;
    }

    return rStatus;
}


/**
 * Next bunch of functions are done to upload a .img firmware to the FX3 device
 * */
int MimacUSB3Connection::download_fx3_firmware(char *filename, char *tgt_str) {
    fx3_fw_target tgt = FW_TARGET_NONE;
    device_handle = cyusb_gethandle(0);

    if (strcasecmp (tgt_str, "ram") == 0) { tgt = FW_TARGET_RAM; }
    if (strcasecmp (tgt_str, "i2c") == 0) { tgt = FW_TARGET_I2C; }
    if (strcasecmp (tgt_str, "spi") == 0) { tgt = FW_TARGET_SPI; }
    if (tgt == FW_TARGET_NONE) {
        fprintf (stderr, "Error: Unknown target %s\n", tgt_str);
        return -EINVAL;
    }

    if ( filename == nullptr ) {
        fprintf (stderr, "Error: Firmware binary not specified\n");
        return -EINVAL;
    }

    switch (tgt) {
        case FW_TARGET_RAM:
            rStatus = fx3_usbboot_download(filename);
            break;
        case FW_TARGET_I2C:
            //rStatus = fx3_i2cboot_download(filename);
            break;
        case FW_TARGET_SPI:
            //rStatus = fx3_spiboot_download(filename);
            break;
        // Impossible to reach default
    }
    if (rStatus != 0) {
        fprintf (stderr, "Error: FX3 firmware programming failed\n");
    } else {
        printf ("FX3 firmware programming to %s completed\n", tgt_str);
    }

    return rStatus;
}


int MimacUSB3Connection::fx3_usbboot_download(const char *filename) {
    unsigned char *fwBuf;
    unsigned int  *data_p;
    unsigned int i, checksum;
    unsigned int address;
    unsigned short length;
    int r, index, filesize;

    fwBuf = (unsigned char *)calloc (1, MAX_FWIMG_SIZE);
    if (fwBuf == nullptr) {
        fprintf (stderr, "Error: Failed to allocate buffer to store firmware binary\n");
        return -1;
    }

    // Read the firmware image into the local RAM buffer.
    r = read_firmware_image(filename, fwBuf, nullptr, &filesize);
    if (r != 0) {
        fprintf (stderr, "Error: Failed to read firmware file %s\n", filename);
        free(fwBuf);
        return -2;
    }

    // Run through each section of code, and use vendor commands to download them to RAM.
    index    = 4;
    checksum = 0;
    while (index < filesize) {
        data_p  = (unsigned int *)(fwBuf + index);
        length  = data_p[0];
        address = data_p[1];
        if (length != 0) {
            for (i = 0; i < length; i++) {
                checksum += data_p[2 + i];
            }
            r = fx3_ram_write (fwBuf + index + 8, address, length * 4);
            if (r != 0) {
                fprintf (stderr, "Error: Failed to download data to FX3 RAM\n");
                free (fwBuf);
                return -3;
            }
        }
        else {
            if (checksum != data_p[2]) {
                fprintf (stderr, "Error: Checksum error in firmware binary\n");
                free (fwBuf);
                return -4;
            }

            r = cyusb_control_transfer (device_handle, 0x40, 0xA0, GET_LSW(address), GET_MSW(address), nullptr, 0, VENDORCMD_TIMEOUT);
            if (r != 0) {
                printf("Info: Ignored error in control transfer: %d\n", r);
            }
            break;
        }

        index += (8 + length * 4);
    }

    free (fwBuf);
    return 0;
}

/** Read the firmware image from the file into a buffer. */
int MimacUSB3Connection::read_firmware_image(const char *filename, unsigned char *buf, int *romsize, int *filesize) {
    int fd;
    int nbr;
    struct stat filestat;

    if (stat (filename, &filestat) != 0) {
        fprintf (stderr, "Error: Failed to stat file %s\n", filename);
        return -1;
    }

    // Verify that the file size does not exceed our limits.
    *filesize = filestat.st_size;
    if (*filesize > MAX_FWIMG_SIZE) {
        fprintf (stderr, "Error: File size exceeds maximum firmware image size\n");
        return -2;
    }

    fd = open(filename, O_RDONLY);
    if (fd < 0) {
        fprintf (stderr, "Error: File not found\n");
        return -3;
    }
    nbr = read (fd, buf, 2);		/* Read first 2 bytes, must be equal to 'CY'	*/
    if (strncmp ((char *)buf,"CY",2)) {
        fprintf (stderr, "Error: Image does not have 'CY' at start.\n");
        return -4;
    }
    nbr = read (fd, buf, 1);		/* Read 1 byte. bImageCTL	*/
    if (buf[0] & 0x01) {
        fprintf (stderr, "Error: Image does not contain executable code\n");
        return -5;
    }
    if (romsize != 0)
        *romsize = i2c_eeprom_size[(buf[0] >> 1) & 0x07];

    nbr = read (fd, buf, 1);		/* Read 1 byte. bImageType	*/
    if (!(buf[0] == 0xB0)) {
        fprintf (stderr, "Error: Not a normal FW binary with checksum\n");
        return -6;
    }

    // Read the complete firmware binary into a local buffer.
    lseek (fd, 0, SEEK_SET);
    nbr = read (fd, buf, *filesize);

    close (fd);
    return 0;
}

/**
* This is a CLI program which can be used to measure the
*   data transfer rate for data (IN or OUT endpoint) transfers
*   from a Cypress USB device. Endpoints of type Bulk, Interrupt
*   and Isochronous are supported.
*/
int MimacUSB3Connection::test_performance() {
    int  if_numsettings;
    bool found_ep = false;
    struct timeval t1{}, t2{};		// Timestamps used for test duration control

    struct libusb_transfer **transfers = nullptr;		// List of transfer structures.
    unsigned char **databuffers = nullptr;			// List of data buffers.

    endpoint   = 129;	// Endpoint to be tested
    reqsize    = 32;   //16;	// Request size in number of packets
    queuedepth = 8;    //16;	// Number of requests to queue
    duration   = 100;	// Duration of the test in seconds

    success_count = 0;	    // Number of successful transfers
    failure_count = 0;	    // Number of failed transfers
    transfer_size = 0;	    // Size of data transfers performed so far
    transfer_index = 0;     // Write index into the transfer_size array

    stop_transfers = false;	// Request to stop data transfers
    rqts_in_flight = 0;	    // Number of transfers that are in progress

    // Step 1: Get a handle to the first CyUSB device.
    device_handle = cyusb_gethandle(0);
    if (device_handle == nullptr) {
        printf ("test_performance: Failed to get CyUSB device handle\n");
        return -EACCES;
    }

    // Step 2: Read the configuration descriptor.
    rStatus = get_device_config();

    // Step 3: Check each of the interfaces one by one and check if we can find the desired endpoint there.
#ifdef DEBUG
    printf("Checking all the the %d interfaces\n", configDesc->bNumInterfaces);
    fflush(stdout);
#endif
    for (int i = 0; i < configDesc->bNumInterfaces; i++) {
        // Step 3.a: Claim the interface
        rStatus = cyusb_claim_interface(device_handle, i);
#ifdef DEBUG
        printf("Claiming interface %d\n", i);
        fflush(stdout);
#endif
        claim_interface(i);
#ifdef DEBUG
        printf("Good, lets keep on\n");
        fflush(stdout);
#endif
        // Step 3.b: Get each of the interface descriptors and check if the endpoint is present.
        if_numsettings = configDesc->interface[i].num_altsetting;
        for (int j = 0; j < if_numsettings; j++) {

            interfaceDesc = (libusb_interface_descriptor *)&(configDesc->interface[i].altsetting[j]);

            // Step 3.b.1: Check if the desired endpoint is present.
#ifdef DEBUG
            printf("Checking all the the %d endpoints for interface %d, desc %d\n", interfaceDesc->bNumEndpoints, i, j);
            fflush(stdout);
#endif
            for (int k = 0; k < interfaceDesc->bNumEndpoints; k++) {

                endpointDesc = (libusb_endpoint_descriptor *)&(interfaceDesc->endpoint[k]);
                if (endpointDesc->bEndpointAddress == endpoint) {
                    printf ("test_performance: Found endpoint 0x%x in interface %d, setting %d\n", endpoint, i, j);

                    // If the alt setting is not 0, select it
                    cyusb_set_interface_alt_setting (device_handle, i, j);
                    found_ep = true;
                    break;
                }
            }
            if (found_ep) { break; }
        }

        if (found_ep) { break; }

        // Step 3.c: Release the interface as the endpoint was not found.
        cyusb_release_interface (device_handle, i);
    }

    if (!found_ep) {
        printf ("test_performance: Failed to find endpoint 0x%x on device\n", endpoint);
        cyusb_free_config_descriptor (configDesc);
        cyusb_close ();
        return (-ENOENT);
    }

    // Store the endpoint type and maximum packet size
    eptype  = endpointDesc->bmAttributes;

    cyusb_get_device_descriptor (device_handle, &deviceDesc);
    if (deviceDesc.bcdUSB >= 0x0300) {
        // If this is a USB 3.0 connection, get the endpoint companion descriptor
        // The packet size for the endpoint is calculated as the product of the max
        // packet size and the burst size. For Isochronous endpoints, this value is
        // multiplied by the mult value as well.

        libusb_get_ss_endpoint_companion_descriptor (nullptr, endpointDesc, &companionDesc);

        if (eptype == LIBUSB_TRANSFER_TYPE_ISOCHRONOUS) {
            pktsize = static_cast<unsigned int>(endpointDesc->wMaxPacketSize * (companionDesc->bMaxBurst + 1) *
                                                (companionDesc->bmAttributes + 1));
        }
        else {
            pktsize = static_cast<unsigned int>(endpointDesc->wMaxPacketSize * (companionDesc->bMaxBurst + 1));
        }

        libusb_free_ss_endpoint_companion_descriptor (companionDesc);

    } else {
        // Not USB 3.0. For Isochronous endpoints, get the packet size as computed by
        // the library. For other endpoints, use the max packet size as it is.
        if (eptype == LIBUSB_TRANSFER_TYPE_ISOCHRONOUS) {
            pktsize = static_cast<unsigned int>(cyusb_get_max_iso_packet_size(device_handle, static_cast<unsigned char>(endpoint)));
        }
        else {
            pktsize = endpointDesc->wMaxPacketSize;
        }

    }

    // Print the test parameters.
    printf ("test_performance: Starting test with the following parameters\n");
    printf ("\tRequest size     : 0x%x\n", reqsize);
    printf ("\tQueue depth      : 0x%x\n", queuedepth);
    printf ("\tTest duration    : 0x%x\n", duration);
    printf ("\tEndpoint to test : 0x%x\n", endpoint);
    printf ("\n");
    printf ("\tEndpoint type    : 0x%x\n", eptype);
    printf ("\tMax packet size  : 0x%x\n", pktsize);

    // Allocate buffers and transfer structures
    bool allocfail = false;

    databuffers = (unsigned char **)calloc (queuedepth, sizeof (unsigned char *));
    transfers   = (struct libusb_transfer **)calloc (queuedepth, sizeof (struct libusb_transfer *));

    if ((databuffers != nullptr) && (transfers != nullptr)) {

        for (unsigned int i = 0; i < queuedepth; i++) {

            databuffers[i] = (unsigned char *)malloc (reqsize * pktsize);
            transfers[i]   = libusb_alloc_transfer (
                    (eptype == LIBUSB_TRANSFER_TYPE_ISOCHRONOUS) ? reqsize : 0);

            if ((databuffers[i] == nullptr) || (transfers[i] == nullptr)) {
                allocfail = true;
                break;
            }
        }

    } else {
        allocfail = true;
    }

    // Check if all memory allocations have succeeded
    if (allocfail) {
        printf ("test_performance: Failed to allocate buffers and transfer structures\n");
        free_transfer_buffers (databuffers, transfers, queuedepth);

        cyusb_free_config_descriptor (configDesc);
        cyusb_close ();
        return (-ENOMEM);
    }

    // Take the transfer start timestamp
    gettimeofday (&start_ts, nullptr);

    // Launch all the transfers till queue depth is complete
    for (unsigned int i = 0; i < queuedepth; i++) {
        switch (eptype) {
            case LIBUSB_TRANSFER_TYPE_BULK:
                libusb_fill_bulk_transfer(transfers[i], device_handle, static_cast<unsigned char>(endpoint),
                                           databuffers[i], reqsize * pktsize, xfer_callback, nullptr, 5000);
                rStatus = libusb_submit_transfer (transfers[i]);
                if (rStatus == 0) { rqts_in_flight++; }
                break;

            case LIBUSB_TRANSFER_TYPE_INTERRUPT:
                libusb_fill_interrupt_transfer(transfers[i], device_handle, static_cast<unsigned char>(endpoint),
                                                databuffers[i], reqsize * pktsize, xfer_callback, nullptr, 5000);
                rStatus = libusb_submit_transfer (transfers[i]);
                if (rStatus == 0) { rqts_in_flight++; }
                break;

            case LIBUSB_TRANSFER_TYPE_ISOCHRONOUS:
                libusb_fill_iso_transfer(transfers[i], device_handle, static_cast<unsigned char>(endpoint), databuffers[i],
                                          reqsize * pktsize, reqsize, xfer_callback, nullptr, 5000);
                libusb_set_iso_packet_lengths (transfers[i], pktsize);
                rStatus = libusb_submit_transfer (transfers[i]);
                if (rStatus == 0) { rqts_in_flight++; }
                break;

            default:
                break;
        }
    }

    gettimeofday (&t1, nullptr);
    do {
        libusb_handle_events (nullptr);
        gettimeofday (&t2, nullptr);
    } while (t2.tv_sec < (t1.tv_sec + duration));

    // Test duration elapsed. Set the stop_transfers flag and wait until all transfers are complete.
    printf ("test_performance: Test duration is complete. Stopping transfers\n");
    stop_transfers = true;
    while (rqts_in_flight != 0) {
        printf ("%d requests are pending\n", rqts_in_flight);
        libusb_handle_events (nullptr);
        sleep (1);
    }

    // All transfers are complete. We can now free up all structures.
    printf ("test_performance: Transfers completed\n");

    free_transfer_buffers (databuffers, transfers, queuedepth);
    cyusb_free_config_descriptor (configDesc);
    cyusb_close();

    printf ("test_performance: Test completed\n");
    return 0;
}

// Function to free data buffers and transfer structures
void MimacUSB3Connection::free_transfer_buffers(unsigned char **databuffers, struct libusb_transfer **transfers, unsigned int queuedepth) {
    // Free up any allocated data buffers
    if (databuffers != nullptr) {
        for (unsigned int i = 0; i < queuedepth; i++) {
            if (databuffers[i] != nullptr) {
                free (databuffers[i]);
            }
            databuffers[i] = nullptr;
        }
        free (databuffers);
    }

    // Free up any allocated transfer structures
    if (transfers != nullptr) {
        for (unsigned int i = 0; i < queuedepth; i++) {
            if (transfers[i] != nullptr) {
                libusb_free_transfer (transfers[i]);
            }
            transfers[i] = nullptr;
        }
        free (transfers);
    }
}

// Function: xfer_callback
// This is the call back function called by libusb upon completion of a queued data transfer.
void MimacUSB3Connection::xfer_callback(struct libusb_transfer *transfer) {

    unsigned int elapsed_time;
    int size = 0;

    // Reduce the number of requests in flight.
    rqts_in_flight--;

    // Check if the transfer has succeeded.
    if (transfer->status != LIBUSB_TRANSFER_COMPLETED) {
        failure_count++;
    } else {

        if (eptype == LIBUSB_TRANSFER_TYPE_ISOCHRONOUS) {

            // Loop through all the packets and check the status of each packet transfer
            for (int i = 0; i < reqsize; ++i) {

                // Calculate the actual size of data transferred in each micro-frame.
                if (transfer->iso_packet_desc[i].status == LIBUSB_TRANSFER_COMPLETED) {
                    size += transfer->iso_packet_desc[i].actual_length;
                }
            }
        } else {
            size = reqsize * pktsize;
        }
        success_count++;
    }
    // Update the actual transfer size for this request.
    transfer_size += size;

    // Print the transfer statistics when queuedepth transfers are completed.
    transfer_index++;
    if (transfer_index == queuedepth) {

        gettimeofday (&end_ts, nullptr);
        elapsed_time = static_cast<unsigned int>((end_ts.tv_sec - start_ts.tv_sec) * 1000000 +
                                                 (end_ts.tv_usec - start_ts.tv_usec));

        printf ("Transfer Counts: %d pass %d fail\n", success_count, failure_count);
        printf ("Data rate: %f KBps\n\n", (((double)transfer_size / 1024) / ((double)elapsed_time / 1000000)));

        transfer_index = 0;
        transfer_size  = 0;
        start_ts = end_ts;
    }

    // Prepare and re-submit the read request.
    if (!stop_transfers) {

        switch (eptype) {
            case LIBUSB_TRANSFER_TYPE_BULK:
                if (libusb_submit_transfer (transfer) == 0)
                    rqts_in_flight++;
                break;

            case LIBUSB_TRANSFER_TYPE_INTERRUPT:
                if (libusb_submit_transfer (transfer) == 0)
                    rqts_in_flight++;
                break;

            case LIBUSB_TRANSFER_TYPE_ISOCHRONOUS:
                libusb_set_iso_packet_lengths (transfer, pktsize);
                if (libusb_submit_transfer (transfer) == 0)
                    rqts_in_flight++;
                break;

            default:
                break;
        }
    }
}

int MimacUSB3Connection::fx3_ram_write(unsigned char *buf, unsigned int ramAddress, unsigned short len) {
    int r;
    int index = 0;
    unsigned short size;

    while (len > 0) {
        size = static_cast<unsigned short>((len > MAX_WRITE_SIZE) ? MAX_WRITE_SIZE : len);
        r = cyusb_control_transfer (device_handle, 0x40, 0xA0, GET_LSW(ramAddress), GET_MSW(ramAddress), &buf[index], size, VENDORCMD_TIMEOUT);
        if (r != size) {
            fprintf (stderr, "Error: Vendor write to FX3 RAM failed\n");
            return -1;
        }
        ramAddress += size;
        index      += size;
        len        -= size;
    }

    return 0;
}







