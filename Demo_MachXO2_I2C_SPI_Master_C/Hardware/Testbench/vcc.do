@echo "Building ECP3 Versa LM8 Sim top"
set sim_working_folder .

alog -sv2k5 -incr pmi/pmi_distributed_dpram.v
alog -sv2k5 -incr pmi/pmi_distributed_spram.v
alog -sv2k5 -incr pmi/pmi_addsub.v
alog -sv2k5 -incr pmi/pmi_ram_dp.v
alog -sv2k5 -incr pmi/pmi_ram_dq.v
alog -sv2k5 -incr pmi/pmi_rom.v

alog -sv2k5 -incr pmi/pmi_fifo_dc.v
alog -sv2k5 -incr pmi/pmi_fifo.v

alog -v2k -incr +define+SIMULATION +incdir+models models/24FC128.v 
alog -v2k -incr +define+SIMULATION +incdir+models models/AT25DQ041.v 

alog -v2k -incr +define+SIMULATION +incdir+../mico8/soc+../mico8/components/lm8/rtl/verilog ../mico8/soc/mico8.v 
alog -v2k -incr +define+SIMULATION +incdir+../IPCore/myEFB ../IPCore/myEFB/myEFB.v 

alog -sv2k5  -incr +define+SIMULATION +incdir+../Source+../Source/PicoLCDDriver ../Source/PicoLCDDriver/lcd4digit.v
alog -sv2k5  -incr +define+SIMULATION +incdir+../Source+../Source/PicoLCDDriver ../Source/PicoLCDDriver/LCDCharMap.v
alog -sv2k5  -incr +define+SIMULATION +incdir+../Source+../Source/PicoLCDDriver ../Source/PicoLCDDriver/LCDCharMapLUTs.v
alog -sv2k5  -incr +define+SIMULATION +incdir+../Source+../Source/PicoLCDDriver ../Source/PicoLCDDriver/LCDEncoding4to1.v
alog -sv2k5  -incr +define+SIMULATION +incdir+../Source+../Source/PicoLCDDriver ../Source/PicoLCDDriver/LCDEncoding4to1com.v
alog -sv2k5  -incr +define+SIMULATION +incdir+../Source+../Source/PicoLCDDriver ../Source/PicoLCDDriver/pwm.v
alog -sv2k5  -incr +define+SIMULATION +incdir+../Source+../Source/PicoLCDDriver ../Source/PicoLCDDriver/PicoLCDdriver.v

alog -sv2k5  -incr +define+SIMULATION +incdir+../Source+../mico8/soc+../mico8/components/lm8/rtl/verilog ../Source/wb2lcd.v
alog -sv2k5  -incr +define+SIMULATION +incdir+../Source+../mico8/soc+../mico8/components/lm8/rtl/verilog ../Source/XO2_top.v


alog -sv2k5  -incr +incdir+../implementation+../mico8/soc+../mico8/components/lm8/rtl/verilog+../mico8/soc sim_top.v
