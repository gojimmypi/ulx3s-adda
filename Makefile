PROJ = ulx3s_adda
PIN_DEF = ulx3s_v20.lpf
DEVICE = up5k

ARACHNE = arachne-pnr 
ARACHNE_ARGS = 
# ICEPACK = ecppack
# ICEPACK = icepack
ICETIME = icetime
ICEPROG = ../f32c_tools/ujprog/ujprog.exe
IS_WSL = 0  

 

# Verilator

TOPMOD  := ulx3s_adda
VLOGFIL := $(TOPMOD).v
VCDFILE := $(TOPMOD).vcd
SIMPROG := $(TOPMOD)_tb
RPTFILE := $(TOPMOD).rpt
BINFILE := $(TOPMOD).bin
SIMFILE := $(SIMPROG).cpp
VDIRFB  := ./obj_dir
#COSIMS  := uartsim.cpp

SHELL=bash


all: $(VCDFILE)

GCC := g++
CFLAGS = -g -Wall -I$(VINC) -I $(VDIRFB)
#
# Modern versions of Verilator and C++ may require an -faligned-new flag
# CFLAGS = -g -Wall -faligned-new -I$(VINC) -I $(VDIRFB)

VERILATOR=verilator
VFLAGS := -O3 -MMD --trace -Wall

## Find the directory containing the Verilog sources.  This is given from
## calling: "verilator -V" and finding the VERILATOR_ROOT output line from
## within it.  From this VERILATOR_ROOT value, we can find all the components
## we need here--in particular, the verilator include directory
VERILATOR_ROOT ?= $(shell bash -c '$(VERILATOR) -V|grep VERILATOR_ROOT | head -1 | sed -e "s/^.*=\s*//"')
##
## The directory containing the verilator includes
VINC := $(VERILATOR_ROOT)/include

$(VDIRFB)/V$(TOPMOD).cpp: $(TOPMOD).v
	$(VERILATOR) $(VFLAGS) -cc $(VLOGFIL)

$(VDIRFB)/V$(TOPMOD)__ALL.a: $(VDIRFB)/V$(TOPMOD).cpp
	make --no-print-directory -C $(VDIRFB) -f V$(TOPMOD).mk

$(SIMPROG): $(SIMFILE) $(VDIRFB)/V$(TOPMOD)__ALL.a $(COSIMS)
	$(GCC) $(CFLAGS) $(VINC)/verilated.cpp				\
		$(VINC)/verilated_vcd_c.cpp $(SIMFILE) $(COSIMS)	\
		$(VDIRFB)/V$(TOPMOD)__ALL.a -o $(SIMPROG)

test: $(VCDFILE)

$(VCDFILE): $(SIMPROG)
	./$(SIMPROG)






##
## Find all of the Verilog dependencies and submodules
##
DEPS := $(wildcard $(VDIRFB)/*.d)

## Include any of these submodules in the Makefile
## ... but only if we are not building the "clean" target
## which would (oops) try to build those dependencies again
##
ifneq ($(MAKECMDGOALS),clean)
ifneq ($(DEPS),)
include $(DEPS)
endif
endif


# main build
all: $(PROJ).bit
	@printf "\n\n $(PROJ).bit done! \n\n"
	ls $(PROJ).bit -al

 

%.bit: $(PROJ).out.config
	@printf "\n\n bit ecppack...\n\n"
	ecppack $(PROJ).out.config $(PROJ).bit --idcode 0x21111043
	grep -i warning $(PROJ).nextpnr-ecp5.log
	grep -i warning $(PROJ).yosys.log

%.out.config: $(PROJ).json
	@printf "\n\n nextpnr-ecp5 config... \n\n "
	nextpnr-ecp5 --25k --json $(PROJ).json  \
		--lpf ulx3s_v20.lpf \
		--textcfg $(PROJ).out.config --log  $(PROJ).nextpnr-ecp5.log
		

%.json: $(PROJ).ys $(PROJ).v
	@printf "\n\n yosys ... \n\n "
	yosys $(PROJ).ys | tee $(PROJ).yosys.log

#%.blif: %.v
	#printf "yosys..."
	#read continue
	#yosys -p 'synth_ice40 -top top -blif $@' $<

#%.asc: $(PIN_DEF) %.blif
	#echo "$(ARACHNE) $(ARACHNE_ARGS) -d $(subst up,,$(subst hx,,$(subst lp,,$(DEVICE)))) -o $@ -p $^"
	#printf "asc..."
	#read continue
	#$(ARACHNE) $(ARACHNE_ARGS) -d $(subst up,,$(subst hx,,$(subst lp,,$(DEVICE)))) -o $@ -p $^


%.bin: %.asc
	@printf "bin..."
	$(ICEPACK) $< $@

%.rpt: %.asc
	$(ICETIME) -d $(DEVICE) -mtr $@ $<

prog: $(PROJ).bit
	$(ICEPROG)  $<

sudo-prog: $(PROJ).bin
	@echo 'Executing prog as root!!!'
	sudo $(ICEPROG) $<

clean:
	rm -rf $(VDIRFB)/ $(SIMPROG) $(VCDFILE) blinky/ $(BINFILE) $(RPTFILE)
	rm -f $(PROJ).blif $(PROJ).asc $(PROJ).rpt $(PROJ).bit $(PROJ).json $(PROJ).out.config $(PROJ).nextpnr-ecp5.log $(PROJ).yosys.log

sim: 
	rm -f $(PROJ).vcd
	iverilog  -o $(PROJ).vvp $(PROJ).v $(PROJ)_tb.v
	vvp $(PROJ).vvp
	export DISPLAY=:0

## if we are running in WSL, we need a bit of help for GUI XWindows: copy .Xauthority file locally.
## sometimes the WSL username is not the same as the Windows username, and we need the windows user path.
## this is the Windows %USER% environment variable when called from makefile: $(shell cmd.exe /c "echo $$USER")
	@if [ "$(shell grep Microsoft /proc/version)" != "" ]; then   \
		cp /mnt/c/cygwin64/home/$(shell cmd.exe /c "echo $$USER")/.Xauthority   ~/.Xauthority; \
    fi

	(gtkwave $(PROJ).vcd $(PROJ)_savefile.gtkw)&

xserver:
## launch the Windows cygwin64 startxwin when WSL iss detected
	@if [ "$(shell grep Microsoft /proc/version)" != "" ]; then   \
		echo "Launching Windows XServer from WSL...";             \
		(/mnt/c/cygwin64/bin/run.exe --quote /usr/bin/bash.exe -l -c " exec /usr/bin/startxwin -- -listen tcp -nowgl")&  \
	else                                                          \
		echo "Not launching WSL XServer!" ;                                             \
    fi

.SECONDARY:
.PHONY: all prog clean