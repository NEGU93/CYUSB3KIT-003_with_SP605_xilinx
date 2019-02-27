Constructor
===========

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