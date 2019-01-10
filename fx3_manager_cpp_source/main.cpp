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

/********** Cut and paste the following & modify as required  **********/
static const char *program_name;
static const char *out_filename = "stdout";
static const char *const short_options = "hvV:P:o:";
static const struct option long_options[] = {
		{ "help",	    0, nullptr,	'h'	},
		{ "version",	0, nullptr,	'v'	},
		{ "Vendor",     1, nullptr, 'V' },
		{ "Product",    1, nullptr, 'P' },
		{ "Output",     1, nullptr, 'O' },
		{nullptr,		0, nullptr,	 0	}
};

static int next_option;

static void print_usage(FILE *stream, int exit_code) {
	fprintf(stream, "Usage: %s options\n", program_name);
	fprintf(stream,
		"  -device_handle  --help           Display this usage information.\n"
		"  -v  --version        Print version.\n"
		"  -V  --Vendor		Input Vendor  ID in hexadecimal.\n"
		"  -P  --Product	Input Product ID in hexadecimal.\n"
		"  -o  --output	 	Output file name.\n");

	exit(exit_code);
}
/***********************************************************************/

static FILE *fp = stdout;
static int vendor_provided;
static unsigned short vid;
static int product_provided;
static unsigned short pid;

static void validate_inputs() {
	if ( ((vendor_provided) && (!product_provided)) || ((!vendor_provided) && (product_provided)) ) {
	   fprintf(stderr,"Must provide BOTH VID and PID or leave BOTH blank to pick up from /etc/cyusb.conf\n");
	   print_usage(stdout, 1);
	}
}

void program() {
	MimacUSB3Connection mimacUSB3Connection = MimacUSB3Connection(false, pid, vid);
	char *filename = const_cast<char *>("/home/barrachina/Documents/MIMAC/CYUSB3KIT-003_with_SP605_xilinx/testing_cpp_code/fx3_images/cyfxbulksrcsink.img");
	char *tgt_str = const_cast<char *>("ram");
	mimacUSB3Connection.download_fx3_firmware(filename, tgt_str);
}

int main(int argc, char **argv) {
	bool user_input;
	program_name = argv[0];

	while ( (next_option = getopt_long(argc, argv, short_options, long_options, nullptr) ) != -1 ) {
		switch ( next_option ) {
			case 'h': /* -device_handle or --help  */
				  print_usage(stdout, 0);
			case 'v': /* -v or --version */
				  printf("%s (Ver 1.0)\n", program_name);
				  printf("Copyright (C) 2012 Cypress Semiconductors Inc. / ATR-LABS\n");
				  printf("Modified version 2018 MIMAC gruop LPSC CNRS\n");
				  exit(0);
			case 'o': /* -o or --output */
				  out_filename = optarg;
				  fp = fopen(out_filename,"a");
				  if ( !fp )
				     print_usage(stdout, 1);
				  break;
			case 'V': /* -V or --vendor  */
				  vendor_provided = 1;
				  vid = static_cast<unsigned short>(strtoul(optarg, nullptr, 16));
				  break;
			case 'P': /* -P or --Product  */
				  product_provided = 1;
				  pid = static_cast<unsigned short>(strtoul(optarg, nullptr, 16));
				  break;
			case '?': /* Invalid option */
				  print_usage(stdout, 1);
			default : /* Something else, unexpected */
				  abort();
		}
	}

	validate_inputs();
	user_input = (vendor_provided) && (product_provided);

	try {
	    program();
	    sleep(1);

		MimacUSB3Connection mimacUSB3Connection = MimacUSB3Connection(user_input, pid, vid);
        //mimacUSB3Connection.print_device_descriptor();
        //mimacUSB3Connection.print_config_descriptor();
        //mimacUSB3Connection.claim_interface(0);
        //mimacUSB3Connection.claim_interface(0);
        mimacUSB3Connection.test_performance();
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