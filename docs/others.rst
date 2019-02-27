Others
======

.. cpp:function:: int soft_reset()

Send a reset command to the FX3 device and then reconnects to it.
	Returns: 	0 on success
			cyusb error if not

.. cpp:function:: int claim_interface(int interface)

This program is a CLI program to claim an interface for a device which has an unclaimed interface
