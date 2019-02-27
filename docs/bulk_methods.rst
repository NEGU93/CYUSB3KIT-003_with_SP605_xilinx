Bulk Methods
============

Send Text Files
---------------

.. cpp:function:: FX3USB3Connection::void send_text_file(bool verbose)

Uses send and receive buffer to send a text file and reads same size response
It then checks the readed data is the same as the data sended

Send Buffer
-----------

.. cpp:function:: int FX3USB3Connection::send_buffer(unsigned char *buf, int sz, unsigned int end_ptr = 0x01)

Sends the data stored on 'buf' of size 'sz' to the endpoint passed (default 0x01)

Recive Buffer
-------------

.. cpp:function:: int FX3USB3Connection::recive_buffer(unsigned char *buf, unsigned int data_count, unsigned int end_ptr = 0x81)

Reads data from endpoint 0x81 (default) to buf and returns the size of data read(should be same as data_count)
	Returns lenght of data readed.