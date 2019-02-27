
Programming
===========

Download fx3 firmware
---------------------

.. cpp:function:: int FX3USB3Connection::download_fx3_firmware(char *filename, char *tgt_str = const_cast<char *>("ram"), unsigned short vid = 0, unsigned short pid = 0)

Upload a .img firmware to the FX3 device
Input:
	@filename: name of the firware.img file to be programmed
	@tgt_str (Optional):
		"ram" (Default)
		"i2c"
		"spi"
	@pid & @vid (Optional):
 		If after programming, the board is supposed to change both vid and pid values it must be passed as parameters.

Program Device
--------------

.. cpp:function:: int FX3USB3Connection::program_device(char *fpga_firmware_filename)

Program FPGA with the file passed as input.
Returns:
	0 on success
 	LIBUSB_ERROR_TIMEOUT if the transfer timed out
	LIBUSB_ERROR_PIPE if the control request was not supported by the device
	LIBUSB_ERROR_NO_DEVICE if the device has been disconnected
	another LIBUSB_ERROR code on other failures