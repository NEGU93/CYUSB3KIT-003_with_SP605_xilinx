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
#include <cassert>
#include <regex>

//#define DEBUG
//#define DEBUG_MATCH_DEVICE

/**
 * isempty:
   Check if the first L characters of the string buf are white-space characters.
 */
static bool isempty(char *buf, int L) {
    bool flag = true;
    int i;

    for (i = 0; i < L; ++i ) {
        if ( (buf[i] != ' ') && ( buf[i] != '\t' ) ) {
            flag = false;
            break;
        }
    }

    return flag;
}

/**
 * Opens a usb device that matches any of the devices listed on device_descriptors (default: "conf/device.conf")
 * If no other requirement other than being a Cypress device, device_descriptors should be a nullptr
 * */
FX3USB3Connection::FX3USB3Connection(char *device_descriptors) {
    vid = 0;
    pid = 0;
    if(device_descriptors) {
        get_device_search_descriptor(device_descriptors);
    }
    rStatus = connect();
}

/**
 * Opens cyusb device given the pid and vid value.
 * */
FX3USB3Connection::FX3USB3Connection(unsigned short vid, unsigned short pid) : vid(vid), pid(pid) {
    rStatus = connect();
}

/**
 * Connects with the FX3 device provided only one is available
 * Returns 0 on success
 * Returns cyusb error if not
 * */
int FX3USB3Connection::connect() {
    fp = stdout;
    cyusb_handle *h = nullptr;
    if (vid && pid) {
        rStatus = cyusb_open(vid, pid);
    }
    else {
        rStatus = cyusb_open();
    }
    //printf("%d\n", rStatus);
    if ( rStatus < 0 ) {
        cyusb_error(rStatus);
        cyusb_close();
    }
    else if (rStatus == 0) {
        if(vid && pid) { fprintf(stderr, "Couldn't find VendorID 0x%04x,\tProdID 0x%04x\n", vid, pid); }
        else { printf("No device was listed as a cyusb device\n"); }
        print_devices();
        rStatus = -5;
    }
    else {  // rStatus > 0
        if(rStatus > 1) {
            printf("Warning: Many possible devices to connect with.\n");
        }
#ifdef DEBUG_MATCH_DEVICE
        int index = get_match(rStatus, true);
#else
        int index = get_match(rStatus, false);
#endif
        if (index < 0) {
            fprintf(stderr, "Device description not found\n");
            return -1;
        }
        else {
            h = cyusb_gethandle(index);
            cyusb_device.dev = libusb_get_device(h);
            cyusb_device.handle = h;
            cyusb_device.vid = cyusb_getvendor(h);
            cyusb_device.pid = cyusb_getproduct(h);
            cyusb_device.is_open = 1;
            cyusb_device.busnum = static_cast<unsigned char>(cyusb_get_busnumber(h));
            cyusb_device.devaddr = static_cast<unsigned char>(cyusb_get_devaddr(h));
        }
    }
    return rStatus;
}

FX3USB3Connection::~FX3USB3Connection() {
    libusb_close(cyusb_device.handle);
    libusb_exit(nullptr);
    sleep(1);
}

/**
 *  Send a reset command to the FX3 device and then reconnects to it.
 * Returns 0 on success
 * Returns cyusb error if not
 * */
int FX3USB3Connection::soft_reset() {
    //return cyusb_reset_device(cyusb_device.handle);
    unsigned int data;
    unsigned short wLength = 16;
    unsigned int timeout = 10*1000;
    unsigned short wValue = 0, wIndex = 1;

    //! Send reset command
    rStatus = cyusb_control_write(
            cyusb_device.handle,       /* a handle for the device to communicate with */
            WRITE_REQUEST_TYPE,        /* bmRequestType: the request type field for the setup packet */
            VND_CMD_RESET_BOARD,       /* bRequest: the request field for the setup packet */
            wValue,                    /* wValue: the value field for the setup packet */
            wIndex,                    /* wIndex: the index field for the setup packet */
            (unsigned char *) &data,   /* *data: a suitably-sized data buffer */
            wLength,                   /* wLength: the length field for the setup packet. The data buffer should be at least this size. */
            timeout);                  /* timeout (in miliseconds) that this function should wait before giving up due to no response being received. For an unlimited timeout, use value 0. */
    sleep(1);
    //! Reconnect to FX3 device
    rStatus = reconnect();
    if (rStatus) {
        fprintf (stderr, "Error: reconnect failed\n");
        cyusb_error(rStatus);
        cyusb_close();
    }

    return 0;
}

/**
 * Disconnect current device and connect again
 * return 0 on success
 * */
int FX3USB3Connection::reconnect() {
    //! Close handle
    libusb_close(cyusb_device.handle);
    sleep(1);   // Wait before reconnecting
    rStatus = connect();
    if(rStatus == 1) { return 0; }
    assert(rStatus!=0);     // Should never return a 0
    //sleep(1);
    return rStatus;
}

/**
 * Reads the configuration file passed and saves all the information of possible devices
 * The configuration file must contain all the restrictions in the following way:
 * <NAME_DEVICE>
 *	bLength             = 18
 *	bDescriptorType     = 1
 *	bcdUSB              = 0x0210
 *	bDeviceClass        = 0x00
 *	bDeviceSubClass     = 0x00
 *	bDeviceProtocol     = 0x00
 *	bMaxPacketSize      = 64
 *	idVendor            = 0x04b4
 *	idProduct           = 0x00f3
 *	bcdDevice           = 0x0000
 *	iManufacturer       = 1
 *	iProduct            = 2
 *	iSerialNumber       = 0
 *	bNumConfigurations  = 1
 *</NAME_DEVICE>
 * If a variable is not listed it means it can be any.
 * This is used as a second filter to further state restrictions upon cyusb devices
 *
 * Input:
 *  @device_descriptor_filename: File path with the information of devices to match.
 * */
int FX3USB3Connection::get_device_search_descriptor(char *device_descriptor_filename) {
    FILE *inp;
    char buf[MAX_CFG_LINE_LENGTH];
    std::string cp1, cp2;
    std::string key;
    std::string::size_type sz;          // alias of size_t
    std::string regex_str_start = "<.+?>";    // matches any character one or more times included
    // inside < and >, expanding as needed
    std::string regex_str_end = "</.+?>";

    inp = fopen(device_descriptor_filename, "rStatus");
    if (inp == nullptr) {
        fprintf(stderr, "File for device descriptor %s not found. Ignoring file\n", device_descriptor_filename);
        return 0;
    };

    memset(buf, '\0', MAX_CFG_LINE_LENGTH);
    while ( fgets(buf, MAX_CFG_LINE_LENGTH, inp) ) {
        if ( buf[0] == '#' ) 			/* Any line starting with a # is a comment 	*/
            continue;
        if ( buf[0] == '\n' )
            continue;
        if ( isempty(buf, static_cast<int>(strlen(buf))) )		/* Any blank line is also ignored		*/
            continue;

        cp1 = strtok(buf, " :=\t\n");   // TODO create token variable to not repeat
#ifdef DEBUG
        printf("Comparing %s with %s and gives %d\n", cp1.c_str(), device_start.str().c_str(), cp1.compare(device_start.str()));
#endif
        if ( std::regex_match(cp1, std::regex(regex_str_start)) ) {
            struct libusb_device_descriptor descriptor{};
            key = cp1;
#ifdef DEBUG_MATCH_DEVICE
            printf("Found device %s restrictions:\n", key.c_str());
#endif
            while ( fgets(buf, MAX_CFG_LINE_LENGTH, inp) ) {
                if ( buf[0] == '#' ) { continue; }	/* Any line starting with a # is a comment 	*/
                if ( buf[0] == '\n' ) { continue; }
                if ( isempty(buf, static_cast<int>(strlen(buf))) ) {    /* Any blank line is also ignored		*/
                    continue;
                }
                cp1 = strtok(buf, " :=\t\n");
                if ( std::regex_match(cp1, std::regex(regex_str_end)) ) {
                    // End of device
#ifdef DEBUG_MATCH_DEVICE
                    printf("End of description of %s\n", key.c_str());
#endif
                    search_description[key] = descriptor;
                    break;
                }
                cp2 = strtok(nullptr, " :=\t\n");
#ifdef DEBUG_MATCH_DEVICE
                printf("\t%s must be %s = ", cp1.c_str(), cp2.c_str());
#endif
                if(cp1 == "bLength") {
                    descriptor.bLength = static_cast<uint8_t>(std::stoi(cp2, &sz));
#ifdef DEBUG_MATCH_DEVICE
                    printf("%d\n", descriptor.bLength);
#endif
                }
                else if(cp1 == "bDescriptorType") {
                    descriptor.bDescriptorType = static_cast<uint8_t>(std::stoi(cp2, &sz));
#ifdef DEBUG_MATCH_DEVICE
                    printf("%d\n", descriptor.bDescriptorType);
#endif
                }
                else if(cp1 == "bcdUSB") {
                    descriptor.bcdUSB = static_cast<uint16_t>(std::stoi(cp2, &sz, 16));
#ifdef DEBUG_MATCH_DEVICE
                    printf("%d\n", descriptor.bcdUSB);
#endif
                }
                else if(cp1 == "bDeviceClass") {
                    descriptor.bDeviceClass = static_cast<uint8_t>(std::stoi(cp2, &sz, 16));
#ifdef DEBUG_MATCH_DEVICE
                    printf("%d\n", descriptor.bDeviceClass);
#endif
                }
                else if(cp1 == "bDeviceSubClass") {
                    descriptor.bDeviceSubClass = static_cast<uint8_t>(std::stoi(cp2, &sz, 16));
#ifdef DEBUG_MATCH_DEVICE
                    printf("%d\n", descriptor.bDeviceSubClass);
#endif
                }
                else if(cp1 == "bDeviceProtocol") {
                    descriptor.bDeviceProtocol = static_cast<uint8_t>(std::stoi(cp2, &sz, 16));
#ifdef DEBUG_MATCH_DEVICE
                    printf("%d\n", descriptor.bDeviceProtocol);
#endif
                }
                else if(cp1 == "bMaxPacketSize") {
                    descriptor.bMaxPacketSize0 = static_cast<uint8_t>(std::stoi(cp2, &sz));
#ifdef DEBUG_MATCH_DEVICE
                    printf("%d\n", descriptor.bMaxPacketSize0);
#endif
                }
                else if(cp1 == "idVendor") {
                    descriptor.idVendor = static_cast<uint16_t>(std::stoi(cp2, &sz, 16));
#ifdef DEBUG_MATCH_DEVICE
                    printf("%d\n", descriptor.idVendor);
#endif
                }
                else if(cp1 == "idProduct") {
                    descriptor.idProduct = static_cast<uint16_t>(std::stoi(cp2, &sz, 16));
#ifdef DEBUG_MATCH_DEVICE
                    printf("%d\n", descriptor.idProduct);
#endif
                }
                else if(cp1 == "bcdDevice") {
                    descriptor.bcdDevice = static_cast<uint16_t>(std::stoi(cp2, &sz, 16));
#ifdef DEBUG_MATCH_DEVICE
                    printf("%d\n", descriptor.bcdDevice);
#endif
                }
                else if(cp1 == "iManufacturer") {
                    descriptor.iManufacturer = static_cast<uint8_t>(std::stoi(cp2, &sz));
#ifdef DEBUG_MATCH_DEVICE
                    printf("%d\n", descriptor.iManufacturer);
#endif
                }
                else if(cp1 == "iProduct") {
                    descriptor.iProduct = static_cast<uint8_t>(std::stoi(cp2, &sz));
#ifdef DEBUG_MATCH_DEVICE
                    printf("%d\n", descriptor.iProduct);
#endif
                }
                else if(cp1 ==  "iSerialNumber") {
                    descriptor.iSerialNumber = static_cast<uint8_t>(std::stoi(cp2, &sz));
#ifdef DEBUG_MATCH_DEVICE
                    printf("%d\n", descriptor.iSerialNumber);
#endif
                }
                else if(cp1 == "bNumConfigurations") {
                    descriptor.bNumConfigurations = static_cast<uint8_t>(std::stoi(cp2, &sz));
#ifdef DEBUG_MATCH_DEVICE
                    printf("%d\n", descriptor.bNumConfigurations);
#endif
                }
                else {
                    printf("Warning: Option %s not recognized. Ignoring it...\n", cp1.c_str());
                }
            }
        }
        else {
            printf("Error in config file: %s \n",buf);
            exit(1);
        }
    }

    fclose(inp);
    return 0;
}

/**
 * Get the amount of devices on liusb list that can be connected to.
 * Check if any of those devices have a match with the devices parsed on "get_device_search_descriptor"
 * The first of the devices that gets a match will be returned without checking any further,
 * So if 2 exact devices are connected only the first one on the list will be selected
 * returns:
 *      index (between 0 and max_devices-1) of matched device is any
 *      -1 if none of the devices where
 *      -2 if error
 * */
int FX3USB3Connection::get_match(int max_devices, bool verbose) {
    int index = 0;
    int r;
    bool found = false;
    cyusb_handle *h = nullptr;
    struct libusb_device_descriptor descriptor{};
    if(search_description.empty()) {
        return 0;   // No specific requirements
    }
    while( (index < max_devices) && !found) {
        h = cyusb_gethandle(index);
        r = cyusb_get_device_descriptor(h, &deviceDesc);
        if (r) {
            fprintf(stderr, "FX3USB3Connection::get_match(): Error getting device descriptor %d\n", index);
            return -2;
        }
        for(const auto &descriptor_map : search_description) { // Search for all the cases to see if device is good enough
            if(verbose)
                printf("Searching match for %s: ", descriptor_map.first.c_str());
            descriptor = descriptor_map.second;
            if (descriptor.bNumConfigurations == 0 ||
                descriptor.bNumConfigurations == deviceDesc.bNumConfigurations) {
                if (descriptor.bcdDevice == 0 || descriptor.bcdDevice == deviceDesc.bcdDevice) {
                    if (descriptor.bcdUSB == 0 || descriptor.bcdUSB == deviceDesc.bcdUSB) {
                        if (descriptor.bDescriptorType == 0 || descriptor.bDescriptorType == deviceDesc.bDescriptorType) {
                            if (descriptor.bDeviceClass == 0 || descriptor.bDeviceClass == deviceDesc.bDeviceClass) {
                                if (descriptor.bDeviceProtocol == 0 || descriptor.bDeviceProtocol == deviceDesc.bDeviceProtocol) {
                                    if (descriptor.bDeviceSubClass == 0 || descriptor.bDeviceSubClass == deviceDesc.bDeviceSubClass) {
                                        if (descriptor.bLength == 0 || descriptor.bLength == deviceDesc.bLength) {
                                            if (descriptor.bMaxPacketSize0 == 0 || descriptor.bMaxPacketSize0 == deviceDesc.bMaxPacketSize0) {
                                                if (descriptor.iProduct == 0 || descriptor.iProduct == deviceDesc.iProduct) {
                                                    if (descriptor.iSerialNumber == 0 || descriptor.iSerialNumber == deviceDesc.iSerialNumber) {
                                                        if (descriptor.iManufacturer == 0 || descriptor.iManufacturer == deviceDesc.iManufacturer) {
                                                            if (descriptor.idVendor == 0 || descriptor.idVendor == deviceDesc.idVendor) {
                                                                if (descriptor.idProduct == 0 || descriptor.idProduct == deviceDesc.idProduct) {
                                                                    if(verbose)
                                                                        printf("device connected matched %s\n", descriptor_map.first.c_str());
                                                                    found = true;   // Device gets all the descriptions
                                                                    break; // Break from the for loop, the device was found.
                                                                }
                                                                else if(verbose) {
                                                                    printf("search_descriptor idProduct %d does not match descriptor %d\n", descriptor.idProduct,
                                                                           deviceDesc.idProduct);
                                                                }
                                                            }
                                                            else if(verbose) {
                                                                printf("search_descriptor idVendor %d does not match descriptor %d\n", descriptor.idVendor,
                                                                       deviceDesc.idVendor);
                                                            }
                                                        }
                                                        else if(verbose) {
                                                            printf("search_descriptor iManufacturer %d does not match descriptor %d\n",
                                                                   descriptor.iManufacturer, deviceDesc.iManufacturer);
                                                        }
                                                    }
                                                    else if(verbose) {
                                                        printf("search_descriptor iSerialNumber  %d does not match descriptor %d\n",
                                                               descriptor.iSerialNumber, deviceDesc.iSerialNumber);
                                                    }
                                                }
                                                else if(verbose) {
                                                    printf("search_descriptor iProduct %d does not match descriptor %d\n", descriptor.iProduct,
                                                           deviceDesc.iProduct);
                                                }
                                            }
                                            else if(verbose) {
                                                printf("search_descriptor bMaxPacketSize0 %d does not match descriptor %d\n",
                                                       descriptor.bMaxPacketSize0, deviceDesc.bMaxPacketSize0);
                                            }
                                        }
                                        else if(verbose) {
                                            printf("search_descriptor bLength %d does not match descriptor %d\n", descriptor.bLength,
                                                   deviceDesc.bLength);
                                        }
                                    }
                                    else if(verbose) {
                                        printf("search_descriptor bDeviceSubClass %d does not match descriptor %d\n",
                                               descriptor.bDeviceSubClass, deviceDesc.bDeviceSubClass);
                                    }
                                }
                                else if(verbose) {
                                    printf("search_descriptor bDeviceProtocol %d does not match descriptor %d\n",
                                           descriptor.bDeviceProtocol, deviceDesc.bDeviceProtocol);
                                }
                            } else if(verbose) {
                                printf("search_descriptor bDeviceClass %d does not match descriptor %d\n",
                                       descriptor.bDeviceClass, deviceDesc.bDeviceClass);
                            }
                        } else if(verbose) {
                            printf("search_descriptor bDescriptorType %d does not match descriptor %d\n",
                                   descriptor.bDescriptorType, deviceDesc.bDescriptorType);
                        }
                    }else if(verbose) {
                        printf("search_descriptor bcdUSB %d does not match descriptor %d\n", descriptor.bcdUSB,
                               deviceDesc.bcdUSB);
                    }
                }else if(verbose) {
                    printf("search_descriptor bcdDevice %d does not match descriptor %d\n", descriptor.bcdDevice,
                           deviceDesc.bcdDevice);
                }
            } else if(verbose) {
                printf("search_descriptor bNumConfigurations %d does not match descriptor %d\n",
                       descriptor.bNumConfigurations, deviceDesc.bNumConfigurations);
            }
        }
        if (!found) { index++; } // If the device was not found increment index
    }
    if(found) { return index; }
    else { return -1; }
}

/*******************************************************************/

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
 * Input:
 *  @filename: name of the firware.img file to be programmed
 *  @tgt_str (Optional):
 *      "ram" (Default)
 *      "i2c"
 *      "spi"
 *  @pid & @vid (Optional):
 *      If after programming, the board is supposed to change both vid and pid values it must be passed as parameters.
 * */
int FX3USB3Connection::download_fx3_firmware(char *filename, char *tgt_str, unsigned short vid, unsigned short pid) {
    fx3_fw_target tgt = FW_TARGET_NONE;

    rStatus = soft_reset();
    if (rStatus) {
        fprintf (stderr, "Error: reconnect failed\n");
        cyusb_error(rStatus);
        cyusb_close();
        return rStatus;
    }

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
        return rStatus;
    }
    else { printf("FX3 firmware programming to %s completed\n", tgt_str); }
    if (pid && vid) {   // Before reconnecting, change the pid and vid if necessary.
        this->pid = pid;
        this->vid = vid;
    }
    rStatus = reconnect();
    if (rStatus) {
        fprintf (stderr, "Error: reconnect failed\n");
        cyusb_error(rStatus);
        cyusb_close();
        return rStatus;
    }
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
 * Uses send and receive buffer to send a text file expecting a loopback.
 * It stores the data on some files and assest the received file is equal to se sent file.
 * */
void FX3USB3Connection::send_text_file(bool verbose) {
    ssize_t nbr;
    unsigned char *buf;
    size_t maxps = 0;
    int fd_outfile, fd_infile;
    int transferred;
    char *out_text_filename = const_cast<char *>("/home/barrachina/Documents/MIMAC/CYUSB3KIT-003_with_SP605_xilinx/fx3_manager_cpp_source/TEST_OUT.txt");
    char *in_text_filename = const_cast<char *>("/home/barrachina/Documents/MIMAC/CYUSB3KIT-003_with_SP605_xilinx/fx3_manager_cpp_source/TEST_IN.txt");

    if (verbose) { printf("Testing Loopback\n"); }
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
    //compare_files(out_text_filename, in_text_filename);
    if (files_match(out_text_filename, in_text_filename) && verbose) { printf("Loopback Ok\n"); }
    else { printf("Loopback failed\n"); }
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
 * Faster function to compare 2 files. Returns true if files are the same.
 * Return false if not.
 * It prints a message with the result.
 * */
bool FX3USB3Connection::files_match(const std::string &p1, const std::string &p2) {
    bool files_match;
    std::ifstream f1(p1, std::ifstream::binary|std::ifstream::ate);
    std::ifstream f2(p2, std::ifstream::binary|std::ifstream::ate);

    if (f1.fail() || f2.fail()) {
        return false; //file problem
    }

    if (f1.tellg() != f2.tellg()) {
        return false; //size mismatch
    }

    //seek back to beginning and use std::equal to compare contents
    f1.seekg(0, std::ifstream::beg);
    f2.seekg(0, std::ifstream::beg);
    files_match = std::equal(std::istreambuf_iterator<char>(f1.rdbuf()),
                             std::istreambuf_iterator<char>(),
                             std::istreambuf_iterator<char>(f2.rdbuf()));
    f1.close();
    f2.close();
#ifdef DEBUG
    if (files_match) { printf("Files match\n"); fflush(stdout); }
    else { printf("Files not equal\n"); fflush(stdout); }
#endif
    return files_match;
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
    sleep(5);
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
