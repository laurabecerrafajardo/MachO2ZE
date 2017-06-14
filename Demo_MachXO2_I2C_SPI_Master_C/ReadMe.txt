MachXO2 Master SPI/I2C Demo Using ‘C’ and LatticeMico8


Introduction
=============

The MachXO2™ LatticeMico8™ Temperature Logging Demo uses a MachXO2 Pico Evaluation Board to read the temperature and display it on the LCD screen and also in a terminal window on a PC. The temperature is obtained from an I2C temperature sensor device on the evaluation board. The temperature readings can also be logged into SPI Flash memory for later recall.

The purpose of the demo is to:
1.Demonstrate use of the MachXO2 Embedded Function Block (EFB) I2C and SPI Master controllers
2.Demonstrate I2C and SPI drivers written in ‘C’
3.Demonstrate LatticeMico8 application software written in ‘C’



Version History
===============
Version: 1.0  April 2012


Directories
===========

Bitstreams\
Prebuilt JEDEC file to load into XO2 to immediately run demo


Documentation\
User GUide, eval board guide and other relevant device documentation


Hardware\
Location of Diamond project, RTL source and MSB platform


Software\
Location of LM8 C projects to load into Mico System C/C++


Workspace\
Default Mico System workspace directory.  See ReadMe.txt in this directory for details on
importing projects into MSB.


Development Flow
================

1.) Open Diamond and open Hardware\Implementation\Diamond_1.4\XO2_Pico.ldf
2.) Open Lattice Mico System and use Workspace as the workspace directory
	See readme.txt in Workspace for instructions on importing.
3.) Build MSB platform and software projects
4.) Deploy software to memory init files
5.) Build JEDEC
6.) Load JEDEC file into XO2
7.) Use Terminal emulator software to access demo menus on XO2 board






