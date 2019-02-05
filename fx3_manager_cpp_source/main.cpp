/************************************************************************************************/

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <getopt.h>
#include <string.h>
#include <iostream>

#include "include/cyusb.h"
#include "include/MimacUSB3Connection.h"

using namespace std;

#define VID         0x04B4     /**<USB Vendor ID.*/
#define PID_FX3     0x00f3      /**FX3 Cyusb device */

/********** Cut and paste the following & modify as required  **********/
static const char *program_name;
static const char *out_filename = "stdout";
static const char *const short_options = "hvV:P:o:";
static const struct option long_options[] = {
		{ "help",	    0, nullptr,	'h'	},
		{ "version",	0, nullptr,	'v'	},
		{ "Output",     1, nullptr, 'O' },
		{nullptr,		0, nullptr,	 0	}
};

static int next_option;

static void print_usage(FILE *stream, int exit_code) {
	fprintf(stream, "Usage: %s options\n", program_name);
	fprintf(stream,
		"  -device_handle   --help       Display this usage information.\n"
		"  -v               --version    Print version.\n"
		"  -o               --output	 Output file name.\n");
	exit(exit_code);
}
/***********************************************************************/

static FILE *fp = stdout;


void wait_for_enter(const string &msg = "") {
    cout << msg;
    cout << "press enter to continue..." << endl;
    cin.get();
    //system("read");
}


void program() {
	MimacUSB3Connection mimacUSB3Connection = MimacUSB3Connection();
	//char *filename = const_cast<char *>("/home/barrachina/Documents/MIMAC/CYUSB3KIT-003_with_SP605_xilinx/fx3_manager_cpp_source/fx3_images/cyfxbulksrcsink.img");
	//char *filename = const_cast<char *>("/home/barrachina/Documents/MIMAC/CYUSB3KIT-003_with_SP605_xilinx/fx3_manager_cpp_source/fx3_images/cyfxbulklpautoenum.img");
	char *filename = const_cast<char *>("/home/barrachina/Documents/MIMAC/CYUSB3KIT-003_with_SP605_xilinx/program_fpga/bin/FX3 firmware/ConfigFpgaSlaveFifoSync.img");
	char *tgt_str = const_cast<char *>("ram");
	mimacUSB3Connection.download_fx3_firmware(filename, tgt_str);
    //mimacUSB3Connection.download_fx3_firmware_to_ram(filename);
}

int main(int argc, char **argv) {
	program_name = argv[0];

	while ( (next_option = getopt_long(argc, argv, short_options, long_options, nullptr) ) != -1 ) {
		switch ( next_option ) {
			case 'h': /* -device_handle or --help  */
				  print_usage(stdout, 0);
			case 'v': /* -v or --version */
				  printf("%s (Ver 2.0)\n", program_name);
				  printf("MIMAC group LPSC IN2P3 CNRS (2018)\n");
				  exit(0);
			case 'o': /* -o or --output */
				  out_filename = optarg;
				  fp = fopen(out_filename,"a");
				  if (!fp)
				     print_usage(stdout, 1);
				  break;
			case '?': /* Invalid option */
				  print_usage(stdout, 1);
			default : /* Something else, unexpected */
				  abort();
		}
	}

	try {
	    program();
	    sleep(1);

		MimacUSB3Connection mimacUSB3Connection = MimacUSB3Connection();
		//char *filename = const_cast<char *>("/home/barrachina/Documents/MIMAC/CYUSB3KIT-003_with_SP605_xilinx/fx3_manager_cpp_source/fx3_images/cyfxbulksrcsink.img");
		//char *tgt_str = const_cast<char *>("ram");
		//mimacUSB3Connection.download_fx3_firmware(filename, tgt_str);
        //mimacUSB3Connection.print_device_descriptor();
        //mimacUSB3Connection.print_config_descriptor();
        //mimacUSB3Connection.claim_interface(0);
        //mimacUSB3Connection.test_performance();
        //mimacUSB3Connection.loopback_test();
        wait_for_enter("Please turn on the FPGA and then ");
        char * fpga_filename = const_cast<char *>("/home/barrachina/Documents/MIMAC/CYUSB3KIT-003_with_SP605_xilinx/program_fpga/bin/slaveFIFO2b_fpga_top.bin");
		//char * fpga_filename = const_cast<char *>("/home/barrachina/Documents/MIMAC/CYUSB3KIT-003_with_SP605_xilinx/counter_for_testing.bin");
        //char * fpga_filename = const_cast<char *>("/home/barrachina/Documents/MIMAC/CYUSB3KIT-003_with_SP605_xilinx/program_fpga/fpga_write/fpga_write/fpga_master.bin");
        mimacUSB3Connection.program_device(fpga_filename);
        wait_for_enter();
		mimacUSB3Connection.send_text_file();
    }
	catch (ErrorOpeningLib& e) {
		printf("Error opening library\n");
		return -1;
	}
	catch (NoDeviceFound& e) {
		printf("No device found\n");
		return 0;
	}

	return 0;
}