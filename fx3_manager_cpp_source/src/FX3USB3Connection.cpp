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
#include <tgmath.h>
#include "../include/FX3USB3Connection.h"

#include <fstream>

//#define DEBUG

// static variables
unsigned int FX3USB3Connection::endpoint;         // Endpoint to be tested
unsigned int FX3USB3Connection::reqsize;          // Request size in number of packets
unsigned int FX3USB3Connection::queuedepth;       // Number of requests to queue
unsigned int FX3USB3Connection::duration;         // Duration of the test in seconds

unsigned char FX3USB3Connection::eptype;		    // Type of endpoint (transfer type)
unsigned int FX3USB3Connection::pktsize;		    // Maximum packet size for the endpoint

bool	FX3USB3Connection::stop_transfers;	    // Request to stop data transfers
int		FX3USB3Connection::rqts_in_flight;	    // Number of transfers that are in progress

unsigned int FX3USB3Connection::success_count;	// Number of successful transfers
unsigned int FX3USB3Connection::failure_count;	// Number of failed transfers
unsigned int FX3USB3Connection::transfer_size;	// Size of data transfers performed so far
unsigned int FX3USB3Connection::transfer_index;	// Write index into the transfer_size array

struct timeval	FX3USB3Connection::start_ts;	    // Data transfer start time stamp.
struct timeval	FX3USB3Connection::end_ts;		// Data transfer stop time stamp.

// Methods
/**
 * Opens if there's only one USB3 device
 * */
FX3USB3Connection::FX3USB3Connection() {
    fp = stdout;
    cyusb_handle *h = nullptr;
    rStatus = cyusb_open();
    if ( rStatus < 0 ) { throw ErrorOpeningLib(); }
    else if ( rStatus == 0 ) { throw NoDeviceFound(); }
    if(rStatus == 1) {
        h = cyusb_gethandle(0);
        cyusb_device.dev     = libusb_get_device(h);
        cyusb_device.handle  = h;
        cyusb_device.vid     = cyusb_getvendor(h);
        cyusb_device.pid     = cyusb_getproduct(h);
        cyusb_device.is_open = 1;
        cyusb_device.busnum  = static_cast<unsigned char>(cyusb_get_busnumber(h));
        cyusb_device.devaddr = static_cast<unsigned char>(cyusb_get_devaddr(h));
    }
    else {
        printf("Many possible devices to connect with. Please select vid and pid number");
    }
}

/**
 * Opens cyusb device given the pid and vid value.
 * */
FX3USB3Connection::FX3USB3Connection(unsigned short vid, unsigned short pid) : vid(vid), pid(pid) {
    fp = stdout;
    cyusb_handle *h = nullptr;
    rStatus = cyusb_open(vid, pid);
    if ( rStatus < 0 ) {
        fprintf(stderr, "VendorID 0x%04x,\tProdID 0x%04x\n", vid, pid);
        fflush(nullptr);
        print_devices();
        throw ErrorOpeningLib();
    }
    else if (rStatus == 0) { throw NoDeviceFound(); }
    else if(rStatus == 1) {
        h = libusb_open_device_with_vid_pid(nullptr, vid, pid);
        if ( !h ) {
            //fprintf(stderr, "Device not found.\n");
            fprintf(stderr, "VendorID 0x%04x,\tProdID 0x%04x\n", vid, pid);
        }
        cyusb_device.dev     = libusb_get_device(h);
        cyusb_device.handle  = h;
        cyusb_device.vid     = cyusb_getvendor(h);
        cyusb_device.pid     = cyusb_getproduct(h);
        cyusb_device.is_open = 1;
        cyusb_device.busnum  = static_cast<unsigned char>(cyusb_get_busnumber(h));
        cyusb_device.devaddr = static_cast<unsigned char>(cyusb_get_devaddr(h));
    }
    else {
        printf("Many possible devices to connect with. Please select vid and pid number");
    }
}

FX3USB3Connection::~FX3USB3Connection() {
    cyusb_close();
}

/**
 * dump out the device descriptor for any USB device given its
 * VID/PID. The program itself accepts options : Either vid/pid on the command line OR first
 * VID/PID of interest in cyusb.conf
 * */
int FX3USB3Connection::get_device_descriptor() {
    rStatus = cyusb_get_device_descriptor(cyusb_device.handle, &deviceDesc);
    if ( rStatus ) {
        fprintf(stderr, "FX3USB3Connection::get_device_descriptor(): Error getting device descriptor\n");
        return -2;
    }
    return rStatus;
}
int FX3USB3Connection::print_device_descriptor(){
    rStatus = get_device_descriptor();
    if(!rStatus) {
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
    else { return rStatus; }
}

/**This program is a CLI program to extract the current configuration of a device.*/
int FX3USB3Connection::get_device_config() {
    int config = 0;

    rStatus = cyusb_get_configuration(cyusb_device.handle,&config);
    if( rStatus ) {
        cyusb_error(rStatus);
        cyusb_close();
        return rStatus;
    }

    if ( config == 0 ) {
        fprintf(stderr, "The device is currently unconfigured\n");
    }
#ifdef DEBUG
    else {
        printf("Device configured. Current configuration = %d\n", config);
    }
#endif

    rStatus = cyusb_get_active_config_descriptor(cyusb_device.handle, &configDesc);
    if ( rStatus ) {
        fprintf(stderr, "FX3USB3Connection::get_device_config(): Error retrieving config descriptor\n");
        cyusb_error(rStatus);
        cyusb_close();
        return rStatus;
    }

    return 0;
}

int FX3USB3Connection::print_config_descriptor() {
    char tbuf[64];

    rStatus = get_device_config();
    if(!rStatus) {
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
    else { return rStatus; }
}

/**
 * This program is a CLI program to claim an interface for a device which has an unclaimed
 * interface
 * */
int FX3USB3Connection::claim_interface(int interface) {
    int kernel_attached = 0;

    rStatus = cyusb_kernel_driver_active(cyusb_device.handle, interface);
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
        rStatus = cyusb_detach_kernel_driver(cyusb_device.handle, interface);
        if ( rStatus == 0 ) {
            printf("Successfully detached kernel driver for this interface\n");
        }
        else {
            cyusb_error(rStatus);
            cyusb_close();
            return rStatus;
        }
    }
    rStatus = cyusb_claim_interface(cyusb_device.handle, interface);
    if ( rStatus == 0 ) {
#ifdef DEBUG
        printf("\tInterface %d claimed successfully\n",interface);
#endif
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
int FX3USB3Connection::download_fx3_firmware(char *filename, char *tgt_str) {
    fx3_fw_target tgt = FW_TARGET_NONE;

    if (strcasecmp (tgt_str, "ram") == 0) { tgt = FW_TARGET_RAM; }
    if (strcasecmp (tgt_str, "i2c") == 0) { tgt = FW_TARGET_I2C; }
    if (strcasecmp (tgt_str, "spi") == 0) { tgt = FW_TARGET_SPI; }

    if ( filename == nullptr ) {
        fprintf (stderr, "Error: Firmware binary not specified\n");
        return -EINVAL;
    }

    switch (tgt) {
        case FW_TARGET_RAM:
            rStatus = cyusb_download_fx3(cyusb_device.handle, filename);
            break;
        case FW_TARGET_I2C:
            fprintf (stderr, "Error: I2C target not yet implemented %s\n", tgt_str);
            //rStatus = fx3_i2cboot_download(cyusb_device.handle, filename);
            //break;
            return -EINVAL;
        case FW_TARGET_SPI:
            fprintf (stderr, "Error: SPI target not yet implemented %s\n", tgt_str);
            //rStatus = fx3_spiboot_download(cyusb_device.handle, filename);
            //break;
            return -EINVAL;
        case FW_TARGET_NONE:
            fprintf (stderr, "Error: Unknown target %s\n", tgt_str);
            return -EINVAL;
    }

    if (rStatus != 0) {
        fprintf (stderr, "Error: FX3 firmware programming failed\n");
        cyusb_error(rStatus);
        cyusb_close();
    }
    else { printf("FX3 firmware programming to %s completed\n", tgt_str); }

    return rStatus;
}

/**---------------------------------------------------------------------**/

/**
 * Search for a specific endpoint to see if it exists
 * */
int FX3USB3Connection::find_endpoint(unsigned int end_pt) {
    int  if_numsettings;
    bool found_ep = false;
    cyusb_handle *device_handle;

    // Step 1: Get a handle to the first CyUSB device.
    device_handle = cyusb_device.handle;
    if (device_handle == nullptr) {
        fprintf (stderr, "FX3USB3Connection::find_endpoint(): Failed to get CyUSB device handle\n");
        cyusb_error(rStatus);
        cyusb_close();
        return -EACCES;
    }

    // Step 2: Read the configuration descriptor.
    rStatus = get_device_config();

    // Step 3: Check each of the interfaces one by one and check if we can find the desired endpoint there.
    for (int i = 0; i < configDesc->bNumInterfaces; i++) {
        // Step 3.a: Claim the interface
        rStatus = cyusb_claim_interface(device_handle, i);
        claim_interface(i);

        // Step 3.b: Get each of the interface descriptors and check if the endpoint is present.
        if_numsettings = configDesc->interface[i].num_altsetting;
        for (int j = 0; j < if_numsettings; j++) {

            interfaceDesc = (libusb_interface_descriptor *)&(configDesc->interface[i].altsetting[j]);

            // Step 3.b.1: Check if the desired endpoint is present.
            for (int k = 0; k < interfaceDesc->bNumEndpoints; k++) {
                endpointDesc = (libusb_endpoint_descriptor *)&(interfaceDesc->endpoint[k]);
                if (endpointDesc->bEndpointAddress == end_pt) {
#ifdef DEBUG
                    printf ("\tFound endpoint 0x%x in interface %d, setting %d\n", end_pt, i, j);
#endif
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
        cyusb_release_interface(device_handle, i);
    }

    if (!found_ep) {
        fprintf (stderr, "FX3USB3Connection::find_endpoint(): Failed to find endpoint 0x%x on device\n", end_pt);
        cyusb_free_config_descriptor(configDesc);
        cyusb_close ();
        return (-ENOENT);
    }

    return 0;
}

/**
* This is a CLI program which can be used to measure the
*   data transfer rate for data (IN or OUT endpoint) transfers
*   from a Cypress USB device. Endpoints of type Bulk, Interrupt
*   and Isochronous are supported.
*/
int FX3USB3Connection::test_performance() {
    cyusb_handle *device_handle;
    int  if_numsettings;
    bool found_ep = false;
    struct timeval t1{}, t2{};		// Timestamps used for test duration control

    struct libusb_transfer **transfers = nullptr;		// List of transfer structures.
    unsigned char **databuffers = nullptr;			    // List of data buffers.

    endpoint   = 129;	    // Endpoint to be tested
    reqsize    = 64;        //16;	// Request size in number of packets
    queuedepth = 16;        //16;	// Number of requests to queue
    duration   = 60;	    // Duration of the test in seconds

    success_count = 0;	    // Number of successful transfers
    failure_count = 0;	    // Number of failed transfers
    transfer_size = 0;	    // Size of data transfers performed so far
    transfer_index = 0;     // Write index into the transfer_size array

    stop_transfers = false;	// Request to stop data transfers
    rqts_in_flight = 0;	    // Number of transfers that are in progress

    // Step 1: Get a handle to the first CyUSB device.
    device_handle = cyusb_device.handle;
    if (device_handle == nullptr) {
        fprintf (stderr, "test_performance: Failed to get CyUSB device handle\n");
        cyusb_error(rStatus);
        cyusb_close();
        return -EACCES;
    }

    // Step 2: Read the configuration descriptor.
    rStatus = get_device_config();

    // Step 3: Check each of the interfaces one by one and check if we can find the desired endpoint there.
    for (int i = 0; i < configDesc->bNumInterfaces; i++) {
        // Step 3.a: Claim the interface
        rStatus = cyusb_claim_interface(device_handle, i);
        claim_interface(i);

        // Step 3.b: Get each of the interface descriptors and check if the endpoint is present.
        if_numsettings = configDesc->interface[i].num_altsetting;
        for (int j = 0; j < if_numsettings; j++) {

            interfaceDesc = (libusb_interface_descriptor *)&(configDesc->interface[i].altsetting[j]);

            // Step 3.b.1: Check if the desired endpoint is present.
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
        fprintf (stderr, "test_performance: Failed to find endpoint 0x%x on device\n", endpoint);
        cyusb_free_config_descriptor(configDesc);
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
        fprintf(stderr, "test_performance: Failed to allocate buffers and transfer structures\n");
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
    do {    // Wait the desired amount of seconds
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
    //cyusb_close();

    printf ("test_performance: Test completed\n");
    fflush(stdout);
    return 0;
}

/**
 * Uses send and receive buffer to send a text file expecting a loopback.
 * It stores the data on some files and assest the received file is equal to se sent file.
 * */
void FX3USB3Connection::send_text_file() {
    ssize_t nbr;
    unsigned char *buf;
    size_t maxps = 0;
    int fd_outfile, fd_infile;
    int transferred;
    char *out_text_filename = const_cast<char *>("/home/barrachina/Documents/MIMAC/CYUSB3KIT-003_with_SP605_xilinx/fx3_manager_cpp_source/TEST_OUT.txt");
    char *in_text_filename = const_cast<char *>("/home/barrachina/Documents/MIMAC/CYUSB3KIT-003_with_SP605_xilinx/fx3_manager_cpp_source/TEST_IN.txt");


    fd_outfile = open(out_text_filename, O_RDONLY);
    if ( fd_outfile < 0 ) {
        fprintf(stderr, "FX3USB3Connection::send_text_file(): Output file not found!");
        return;
    }
    fd_infile = open(in_text_filename, O_WRONLY | O_CREAT, S_IRUSR | S_IWUSR);
    if ( fd_infile < 0 ) {
        fprintf(stderr, "FX3USB3Connection::send_text_file(): Input file creation error");
        return;
    }

    maxps = 4096;	// If sending a file, then data is sent in 4096 byte packets

    buf = (unsigned char *)malloc(maxps);
    while ( (nbr = read(fd_outfile, buf, maxps)) ) {
        if(send_buffer(buf, static_cast<int>(nbr))) {        // Send data to FPGA
            fprintf(stderr, "FX3USB3Connection::send_text_file(): Error couldn't write the data back (error: %d)\n", rStatus);
            free(buf);
            ::close(fd_outfile);
            ::close(fd_infile);
            return;
        }
        sleep(1);
        transferred = recive_buffer(buf, static_cast<unsigned int>(nbr));   // Get data from FPGA
        if(transferred < 0) {
            fprintf(stderr, "FX3USB3Connection::send_text_file(): Error couldn't read the data back (error: %d)\n", rStatus);
            free(buf);
            ::close(fd_outfile);
            ::close(fd_infile);
            return;
        }
        rStatus = static_cast<int>(write(fd_infile, buf, static_cast<size_t>(transferred)));
        if (rStatus < 0) {
            fprintf(stderr, "FX3USB3Connection::send_text_file(): Error creating file from data (rStatus = %d)\n", rStatus);
            free(buf);
            ::close(fd_outfile);
            ::close(fd_infile);
            return;
        }
    }
    free(buf);
    ::close(fd_outfile);
    ::close(fd_infile);
    printf("Loopback recieved, checking if I received the same that I sended\n");
    compare_files(out_text_filename, in_text_filename);
}

/**
 * Compares to files and asserts they are the same.
 * Prints the number of missmatches and returns it's value
 * */
int FX3USB3Connection::compare_files(char *fp1_string, char *fp2_string) {
#ifdef DEBUG
    printf("Comparing both files ...\n");
#endif
    // opening both file in read only mode
    FILE *fp1 = fopen(fp1_string, "r");
    FILE *fp2 = fopen(fp2_string, "r");

    if (fp1 == nullptr || fp2 == nullptr) {
        fprintf(stderr, "FX3USB3Connection::compare_files(): Error: Files not open");
        exit(0);
    }

    // fetching character of two file
    // in two variable ch1 and ch2
    int ch1 = getc(fp1);
    int ch2 = getc(fp2);

    // error keeps track of number of errors
    // pos keeps track of position of errors
    // line keeps track of error line
    int error = 0, pos = 0, line = 1;

    // iterate loop till end of file
    while (ch1 != EOF && ch2 != EOF) {
        pos++;

        // if both variable encounters new
        // line then line variable is incremented
        // and pos variable is set to 0
        if (ch1 == '\n' && ch2 == '\n') {
            line++;
            pos = 0;
        }

        // if fetched data is not equal then
        // error is incremented
        if (ch1 != ch2) {
            error++;
            printf("Line Number : %d \tError"
                   " Position : %d \n", line, pos);
        }

        // fetching character until end of file
        ch1 = getc(fp1);
        ch2 = getc(fp2);
    }

    // closing both file
    fclose(fp1);
    fclose(fp2);
    printf("Total missmatches between files : %d\n", error);
    return error;
}

/**
 * Sends the data stored on buf of size sz to the endpoint 0x01
 * */
int FX3USB3Connection::send_buffer(unsigned char *buf, int sz, unsigned int end_ptr) {
    int rStatus;
    int transferred = 0;

    if(find_endpoint(end_ptr) != 0) {
        fprintf(stderr, "FX3USB3Connection::send_buffer(): Error: endpoint (%d) not found\n", end_ptr);
        return -1;
    }

    rStatus = cyusb_bulk_transfer(cyusb_device.handle, static_cast<unsigned char>(end_ptr), buf, sz, &transferred, 1000);
#ifdef DEBUG
    printf("Bytes sent to device = %d\n", transferred);
#endif
    if (rStatus) {
        fprintf(stderr, "Error in send buffer: ");
        cyusb_error(rStatus);
        cyusb_close();
        return rStatus;
    }
}

/**
 * Reads data from endpoint 0x81 to buf and returns the size of data read
 * (should be same as data_count)
 *
 * Returns lenght of data readed.
 * */
int FX3USB3Connection::recive_buffer(unsigned char *buf, unsigned int data_count, unsigned int end_ptr){
    //int rStatus;
    int transferred = 0;

    if(find_endpoint(end_ptr) != 0) {
        fprintf(stderr, "FX3USB3Connection::recive_buffer(): Error: endpoint (%d) not found\n", end_ptr);
        return -1;
    }
    buf = (unsigned char *)malloc(data_count);
    rStatus = cyusb_bulk_transfer(cyusb_device.handle, static_cast<unsigned char>(end_ptr), buf, data_count, &transferred, 1000);
#ifdef DEBUG
    printf("Bytes read from device = %d\n", transferred);
#endif
    if ( rStatus < 0 ) {
        fprintf(stderr, "Error in recive buffer: ");
        cyusb_error(rStatus);
        cyusb_close();
        return rStatus;
    }
    return transferred;
}

//! Function to free data buffers and transfer structures
void FX3USB3Connection::free_transfer_buffers(unsigned char **databuffers, struct libusb_transfer **transfers, unsigned int queuedepth) {
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

//! Function: xfer_callback
//! This is the call back function called by libusb upon completion of a queued data transfer.
void FX3USB3Connection::xfer_callback(struct libusb_transfer *transfer) {
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
        elapsed_time = static_cast<unsigned int>((end_ts.tv_sec - start_ts.tv_sec) * 1000000 + (end_ts.tv_usec - start_ts.tv_usec));
//#ifdef DEBUG
        printf ("Transfer Counts: %d pass %d fail\n", success_count, failure_count);
        printf ("Data rate: %f KBps\n\n", (((double)transfer_size / 1024) / ((double)elapsed_time / 1000000)));
//#endif
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

/**
 *  Program FPGA with the file passed as input.
 *  Returns:
 *   0 on success
 *   LIBUSB_ERROR_TIMEOUT if the transfer timed out
 *   LIBUSB_ERROR_PIPE if the control request was not supported by the device
 *   LIBUSB_ERROR_NO_DEVICE if the device has been disconnected
 *   another LIBUSB_ERROR code on other failures
 * */
int FX3USB3Connection::program_device(char *fpga_firmware_filename) {
    FILE * fpga_file;
    unsigned int fpga_firmware_size;
    char * buffer;
    size_t fread_result;
    unsigned short wLength = 16;
    unsigned int timeout = 10*1000;
    unsigned short wValue = 0, wIndex = 1;

    fpga_file = fopen(fpga_firmware_filename, "rb");
    if (fpga_file == nullptr) {
        fprintf(stderr, "Error Couldn't open firmware %s\n", fpga_firmware_filename);
        exit (1);
    }

    fseek (fpga_file , 0 , SEEK_END);
    fpga_firmware_size = static_cast<unsigned int>(ftell (fpga_file));   // obtain file size:
    rewind (fpga_file);

    buffer = (char*) malloc (sizeof(char)*fpga_firmware_size);   // Allocate memory to contain the whole file:
    if (buffer == nullptr) {
        fprintf(stderr, "Memory error allocating buffer");
        exit (2);
    }

    fread_result = fread(buffer, 1, static_cast<size_t>(fpga_firmware_size), fpga_file);   // Copy the file into the buffer
    if (fread_result != fpga_firmware_size) {
        fprintf(stderr, "Error copying file to buffer");
        exit (3);
    }
#ifdef DEBUG
    printf("filelen = %u\n", fpga_firmware_size);
#endif
    printf("Programming FPGA\n");
    // Start programming command
    rStatus = cyusb_control_write(
            cyusb_device.handle,        /* a handle for the device to communicate with */
            WRITE_REQUEST_TYPE,        /* bmRequestType: the request type field for the setup packet */
            VND_CMD_SLAVESER_CFGLOAD,  /* bRequest: the request field for the setup packet */
            wValue,                    /* wValue: the value field for the setup packet */
            wIndex,                    /* wIndex: the index field for the setup packet */
            (unsigned char *) &fpga_firmware_size,  /* *data: a suitably-sized data buffer */
            wLength,                   /* wLength: the length field for the setup packet. The data buffer should be at least this size. */
            timeout);                  /* timeout (in millseconds) that this function should wait before giving up due to no response being received. For an unlimited timeout, use value 0. */
    if (rStatus < 0) {         /* LIB_USB_ERROR */
        fprintf(stderr, "rStatus = %d\n", rStatus);
        cyusb_error(rStatus);
        cyusb_close();
        return rStatus;
    }
    send_buffer(reinterpret_cast<unsigned char *>(buffer), fpga_firmware_size);  // Send the FPGA firmware
    sleep(1);
    rStatus = cyusb_control_read(
            cyusb_device.handle,       /* a handle for the device to communicate with */
            0xC0,                      /* bmRequestType: the request type field for the setup packet */
            VND_CMD_SLAVESER_CFGSTAT,  /* bRequest: the request field for the setup packet */
            wValue,                    /* wValue: the value field for the setup packet */
            wIndex,                    /* wIndex: the index field for the setup packet */
            (unsigned char *) &fpga_firmware_size,  /* *data: a suitably-sized data buffer */
            wLength,                   /* wLength: the length field for the setup packet. The data buffer should be at least this size. */
            timeout);                  /* timeout (in millseconds) that this function should wait before giving up due to no response being received. For an unlimited timeout, use value 0. */
    if (rStatus < 0) {         // LIB_USB_ERROR
        fprintf(stderr, "rStatus = %d\n", rStatus);
        cyusb_error(rStatus);
        cyusb_close();
        return rStatus;
    }
    printf("FPGA configured with %s\n", fpga_firmware_filename);
    fclose (fpga_file);
    free (buffer);
    return 0;
}

/**
 *  Not yet debuged nor working
 * */
int FX3USB3Connection::reset_board() {
    return cyusb_reset_device(cyusb_device.handle);
    /*unsigned char instruction[32];
    int transferred = 0;

    instruction[0] = RESET_BOARD;
    instruction[1] = 1;

    rStatus = libusb_bulk_transfer(cyusb_device.handle, 1, instruction, 2, &transferred, 1000);
    if (rStatus || transferred != 2) {
        fprintf(stderr, "Reset set failed \n");
        cyusb_error(rStatus);
        cyusb_close();
        return rStatus;
    }

    instruction[1] = 0;
    rStatus = libusb_bulk_transfer(cyusb_device.handle, 1, instruction, 2, &transferred, 1000);
    if (rStatus || transferred != 2) {
        fprintf(stderr, "Reset relese failed \n");
        cyusb_error(rStatus);
        cyusb_close();
        return rStatus;
    }

    return 0;*/
}

/**
 * Prints all USB devices BUS, VID, PID and bcd.
 * Returns number of USB devices on success
 * libusb error upon error.
 * */
int FX3USB3Connection::print_devices() {
    struct  libusb_device_descriptor desc{};
    libusb_device	**list;
    int numdev;

    numdev = static_cast<int>(libusb_get_device_list(nullptr, &list));    // Get all usb devices
    if (numdev < 0) {
        printf("Fail, no device to list: %s", libusb_error_name(numdev));
        return numdev;
    }

    for (int i = 0; i < numdev; ++i ) { // For each device
        libusb_device *device = list[i];
        libusb_get_device_descriptor(device, &desc);
        // Print device information.
        printf("Bus=0x%x,\tVendorID 0x%04x,\tProdID 0x%04x,\tbcdDevice 0x%04x\n",
                 libusb_get_bus_number(device), desc.idVendor, desc.idProduct, desc.bcdDevice);
    }

    return numdev;
}
int FX3USB3Connection::clear_halt(unsigned char endpoint) {
    rStatus = libusb_clear_halt(cyusb_device.handle, endpoint);
    if(rStatus) {
        fprintf(stderr, "FX3USB3Connection::clear_halt(): Error %s for endpoint %u\n", libusb_error_name(rStatus), endpoint);
    }
    return rStatus;
}

/*int FX3USB3Connection::download_fx3_firmware_ram(char *filename, char *tgt_str) {
    return cyusb_download_fx3(cyusb_device.handle, filename);
}*/
