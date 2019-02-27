Constructor
===========

Upon construction, the object connects to the desired Cypress device.
For initializing the device there are 3 options according to the need.

.. cpp:function:: FX3USB3Connection::FX3USB3Connection(vid, pid)

This option is used to give the device a VID and PID of the device that has to connect

.. cpp:function:: FX3USB3Connection::FX3USB3Connection(nullptr)

When cypress is installed, a file is created on ``/etc/cyusb.conf`` with the description of all Cypress possible devices. 
Use the ``nullptr`` option when connection to any standard Cypress device.

.. cpp:function:: FX3USB3Connection::FX3USB3Connection()
.. cpp:function:: FX3USB3Connection::FX3USB3Connection("path/to/conf/file")

If VID and PID is not good enough, you can create a ``.conf`` file with the description of all the parameters the device must have. 
By default, ``conf/device.conf`` is used. If not it is necessary to give the construcor the file path.