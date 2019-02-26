# API usage

The cpp code is a class. When initializing the object, it automatically connects to a Cypress device:

**Constructor**

For initializing the device there are 3 options according to the need.
1. If the VID and PID is known, the device can be initialized direcly with:
`FX3USB3Connection fx3USB3Connection = FX3USB3Connection(vid, pid);`
2. If any cypress device will be OK, then initialize with:
`FX3USB3Connection fx3USB3Connection = FX3USB3Connection(nullptr);`
But make sure the device is listed on: `/etc/cyusb.conf`
3. If VID and PID is not good enough, put your description on `conf/device.conf` and run:

 - `FX3USB3Connection fx3USB3Connection = FX3USB3Connection();`
or
 - `FX3USB3Connection fx3USB3Connection = FX3USB3Connection("path/to/conf/file");` for using another conf file.

**Public methods**

Programming
- `int download_fx3_firmware(char *filename, char *tgt_str = const_cast<char *>("ram"), unsigned short vid = 0, unsigned short pid = 0);`:
```
/**
 * Upload a .img firmware to the FX3 device
 * Input:
 *  @filename: name of the firware.img file to be programmed
 *  @tgt_str (Optional):
 *      "ram" (Default)
 *      "i2c"
 *      "spi"
 *  @pid & @vid (Optional):
 *      If after programming, the board is supposed to change both vid and pid values it must be passed as parameters.
 * */
```

- `int program_device(char *fpga_firmware_filename);`:
```
/**
 *  Program FPGA with the file passed as input.
 *  Returns:
 *   0 on success
 *   LIBUSB_ERROR_TIMEOUT if the transfer timed out
 *   LIBUSB_ERROR_PIPE if the control request was not supported by the device
 *   LIBUSB_ERROR_NO_DEVICE if the device has been disconnected
 *   another LIBUSB_ERROR code on other failures
 * */
```
Bulk Methods
- `void send_text_file(bool verbose);`:
```
/**
 * Uses send and receive buffer to send a text file and reads same size response
 * It then checks the readed data is the same as the data sended
 * */
```
- `int send_buffer(unsigned char *buf, int sz, unsigned int end_ptr = 0x01);`:
```
/**
 * Sends the data stored on 'buf' of size 'sz' to the endpoint passed (default 0x01)
 * */
```
- `int recive_buffer(unsigned char *buf, unsigned int data_count, unsigned int end_ptr = 0x81);`:
```
/**
 * Reads data from endpoint 0x81 (default) to buf and returns the size of data read
 * (should be same as data_count)
 * Returns lenght of data readed.
 * */
```
Print information
- `int print_devices();`:
```
/**
 * Prints all USB devices BUS, VID, PID and bcd.
 * Returns number of USB devices on success
 * libusb error upon error.
 * */
```
- `int print_device_descriptor();`:
Prints the connected device descriptor.
- `int print_config_descriptor();`:
Prints the connected device configuration
- `libusb_device_descriptor get_device_descriptor()`:
Returns a [libusb_device_descriptor](http://libusb.sourceforge.net/api-1.0/structlibusb__device__descriptor.html) with the information of the connected device.

  Others:
- `int soft_reset();`:
```
/**
 *  Send a reset command to the FX3 device and then reconnects to it.
 * Returns 0 on success
 * Returns cyusb error if not
 * */
```
- `int claim_interface(int interface);`:
```
/**
 * This program is a CLI program to claim an interface for a device which has an unclaimed
 * interface
 * */
```

**FX3 firmware**
1. After programming, FX3 changes product ID from 0xF3 to 0xF1. To the definition of product ID is done on: `cyfxslfifousbdscr`
2. Endpoint defined on `cyfxslfifosync::CyFxSlFifoApplnStart()`
