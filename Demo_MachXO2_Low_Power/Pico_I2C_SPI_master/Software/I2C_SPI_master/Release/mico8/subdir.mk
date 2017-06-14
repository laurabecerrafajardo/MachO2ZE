################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
$(ROOT)/mico8/DDInit.c \
$(ROOT)/mico8/DDStructs.c \
$(ROOT)/mico8/MicoInterrupts.c \
$(ROOT)/mico8/MicoPassthru.c \
$(ROOT)/mico8/MicoStdStreams.c \
$(ROOT)/mico8/MicoUart.c \
$(ROOT)/Mico8Interrupts.c

DEPS += \
${addprefix ./mico8/, \
DDInit.d \
DDStructs.d \
MicoInterrupts.d \
MicoPassthru.d \
MicoSleepHelper.d \
MicoStdStreams.d \
MicoUart.d \
crt0.d \
}


ASM_SRCS += \
$(ROOT)/mico8/MicoSleepHelper.S \
$(ROOT)/mico8/crt0.S