//
// Created by barrachina on 12/20/18.
//

#ifndef TESTING_CPP_CODE_DOWNLOAD_FX3_H
#define TESTING_CPP_CODE_DOWNLOAD_FX3_H

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/stat.h>

#include <libusb-1.0/libusb.h>
#include "cyusb.h"

int fx3_usbboot_download(cyusb_handle *h, const char *filename);
int fx3_i2cboot_download(cyusb_handle *h, const char *filename);
int fx3_spiboot_download(cyusb_handle *h, const char *filename);

#endif //TESTING_CPP_CODE_DOWNLOAD_FX3_H
