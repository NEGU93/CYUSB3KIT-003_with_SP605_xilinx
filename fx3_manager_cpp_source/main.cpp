/************************************************************************************************/

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <getopt.h>
#include <string.h>
#include <iostream>

#include "include/cyusb.h"
#include "include/FX3USB3Connection.h"

using namespace std;

#define VID         0x04B4     	/* <USB Vendor ID.*/
#define PID_FX3     0x00f3     	/* FX3 Cyusb device */
#define PID_FX1     0x00f1		/* PID after programming */
#define PID_FPGA    0x00bc     	/* PID when FPGA on */

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
	FX3USB3Connection fx3USB3Connection = FX3USB3Connection();
	/*if (fx3USB3Connection.reset_board() != 0) {
		printf("Failed to reset FX3 device");
		exit(-1);
	}*/
	//char *filename = const_cast<char *>("fx3_images/cyfxbulksrcsink.img");
	//char *filename = const_cast<char *>("fx3_images/cyfxbulklpautoenum.img");
	char *filename = const_cast<char *>("../program_fpga/bin/FX3 firmware/ConfigFpgaSlaveFifoSync_32.img");
	char *tgt_str = const_cast<char *>("ram");
	if (fx3USB3Connection.download_fx3_firmware(filename, tgt_str) != 0) {
		printf("Failed to program FX3 device");
		exit(-1);
	}
	//fx3USB3Connection.download_fx3_firmware(filename, tgt_str);
    //fx3USB3Connection.download_fx3_firmware_to_ram(filename);
}

int main(int argc, char **argv) {
	program_name = argv[0];

	while ( (next_option = getopt_long(argc, argv, short_options, long_options, nullptr) ) != -1 ) {
		switch ( next_option ) {
			case 'h': /* -device_handle or --help  */
				  print_usage(stdout, 0);
			case 'v': /* -v or --version */
				  printf("%s (Ver 2.0)\n", program_name);
				  printf("Jose Agustin Barrachina. GitHub: NEGU93 (2018)\n");
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

		FX3USB3Connection fx3USB3Connection = FX3USB3Connection(VID, PID_FX1);
        //fx3USB3Connection.print_device_descriptor();
        //fx3USB3Connection.print_config_descriptor();
        //fx3USB3Connection.claim_interface(0);
        //fx3USB3Connection.test_performance();
        //fx3USB3Connection.loopback_test();
        //wait_for_enter("Please turn on the FPGA and then ");
        char * fpga_filename = const_cast<char *>("../program_fpga/bin/slaveFIFO2b_fpga_top.bin");
        //char * fpga_filename = const_cast<char *>("../com_fpga//fpga_source_code/fpga_slavefifo2b_vhdl/fx3_slavefifo2b_vhdl_proj/slaveFIFO2b_fpga_top.bin");
		//char * fpga_filename = const_cast<char *>("../counter_for_testing.bin");
		fx3USB3Connection.program_device(fpga_filename);
        //wait_for_enter();
		sleep(3);
        fx3USB3Connection.send_text_file();
		//printf("\nReseting Device");
		//fx3USB3Connection.reset_board();
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