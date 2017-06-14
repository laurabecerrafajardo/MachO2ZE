Running Simulations
===================

To start ActiveHDL, open DOS window in this directory
and run: 
	c:> avhdl
-OR-
	double click the start_AVHDL icon (note: the shortcut expects Diamond 1.4 installation)


When ActiveHDL opens, use the Console window pane at the bottom of the
tool to enter the following commands to compile and run.


The very first time create the simulation workspace with:
	createdesign work .
	cd ..


Subsequent times:
	do init.do


To compile design:
	do vcc.do


To Simulate design:
	do sim.do
	do i2c_waves.do  or spi_waves.do depending on software build (to load waveform viewer)
	run 200 us


To clear all libraries and build fresh:
	adel -lib work -all