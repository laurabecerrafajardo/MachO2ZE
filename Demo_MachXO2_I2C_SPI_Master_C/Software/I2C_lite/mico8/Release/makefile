.PHONY: clean
.PHONY: platform_directory.phny

LIBRARY_C_SRCS=
LIBRARY_CXX_SRCS=
LIBRARY_ASM_SRCS=
LIBRARY_INCLUDE_PATH=
INCLUDE_PATH=
#declare C sources needed for archive
C_SRCS += 		DDInit.c	\
		DDStructs.c	\
		MicoStdStreams.c	\




OUTPUT_DIR = $(PLATFORM_LIBRARY_OUTPUT_DIR)
INCLUDE_PATH +=.
#include other makefiles
include drivers.mk
include inherited_settings.mk
include linker_settings.mk
include platform_rules.mk



C_SRCS +=$(LIBRARY_C_SRCS)
CXX_SRCS +=$(LIBRARY_CXX_SRCS)
ASM_SRCS +=$(LIBRARY_ASM_SRCS)
INCLUDE_PATH +=$(LIBRARY_INCLUDE_PATH)
VPATH +=.. $(LIBRARY_VPATH) ./$(LIBRARY_VPATH)/..



#include building-rules makefile
include ../../../../Hardware/mico8/soc/../components/lm8/gnu/gnu_rules.mk

#Targets for this library..
all: platform_directory.phny $(OUTPUT_DIR)/lib$(PLATFORM_LIBRARY_NAME).a

clean:
	@echo cleaning...
	rm -f $(OUTPUT_DIR)/*.o
	rm -f $(OUTPUT_DIR)/lib$(PLATFORM_LIBRARY_NAME).a

platform_directory.phny:
	@mkdir -p $(OUTPUT_DIR)

$(OUTPUT_DIR)/lib$(PLATFORM_LIBRARY_NAME).a : $(ARCHIVE_OBJS)
	@echo creating $@...
	@$(AR) $(ARFLAGS) $@ $(ARCHIVE_OBJS)

DEPS += \
${addprefix $(OUTPUT_DIR)/, \
DDInit.d \
DDStructs.d \
MicoInterrupts.d \
MicoPassthru.d \
MicoUart.d \
}
ifneq ($(strip $(DEPS)),)
-include $(DEPS)
endif
