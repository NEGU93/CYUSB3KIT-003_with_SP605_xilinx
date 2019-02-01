################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := cs-rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
ifneq ($(strip $(ASM_DEPS)),)
-include $(ASM_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
SECONDARY_LIST += \
ConfigFpgaSlaveFifoSync.lst \

SECONDARY_SIZE += \
ConfigFpgaSlaveFifoSync.siz \


# All Target
all: ConfigFpgaSlaveFifoSync.elf secondary-outputs

# Tool invocations
ConfigFpgaSlaveFifoSync.elf: $(OBJS) $(USER_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: ARM Sourcery Windows GCC C Linker'
	arm-none-eabi-gcc $(OBJS) $(USER_OBJS) $(LIBS) -T"C:\Program Files (x86)\Cypress\EZ-USB FX3 SDK\1.3\/firmware/common/fx3.ld" -nostartfiles -Wl,-Map,ConfigFpgaSlaveFifoSync.map -Wl,-d -Wl,--no-wchar-size-warning -Wl,--entry,CyU3PFirmwareEntry "C:\Program Files (x86)\Cypress\EZ-USB FX3 SDK\1.3\\firmware\u3p_firmware\lib\fx3_release\cyfxapi.a" "C:\Program Files (x86)\Cypress\EZ-USB FX3 SDK\1.3\\firmware\u3p_firmware\lib\fx3_release\cyu3lpp.a" "C:\Program Files (x86)\Cypress\EZ-USB FX3 SDK\1.3\\firmware\u3p_firmware\lib\fx3_release\cyu3threadx.a"  "C:\Program Files (x86)\Cypress\EZ-USB FX3 SDK\1.3\ARM GCC\\arm-none-eabi\lib\libc.a" "C:\Program Files (x86)\Cypress\EZ-USB FX3 SDK\1.3\ARM GCC\\lib\gcc\arm-none-eabi\4.8.1\libgcc.a" -mcpu=arm926ej-s -mthumb-interwork -o"ConfigFpgaSlaveFifoSync.elf"
	@echo 'Finished building target: $@'
	@echo ' '
	$(MAKE) --no-print-directory post-build

ConfigFpgaSlaveFifoSync.lst: ConfigFpgaSlaveFifoSync.elf
	@echo 'Invoking: ARM Sourcery Windows GNU Create Listing'
	arm-none-eabi-objdump -h -S ConfigFpgaSlaveFifoSync.elf > "ConfigFpgaSlaveFifoSync.lst"
	@echo 'Finished building: $@'
	@echo ' '

ConfigFpgaSlaveFifoSync.siz: ConfigFpgaSlaveFifoSync.elf
	@echo 'Invoking: ARM Sourcery Windows GNU Print Size'
	arm-none-eabi-size  --format=berkeley ConfigFpgaSlaveFifoSync.elf
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(SECONDARY_SIZE)$(OBJS)$(C_DEPS)$(ASM_DEPS)$(EXECUTABLES)$(SECONDARY_LIST)$(S_UPPER_DEPS) ConfigFpgaSlaveFifoSync.elf
	-@echo ' '

post-build:
	-@echo 'Converting ELF to image (.img) format'
	-elf2img.exe -i ConfigFpgaSlaveFifoSync.elf -o ConfigFpgaSlaveFifoSync.img
	-@echo ' '

secondary-outputs: $(SECONDARY_LIST) $(SECONDARY_SIZE)

.PHONY: all clean dependents
.SECONDARY: post-build

-include ../makefile.targets
