using System;
using System.IO;
using System.Collections.Generic;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Diagnostics;
using System.Threading;
using CyUSB;

namespace Template
{
    public partial class Form1 : Form
    {
        CyUSBDevice myDevice = null;                                                       // Create a USB device for our application called myUSB
        CyUSBDevice myFX3Device = null;
        USBDeviceList usbDevices = null;                                                // Find all USBDevice objects that represent all USB devices
                                                  
        CyBulkEndPoint BulkOutEndPt = null;
        CyControlEndPoint CtrlEndPt = null;

        
        bool DeviceAttached = true;
        static int file_bytes;
        byte[] file_buffer;
        bool success ;
        bool firmwaredownloaded = false;
 

        public Form1()
        {
            InitializeComponent();                                                      // All components of the form are initialized
            Refresh();
            

            usbDevices = new USBDeviceList(CyConst.DEVICES_CYUSB);                      // All devices served by CyUSB.sys is added to the list usbDevices

            GetDevice();                                                                //  check if an EZ-USB device is already connected
           
            usbDevices.DeviceAttached += new EventHandler(usbDevices_DeviceAttached);   // Eventhandler assigned to DeviceAttached
                                                                                        // to handle the event when a device is attached
            usbDevices.DeviceRemoved += new EventHandler(usbDevices_DeviceRemoved);     // Eventhandler assigned to DeviceRemoved
                                                                                        // to handle the event when a device is removed
            //StatLabel1.Text = "Download the image file into FX3 using Cypress Control Center";  
            
        }

        public void usbDevices_DeviceAttached(object sender, EventArgs e)
        {
            DeviceAttached = true;                                                      // A device has been connected
            GetDevice();
        }

        public void usbDevices_DeviceRemoved(object sender, EventArgs e)
        {
            DeviceAttached = false;                                                      // A device has been disconnected
            RemoveDevice();
            //rtConsole.Clear();
        }

        public void RemoveDevice()
        {
            
            myFX3Device = usbDevices[0x04b4, 0x00F1] as CyFX3Device;

            if (!firmwaredownloaded)
            {
                if (myFX3Device == null)
                {
                    rtConsole.AppendText("No EZ-USB  FX3 device is connected\n");                           // Status message when device is disconnected
                    StatLabel1.Text = "NEXT STEP: Connect EZ-USB FX3 board to PC using an USB cable";
                    button1.Enabled = false;
                    button2.Enabled = false;
                    button3.Enabled = false;

                }
            }
        }

        public void GetDevice()
        {
            if (DeviceAttached == true)
            {
                myDevice = usbDevices[0x04b4, 0x00F1] as CyUSBDevice;              // check for device with VID/PID of 0x04B4/0x1002
                myFX3Device = usbDevices[0x04B4, 0x00F3] as CyFX3Device;
                                                                   
                
                if ((myFX3Device != null)&&(myDevice == null))                                           // If myDevice exists
                {
                    button1.Enabled = true;
                    button2.Enabled = false;
                    button3.Enabled = false;
                    
                    StatLabel1.Text = "NEXT STEP: Use Download Firmware button to load image into FX3";
                    rtConsole.AppendText ("EZ-USB FX3 Bootloader Device connected\n");
                }
                else if ((myDevice != null)&&(myFX3Device == null))                                             // If myDevice exists
                {
                    BulkOutEndPt = myDevice.EndPointOf(0x02) as CyBulkEndPoint;   //Assign EP2 as BulkOutEP and EP6 as BulkInEP
                    button3.Enabled = true;
                    button1.Enabled = false;
                   
                    button2.Enabled = false;
                    rtConsole.AppendText ("FX3 - Xilinx Slave Serial Programmer detected\n");
                    StatLabel1.Text = "NEXT STEP: Use Select Bitstream button to select the .bin file for FPGA ";
                }
                else if ((firmwaredownloaded)&&(myDevice != null))
                {
                    button1.Enabled = false;
                    rtConsole.AppendText ("NO FX3 - Xilinx Slave Serial Programmer detected\n");
                    StatLabel1.Text = "NEXT STEP: Reset the FX3 board and Download the right image into FX3";
                    
                }
                else
                {

                    button1.Enabled = false;
                    button2.Enabled = false;
                    button3.Enabled = false;
                    
                    

                    rtConsole.AppendText ("No EZ-USB  FX3 device is connected\n");
                    StatLabel1.Text = "NEXT STEP: Connect EZ-USB FX3 board to PC using an USB cable";
                    DeviceAttached = false;

                }

            }

            if (DeviceAttached == false)
            {
                DisableApp();                                                          // there is either no device attached or the attached device is not a FX2
            }
            else
            {
                EnableApp();                                                           // the attached device is a FX2LP with our VID/PID
            }


        }

                                                                                                
        public void EnableApp()
        {
                                              
        }

        public void DisableApp()
        {
                               
        }

       

       

        private void Form1_Load(object sender, EventArgs e)
        {

        }

        

        private void button1_Click_1(object sender, EventArgs e)             // Code for Exit Button Press
        {
            Application.Exit();
        }

        

        private void button3_Click(object sender, EventArgs e)
        {
            long flen = 0;

            string fname = "";
            string tmpFilter = FOpenDialog.Filter;
            string title = FOpenDialog.Title;
            FOpenDialog.Title = "Select the file to send";
            FOpenDialog.Filter = "bin files (*.bin)|*.bin|All files (*.*) | *.*";

            if (FOpenDialog.ShowDialog() == DialogResult.OK) //selecting bitstream
            {
                fname = FOpenDialog.FileName;
                
                Refresh();
                rtConsole.AppendText ("Bitstream File Selected\n");
                StatLabel1.Text = "NEXT STEP: Use Configure button to start Configuration ";
            }
            else
            {
                FOpenDialog.Filter = tmpFilter;
                FOpenDialog.Title = title;
                return;
            }

            FOpenDialog.FileName = "";
            FOpenDialog.Filter = tmpFilter;
            FOpenDialog.Title = title;

            FileStream file = new FileStream(fname, FileMode.Open, FileAccess.Read);
            flen = file.Length;
            //file_bytes = (int)flen;

            file_bytes = (int)flen;
            file_buffer = new byte[file_bytes];

            file.Read(file_buffer, 0, file_bytes);
            file.Close();
            rtConsole.AppendText (fname);
            rtConsole.AppendText("\n");
            
            
            button2.Enabled = true;
            button3.Enabled = false;
            
            
                   
    

        }

        private void button2_Click_1(object sender, EventArgs e)
        {
            int len = 0;
            byte[] buf = new byte[16];
           
            buf[0] = (Byte)(file_bytes & 0x000000FF);
            buf[1] = (Byte)((file_bytes & 0x0000FF00) >> 8);
            buf[2] = (Byte)((file_bytes & 0x00FF0000) >> 16);
            buf[3] = (Byte)((file_bytes & 0xFF000000) >> 24);
            if (myDevice != null)
            {
                rtConsole.AppendText ("Writing data to FPGA........\n");
                StatLabel1.Text = "NEXT STEP: Wait ... ";
                CtrlEndPt = myDevice.ControlEndPt;
                CtrlEndPt.Target = CyConst.TGT_DEVICE;
                CtrlEndPt.ReqType = CyConst.REQ_VENDOR;
                CtrlEndPt.Direction = CyConst.DIR_TO_DEVICE;
                CtrlEndPt.ReqCode = 0xB2;
                CtrlEndPt.Value = 0;
                CtrlEndPt.Index = 1;
                len = 16;
                CtrlEndPt.XferData(ref buf, ref len);//send vendor command to start configuration 
                // myDevice.BulkOutEndPt.TimeOut = 100000;
                myDevice.BulkOutEndPt.XferSize = 4096;//set transfer size as 4096

                //myDevice.BulkOutEndPt.TimeOut = 1000;

                success = myDevice.BulkOutEndPt.XferData(ref file_buffer, ref file_bytes); //check if transfer successful

                if (success == true)
                {
                              
                    button2.Enabled = false;
                    
                    rtConsole.AppendText ("Configuration data has been sent to FPGA\n");
                    System.Threading.Thread.Sleep(200);
                    CtrlEndPt.Target = CyConst.TGT_DEVICE;
                    CtrlEndPt.ReqType = CyConst.REQ_VENDOR;
                    CtrlEndPt.Direction = CyConst.DIR_FROM_DEVICE;
                    CtrlEndPt.ReqCode = 0xB1;
                    CtrlEndPt.Value = 0;
                    CtrlEndPt.Index = 1;
                    len = 16;
                    buf[0] = 0;

                    CtrlEndPt.XferData(ref buf, ref len);//send vendor command to know the status of Configuration
                    button2.Enabled = false;


                    //rtConsole.Clear();

                    if (buf[0] == 1)
                    {
                        button3.Enabled = false;
                        rtConsole.AppendText("Configuration Successful\n");
                        rtConsole.AppendText("FX3 Slave FIFO interface is activated\n");
                        rtConsole.AppendText("*********************************************\n");
                        StatLabel1.Text = "NEXT STEP: Use Control Center/Streamer application to do data transfers";
                    }
                    else
                    {
                        button3.Enabled = true;
                        button2.Enabled = true;
                        rtConsole.AppendText("Configuration Failed\n");
                        StatLabel1.Text = "NEXT STEP: Please Repeat the Steps Carefully";
                    }


                    
                }
                else
                {
                    
                    rtConsole.AppendText ("Failed to send the Configuration data to FPGA\n");
                    StatLabel1.Text = "NEXT STEP: Please Repeat the Steps Carefully";
                }

                
            }
            else
            {
                button1.Enabled = false;
                button2.Enabled = false;
                button3.Enabled = false;
                
                rtConsole.AppendText ("No EZ-USB  FX3 device is connected\n");
                StatLabel1.Text = "NEXT STEP: Connect EZ-USB FX3 board to PC using an USB cable";
            }

        }

        private void button1_Click(object sender, EventArgs e)
        {

                
            CyFX3Device fx = myFX3Device as CyFX3Device;
            string tmpFilter = FOpenDialog.Filter;
            FOpenDialog.Filter = "Firmware Image files (*.img) | *.img";
            if ((fx != null) && (FOpenDialog.ShowDialog() == DialogResult.OK))
            {
                
                FX3_FWDWNLOAD_ERROR_CODE enmResult = FX3_FWDWNLOAD_ERROR_CODE.SUCCESS;

                
                rtConsole.AppendText("Programming RAM of ");
                rtConsole.AppendText(fx.FriendlyName);
                rtConsole.AppendText("........\n");

                string filename = FOpenDialog.FileName;
               Refresh();
               enmResult = fx.DownloadFw(filename, FX3_FWDWNLOAD_MEDIA_TYPE.RAM);



                rtConsole.AppendText("Programming");
                rtConsole.AppendText(fx.GetFwErrorString(enmResult));
                rtConsole.AppendText("\n");
                Refresh();
                firmwaredownloaded = true;
                
                button1.Enabled = false;
            }
            else if (myDevice != null)
            {
                rtConsole.AppendText ("FX3 firmware is already downloaded\n");
                StatLabel1.Text = "NEXT STEP: Use Select Bitstream to select the FPGA .bin file ";
            }

            FOpenDialog.FileName = "";
            FOpenDialog.Filter = tmpFilter;


        }

        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void rtConsole_TextChanged(object sender, EventArgs e)
        {

        }

       
        
          

    }
}