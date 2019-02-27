Bulk Methods
============

Send Buffer
-----------

.. cpp:function:: int FX3USB3Connection::send_buffer(unsigned char *buf, int sz, unsigned int end_ptr = 0x01)

Description
	Sends the data stored on 'buf' of size 'sz' to the cypress device
Receives
	- ``unsigned char *buf``: pointer to a buffer where the data to be sent is stored
	- ``unsigned int data_count``: Size of data to be sent
	- (Optional) ``unsigned int end_ptr``: endpoint number where to send the data (default 0x01)
Returns
	- 0 on success (and populates transferred)
	- LIBUSB_ERROR_TIMEOUT if the transfer timed out (and populates transferred)
	- LIBUSB_ERROR_PIPE if the endpoint halted
	- LIBUSB_ERROR_OVERFLOW if the device offered more data, see Packets and overflows
	- LIBUSB_ERROR_NO_DEVICE if the device has been disconnected
	- another LIBUSB_ERROR code on other failures

Recive Buffer
-------------

.. cpp:function:: int FX3USB3Connection::receive_buffer(unsigned char *buf, unsigned int data_count, unsigned int end_ptr = 0x81)

Description
	Reads data from endpoint 0x81 (default) to buf and returns
Receives
	- ``unsigned char *buf``: pointer to a buffer where the readed data will be stored
	- ``unsigned int data_count``: Size of expected amount of bytes to read
	- (Optional) ``unsigned int end_ptr``: endpoint number where to read the data (default 0x81)
Returns 
	Lenght of data readed the size of data read (should be same as data_count)


Send Text Files
---------------
.. cpp:function:: void FX3USB3Connection::send_text_file(bool verbose)

Description
	Uses send and receive buffer functions to send a text file and reads same size response
	It then checks the readed data is the same as the data sended
Receives
	- ``bool verbose``: True if print results and false if silent mode