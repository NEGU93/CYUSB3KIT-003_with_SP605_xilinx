Print information
=================

.. cpp:function:: int FX3USB3Connection::print_devices()
Description
	Prints all USB devices BUS, VID, PID and bcd.
Returns 
	- number of USB devices on success
	- libusb error upon error.

.. cpp:function:: int FX3USB3Connection::print_device_descriptor()

Description
	Prints the connected device descriptor.
Returns
	LIBUSB error return status

.. cpp:function:: int FX3USB3Connection::print_config_descriptor()
Description
	Prints the connected device configuration
Returns
	LIBUSB error return status

.. cpp:function:: libusb_device_descriptor FX3USB3Connection::get_device_descriptor()

Returns 
	libusb_device_descriptor_ with the information of the connected device.

.. _libusb_device_descriptor: http://libusb.sourceforge.net/api-1.0/structlibusb__device__descriptor.html