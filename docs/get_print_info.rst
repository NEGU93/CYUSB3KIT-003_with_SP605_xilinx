Print information
=================

.. cpp:function:: int FX3USB3Connection::print_devices()

Prints all USB devices BUS, VID, PID and bcd.
	Returns number of USB devices on success
	libusb error upon error.

.. cpp:function:: int FX3USB3Connection::print_device_descriptor()

Prints the connected device descriptor.

.. cpp:function:: int FX3USB3Connection::print_config_descriptor()

Prints the connected device configuration

.. cpp:function:: libusb_device_descriptor FX3USB3Connection::get_device_descriptor()

Returns a libusb_device_descriptor_ with the information of the connected device.

.. _libusb_device_descriptor: http://libusb.sourceforge.net/api-1.0/structlibusb__device__descriptor.html