PROJ = ulx3s-adda
PIN_DEF = ulx3s_v20.lpf
DEVICE = up5k

ARACHNE = arachne-pnr 
ARACHNE_ARGS = 
ICEPACK = icepack
ICETIME = icetime
ICEPROG = ../f32c_tools/ujprog/ujprog.exe

all: $(PROJ).bit
	@printf "$(PROJ).bit done!"
	ls $(PROJ).bit -al

 

%.bit: $(PROJ).out.config
	@printf "bit..."
	ecppack $(PROJ).out.config $(PROJ).bit --idcode 0x21111043

%.out.config: $(PROJ).json
	@printf "config..."
	nextpnr-ecp5 --25k --json $(PROJ).json  \
		--lpf ulx3s_v20.lpf \
		--textcfg $(PROJ).out.config --log  $(PROJ).nextpnr-ecp5.log
		

%.json: $(PROJ).ys $(PROJ).v
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
	grep -i warning $(PROJ).nextpnr-ecp5.log
	grep -i warning $(PROJ).yosys.log
	$(ICEPROG)  $<

sudo-prog: $(PROJ).bin
	@echo 'Executing prog as root!!!'
	sudo $(ICEPROG) $<

clean:
	rm -f $(PROJ).blif $(PROJ).asc $(PROJ).rpt $(PROJ).bit $(PROJ).json $(PROJ).out.config $(PROJ).nextpnr-ecp5.log $(PROJ).yosys.log

.SECONDARY:
.PHONY: all prog clean