Others
======

.. cpp:function:: int FX3USB3Connection::soft_reset()
Description
	Send a reset command to the FX3 device and then reconnects to it.
Returns
	- 0 on success
	- cyusb error if not

.. cpp:function:: int FX3USB3Connection::claim_interface(int interface)

Description
	This program is a CLI program to claim an interface for a device which has an unclaimed interface
Receives
	Interface to claim
