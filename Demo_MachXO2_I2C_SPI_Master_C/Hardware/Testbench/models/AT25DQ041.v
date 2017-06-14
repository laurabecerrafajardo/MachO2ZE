//--------------------------------------------------------------------------
// This is the property of PERFTRENDS TECHNOLOGIES PRIVATE LIMITED and
// possession or use of file has to be with the written LICENCE AGGREMENT
// from PERFTRENDS TECHNOLOGIES PRIVATE LIMITED.
//
//--------------------------------------------------------------------------
//
// Project : ATMEL Data Flash Device
//--------------------------------------------------------------------------
// File 	: $RCSBfile: AT25DQ041.v,v $
// Path 	: $Source: /home/cvs/atmel_flash_dev/serial_flash/AT25DF/design/verilog/AT25DF041.v,v $
// Author 	: $ D. Nguyen $
// Created on 	: $ 02-26-2009 $
// Revision 	: $Revision: 1.1 $
//--------------------------------------------------------------------------
// Module 		: AT26DF041.v
// Description 	: BFM for devices  AT25DF041
//
//--------------------------------------------------------------------------
//
// Design hierarchy : _top.v/top_1.v/top_2.v/...
// Instantiated Modules : top_1.v, top_2.v
//--------------------------------------------------------------------------
// Revision history :
// $Log: AT25DF041.v_v1.0,v $
//
// Revision 1.1  03/12/2009  dnguyen
// 1st update  		 
//
// Revision 1.0  02/26/2009  dnguyen 
// initial model for AT25DQ041
//
//--------------------------------------------------------------------------

module AT25DQ041 (
		CSB,
		SCK,
		SI,
		WPB,
          SO,
          HOLDB,
          VCC,
          GND
		);

// ******************************************************************** //
//			Port Declaration:
// ******************************************************************** //

input 	CSB;		// Chip Select!
input	SCK;		// Serial Clock
inout   SI ;	        // Bidirectional signal
inout   SO ;            // Bidirectional Signal
input   HOLDB;          // Hold or Bidirection Signal 
//inout   HOLDB;          // Hold or Bidirection Signal 
input   VCC;
input 	GND;
inout	WPB;		// Write Protect or Bidirection Signal

/**********************************************************************
Memory & Registers PreLoading Parameters:
=============================
These parameters are related to Memory and Registers Preloading.
Memory, Sector Lock-down Register, Freeze Sector Lock-down State Register  and
Security Register can be preloaded, in Hex format.

To pre-load Memory (in Hex format), define parameter
MEMORY_FILE = <filename>, where <filename> is the name of
the pre-load file.
If MEMORY_FILE = "", the Memory is initialized to Erased state (all data = FF).
If the memory is initialized, the status of all pages will be Not-Erased.

To pre-load Sector Lock-down Register (in Hex format), define parameter
LOCKDOWN = <filename>, where <filename> is the name of the
pre-load file.
If LOCKDOWN = "", all sectors are initially in the Unlocked state
(all data = 00).

To pre-load Freeze Sector Lock-down State Register (in Hex format), define parameter
FREEZE_LOCKDOWN_STATE= <filename>, where <filename> is the name of the
pre-load file.
If FREEZE_LOCKDOWN_STATE = "", the Freeze Sector Lockdown State is not permanently disabled  
(data = 00).

To pre-load Security Register (only the User Programmable Bytes 0 to 63),
define parameter SECURITY = <filename>, where <filename> is the name
of the pre-load file.
If SECURITY = "", the register is initialized to erased state (all data = FF).

The Factory Programmed Bytes 64 to 127 are always initialized by defining
parameter FACTORY = "factory.txt". As the Factory Programmed Bytes are
accessible to the user for read, a sample of "factory.txt" file
needs to be included in the Verilog Model directory.


**********************************************************************/
parameter DEVICE = "AT25DQ041";
parameter PRELOAD = 0;									// Preload  
parameter MEMORY_FILE = "memory.txt";							// Memory pre-load
parameter LOCKDOWN = "lockdown.txt";							// Sector Lock-down pre-load
parameter FREEZE_LOCKDOWN_STATE = "freeze_lockdown_state.txt";				// Freeze Lockdown State pre-load
parameter SECURITY = "security.txt";							// Security Register Bytes[0:63] pre-load
parameter FACTORY = "factory.txt";							// Security Register Bytes[64:127]  
parameter CONFIGURATION_REGISTER = "configuration_register.txt";			// Configuration Register

// ********************************************************************* //
//Timing Parameters :
// ******************************************************************** //

// Fixed parameters
parameter fSCK    = 100;	// Serial clock (SCK) Frequency in MHz
parameter fRDLF   = 50;		// SCK Frequency for read Array (Low freq - 03h opcode)
//representation in ns
parameter tSCKH   = 4.3;	// Clock High Time
parameter tSCKL   = 4.3;	// Clock Low Time
parameter tDIS    = 5;		// Output Disable time
parameter tV      = 5;	        // Output Valid time
parameter tOH     = 2 ;		// Output Hold time

parameter tHLQZ   = 5 ;		// HOLD! Low to Output High-z
parameter tHHQX   = 5 ;		// HOLD! High to Output Low-z

parameter tSECP   = 20;		// Sector Protect Time
parameter tSECUP  = 20;		// Sector Unprotect Time
parameter tLOCK   = 200000;	// Sector Lockdown and Freeze Sector Lockdown State Time

parameter tEDPD   = 1000;	// Chip Select high to Deep Power-down (1 us max)
parameter tRDPD   = 30000;	// Chip Select high to Stand-by Mode
parameter tRST    = 30000;	// Reset Memory Program/Erase Operation Time

parameter tPP     = 1000000;	// Page Program Time
parameter tBP     = 7000;	// Byte Program Time
parameter tBLKE4  = 50000000;	// Block Erase Time 4-kB
parameter tBLKE32 = 250000000;	// Block Erase Time 32-kB
//parameter tBLKE64 = 400000000;	// Block Erase Time 64-kB
parameter tBLKE64 = 4000;	// Block Erase Time 64-kB
parameter tCHPEn  = 1000000000;	// Spec. time is 64s	
parameter tCHPE   = 64 * tCHPEn;
parameter tSUSP   = 10000 ;		// Program/Erase Suspend Time 
parameter tRES    = 10000 ;		// Program/Erase Resume Time 
parameter tOTPP   = 200000;		// OTP Security Register Program Time 
parameter tWRSR   = 20;			// Write Status Register Time
parameter tWRCR   = 20000000;		// Write Configuration Register 

parameter tVCSL = 50000;     		// Minimum VCC to chip select Low time 
parameter tPUW = 10000000;   		// Minimum VCC to chip select Low time 
// variable parameters
// ********************** Manufacturer ID ********************** //
parameter [39:0] MAN_ID = 	40'h1F_84_00_01_00 ;

// ********* Memory And Access Related Declarations ***************** //
parameter MADDRESS =  19; 			
parameter SECTORS =  8;
parameter time_10ns = 10;	// => tMAX  - 100MHz
parameter time_12ns = 12;	// => tRDDO - 85MHz
parameter time_20ns = 20;	// => tRDLF - 50MHz
reg tMAX;
reg tRDDO;
reg tRDLF;  

// total memory size = no. of blocks * 64 k bits (i.e each block contains 64 KB)
parameter MEMSIZE = SECTORS * 256 * 256; 	// total memory size
reg [7:0] memory [MEMSIZE-1:0]; 		// memory of selected device

reg [7:0] factory_reg[63:0];			// factory programmed security register
reg [7:0] security_reg[63:0];			// security register
reg [7:0] OTP_reg [127:0];			// factory & security register 

reg [7:0] lock_reg [SECTORS-1:0];		// Sector Lock-down reg

reg security_flag;
reg [SECTORS-1:0] lock_status;			// 0 means sector unlocked, 1 locked-down
reg [SECTORS-1:0] prot_status; 			// 0 means sector unprotected, 1 unprotected

reg [7:0] status_reg1;				// Status register Byte 1
reg [7:0] status_reg2;        			// Stautus register Byte 2
wire [15:0] status_reg;      			// Stautus registers 
reg [7:0] CFG_reg;				// Configuration register
reg [7:0] Config_reg[0:0];			//  
reg [7:0] int_buffer [255:0];	// internal buffer to store data in page programming mode
reg [7:0] OTP_buffer [63:0];	// internal buffer to store data in page programming mode
// ****************** ***************** ***************** //


// ********* Registers to track the current operation of the device ******** //
reg deep_power_down;		// Device in Deep Power Down Mode
reg erasing_block4;		// 4kB block erase
reg erasing_block32;		// 32kB block erase
reg erasing_block64;		// 64kB block erase
reg erasing_chip;		// chip erase
reg byte_prog;			// Byte/page programming
reg otp_sec_prog;			// otp security program 
reg dual_byte_prog;
reg quad_byte_prog;
reg sec_lockdown;
reg Freez_sec_lockdown;
reg overflow;
reg dual_mode;
reg quad_mode;
reg sec_loc;
reg [5:0] sckcnt;		// SPI clock counter 
reg cmd_1byte;		// 1byte 
reg cmd_2byte;		// 2byte 
reg cmd_4byte;		// 4byte 
reg cmd_5byte;		// 5byte 
reg abort;			// abort register
reg abort_boundary;
reg abort_holdb;
reg reset_exit;		// Reset Exit register
reg reset_request;		// Reset request register
reg reset;
reg HOLD_EN;			// 
reg	dout_phase;		//
reg	dummy_phase;		//

// ********* Events to trigger some task based on opcode *********** //
event  EDPD;		// Deep Power-down (enable)
event  RDPD;		// Resume from Deep Power-down
event  RA;		// Read Array
//event  RAL;		// Read Array (Low frequency)
event  BE4;		// Block Erase 4KB
event  BE32;		// Block Erase 32KB
event  BE64;		// Block Erase 64KB
event  CE;		// Chip Erase
event  BP;		// byte /page program
event  SLD;		// Sector Lock Down
event  FSL;		// Freeze Sector Lock Down
event  RSLR;		// Read Sector Lock Down
event  WE;		// Write Enable
event  WD;		// Write Disable
event  PS;		// Protect Sector
event  UPS;		// Un-Protect Sector
event  RSPR;		// Read Sector Protection Register
event  RSR;		// Read Status Register
event  WSR1;		// Write Status Register
event  WSR2;		// Write Status Register byte 2
event  MIR;		// Manufacturer ID Read
event  POSR;       	// Program OTP Security Register
event  ROSR;       	//Read Otp Register
event  RST;             	//Reset command
event  DORA;            	//Dual Output read array
event  DIPG;            	//Dual Input Page Programe
event  RCFGR;			// Read Configuration Register
event  WCFGR;			// Write Configuration Register
event  QIPG;            	//Quad Input Page Programe
event  QORA;            	//Quad Output read array
/******** Other variables/registers ******************/
reg [7:0] read_data;		// register in which opcode/data is read-in
reg [23:0] temp_addr;		// to store mem address temporarily
reg [7:0] con_byte;		// to store confirmation byte temporarily
reg [7:0] config_byte;		// to store configuration byte temporarily
reg [23:0] current_address;	// to store mem address
reg [23:0] specific_address;	// specific address fo Freeze Sector Lockdown State
reg [7:0] buffer_address;	//
reg [7:0] temp_data;		// temp read data from memory
reg [7:0] data_in; 		// data in for byte programming
reg [7:0] read_dummy;		// register in which dont care data is stored
reg [3:0] stat_reg_temp;	// WSR temp value for global protec/unprotect
reg [1:0] stat_reg_temp1;	// WSR1 temp value for RSTE/SLE
reg [7:0] pp_address;		// specifies the page address for BP/PP
reg [12:0] erase_start_4;		// specifies the page address for BP/PP
reg [15:0] erase_start_32;		// specifies the page address for BP/PP
reg [16:0] erase_start_64;		// specifies the page address for BP/PP
reg [5:0] OTP_address;		// specifies the page address for Program OTP (64 bytes only) 
reg [6:0] OTP_rd_address;	// specifies the page address for Read OTP Security Registers
reg SO_reg;		        	// Signal out reg
reg SI_reg;		        	// Signal out reg
reg HOLDB_reg;				// Signal out reg
reg WPB_reg;				// Signal out reg
reg WPB_Int;
reg SI_on;			// Signal out enable signal For IO0
reg SO_on;			// Signal out enable signal For IO1
reg WPB_on;			// Signal out enable signal For IO2 
reg HOLDB_on;			// Signal out enable signal For IO3 
reg con_;			// Signal for confirmation byte received
reg SPRL;			// Sector Protection Register Locked
reg SPM;			// Sequential Program Mode Status
reg EPE;			// Erase/Program Error
reg WPP;			// Write Protection Pin Status
reg [1:0] SWP;			// Software Protection Status
reg RSTE;                // Reset Enabled
reg SLE;                 //Sector Lock Down Enabled
reg WEL;				// Write Enable Latch Status
reg QE;				// Quad Enable bit
reg RDYnBSY;			// Ready/Busy Status
reg lock;				// to lock SPRL bit of status reg
reg unlock;			// to unlock SPRL bit of status reg
reg global_protect;		// global protection
reg global_unprotect;	// global unprotect
reg protect;			// to protect Sector reg bits
reg sect_lock_flag;		// Sector Lockdown Flag for Chip Erase  
reg sect_locked;		     // Sector lockdown   
reg unprotect;			// to unprotect Sector reg bits
reg protected;			// check protection status of sector reg
reg SPRL_val;			// WSR temp value for SPRL
reg mem_initialized;		//
reg foreground_op_enable, background_op_enable;
reg sdindual_en;		// dual input enable reg
reg sdinquad_en;		// quad input enable reg
integer j;		     // integers for accessing memory
integer pp;			// specifies no of bytes need to write in memory
integer pp_j;			// holds no of bytes received for OTP page program
integer pp_h;			// holds no of bytes received for page program
integer pp_i;			// holds no of bits received for each byte in page program
integer pp_latched;			// holds no of bits received for each byte in page program
integer pp_start;			// holds no of bits received for each byte in page program
integer rd_dummy;		// counter for receiving 8 dummy bit from SO
integer delay;			// waits for Chip Erase to complete
integer h;
integer z;
integer i;
integer a;

real tperiod;				// time period - on period
real tperiod1;				// time period - off period
reg freq_error;			// frequency limit exceeds indication
reg [5:0]int_address;         // internal address for OTP
reg [7:0] Freez_lockdown[0:0];// Freeze Sector Lockdown State Register
reg Freez_sector_lockdown;	//
reg fRDA2; 
reg[23:0] erase_i;       
reg [11:0]erase4_i;
real clk_val;
real clk_val_d;
real clk_diff;
reg full_page; 
reg OE;
wire CLK;
reg vcc_reg;
wire power_en; 

// ****************** Initialize **************** //
initial
begin
    	// start with erased state
    	// Memory Initialization

	for (j=0; j<MEMSIZE; j=j+1)   	// Pre-initiazliation to Erased
  	begin                        	// state is useful if a user wants to
    		memory[j] = 8'hff;       // initialize just a few locations.
  	end
  	mem_initialized = 1'b0;

   	// Now preload, if needed
	//if (MEMORY_FILE != "")
	if (PRELOAD == 1'b1)
  	begin
     	$readmemh(MEMORY_FILE, memory);
     	mem_initialized = 1;
  	end


 	// Initialize lock-down, freeze-lockdown state and security registers

  	for (j=0; j<SECTORS; j=j+1)
  	begin
    		lock_reg[j] = 8'h00;
  	end

	Freez_lockdown[0] = 8'h00;

	Config_reg[0] = 8'hFF;

  	for (j=0; j<64; j=j+1)
  		security_reg[j] = 8'hFF;
  	security_flag = 1'b0;

  	// Pre-load lock-down registers, freeze sector lockdown and security registers if needed
  	//if (LOCKDOWN !="")
  	if (PRELOAD==1'b1)
     	$readmemh(LOCKDOWN, lock_reg);

  	//if (FREEZE_LOCKDOWN_STATE != "")
  	if (PRELOAD==1'b1)
     	$readmemh(FREEZE_LOCKDOWN_STATE, Freez_lockdown);

  	//if (CONFIGURATION_REGISTER != "")
  	if (PRELOAD==1'b1)
     	$readmemh(CONFIGURATION_REGISTER, Config_reg);
	
	QE = ~(&Config_reg[0]);

  	if (PRELOAD==1'b1)
  	$readmemh(FACTORY, factory_reg);

  	//if (SECURITY != "")
  	if (PRELOAD==1'b1)
    	begin
    		$readmemh(SECURITY, security_reg);
         	security_flag = 1'b1;
    	end

  	// Initialize lock_status
  	for (j=0; j< SECTORS; j= j+1)
    		lock_status[j] = &(lock_reg[j]);
	sect_lock_flag = |lock_status;

	// Initialize Freeze sector lockdown state
	Freez_sector_lockdown = &Freez_lockdown[0];
  	
	// Now initialize all registers 
	SPRL = 1'b0;
	SPM = 1'b0;
	EPE = 1'b0;
	WPP = 1'b0;
	SWP = 2'b11;
	WEL = 1'b0;
	RSTE = 1'b0;
	SLE  = 1'b0;
	QE	= 1'b0;

	status_reg1[7] 	= SPRL;
	status_reg1[6] 	= SPM;
	status_reg1[5]		= EPE; // reserved
	status_reg1[4] 	= WPP;
	status_reg1[3:2] 	= SWP;
	status_reg1[1] 	= WEL;
	status_reg1[0] 	= RDYnBSY;

	status_reg2[7] 	= 1'b0;
	status_reg2[6] 	= 1'b0;
	status_reg2[5] 	= 1'b0;
	status_reg2[4] 	= RSTE;
	status_reg2[3] 	= SLE;
	status_reg2[2] 	= 1'b0;
	status_reg2[1] 	= 1'b0;
	status_reg2[0] 	= RDYnBSY;

	CFG_reg[7]		= QE;
	CFG_reg[6]		= 1'b0;		// reserved
	CFG_reg[5]		= 1'b0;		// reserved
	CFG_reg[4]		= 1'b0;		// reserved
	CFG_reg[3]		= 1'b0;		// reserved
	CFG_reg[2]		= 1'b0;		// reserved
	CFG_reg[1]		= 1'b0;		// reserved
	CFG_reg[0]		= 1'b0;		// reserved
  
	// There is no activity at this time, chip is in stand-by mode

	deep_power_down	= 1'b0;
	erasing_block4	= 1'b0;
	erasing_block32 = 1'b0;
	erasing_block64 = 1'b0;
	erasing_chip	= 1'b0;
	byte_prog	= 1'b0;
	dual_byte_prog = 1'b0;
	quad_byte_prog = 1'b0;
	otp_sec_prog = 1'b0;
	sec_lockdown = 1'b0;
	Freez_sec_lockdown = 1'b0;
	h = 0;
	erase_i = 23'h00000;
	con_byte = 8'h00;
	con_ = 1'b0;
	dual_mode = 1'b0;
	quad_mode = 1'b0;
	sec_loc = 1'b0;
	full_page = 1'b0;
	abort = 1'b0;
	abort_boundary = 1'b0;
	abort_holdb = 1'b0;
	reset_request = 1'b0;
	reset_exit = 1'b0;
	reset = 1'b0;
	protected = 1'b1;
	sdindual_en = 1'b0;
	sdinquad_en = 1'b0;
	dout_phase = 1'b0;
	dummy_phase = 1'b0;
 
	for (j=0; j<SECTORS; j=j+1)   
  	begin                        
    		prot_status[j] = 1'b1;
  	end
  		
	// Stand-by mode initialization
	sect_locked	= 1'b1;
	current_address  = 24'b0;
	data_in		 = 8'b0;
	stat_reg_temp	 = 4'b0;
	stat_reg_temp1   = 2'b0;
	global_protect	 = 1'b0;
	global_unprotect = 1'b0;
	SPRL_val	 = 1'b0;
	lock		 = 1'b0;
	unlock		 = 1'b0;
	rd_dummy	 = 0;
	RDYnBSY		 = 1'b0;

  	// All o/ps are High-impedance
  	SO_on = 1'b0;

  	// Power-up Timing Restrictions
  	foreground_op_enable = 1'b0;
  	background_op_enable = 1'b0;
  	#tVCSL;
  	foreground_op_enable = 1'b1; // Enable foreground op_codes
  	#tPUW;
  	background_op_enable = 1'b1; // Enable background op_codes

end // end of initial

// ********************** Drive SO ********************* //
//bufif1 (SI, SO_reg, SO_on); //SO will be driven only if SO_on is High

assign SI 	= SI_on 		? SI_reg 		: 1'bz;				// IO<0>
assign SO 	= SO_on 		? SO_reg 		: 1'bz;				// IO<1>
assign WPB   	= WPB_on 		? WPB_reg 	: 1'bz;				// IO<2>
assign HOLDB 	= HOLDB_on 	? HOLDB_reg 	: 1'bz;				// IO<3>

assign status_reg = {status_reg1 , status_reg2};

//Power up initialization
always@(VCC)
begin
     # 1 vcc_reg = VCC;
end

assign power_en = (VCC==1'b1 && vcc_reg==1'b0) ? 1'b1 : (VCC==1'b0) ? 1'b0 : power_en;

always @ (power_en or VCC)
begin
	if (VCC==1'b0)
	begin
		foreground_op_enable = 1'b0;
		background_op_enable = 1'b0;
		for (j=0; j<SECTORS; j=j+1)   
  		begin                        
    			prot_status[j] = 1'b1;
  		end
		RSTE = 1'b0;
         	SLE = 1'b0;
	end
    	else if (VCC==1'b1)
	begin
     	#tVCSL foreground_op_enable = power_en;
		#tPUW  background_op_enable = power_en;
	end
     else
          $monitor("VCC deasserted before tVCSL period ", VCC);
end

// global protection and unprotection on sectors
always@(global_protect or global_unprotect)
begin
	if(global_protect==1'b1)
		for (i=0; i<SECTORS; i=i+1)
			prot_status[i] = 1'b1;
	else if(global_unprotect==1'b1)
		prot_status[SECTORS-1:0] = 'b0;
end

// ********************* Status register ********************* //
always @(WPB_Int or lock or unlock)	//SPRL bit locking & Unlocking
begin
	if(WPB_Int==1'b1 && SPRL==1'b0 && lock==1'b1)
		SPRL = 1'b1;
	else if(WPB_Int==1'b1 && SPRL==1'b1 && unlock==1'b1)
		SPRL = 1'b0; // S/W Locked
	else if(WPB_Int==1'b0 && SPRL==1'b0 && lock==1'b1)
		SPRL = 1'b1;
	else if(WPB_Int==1'b0 && SPRL==1'b1 && unlock==1'b1)
		SPRL = 1'b1; // H/W Locked
end

always @(WPB or QE)			// Write Protect (WP!) Pin Status
begin
	if (QE==1'b0)
	begin
		WPP = WPB;
		WPB_Int = WPB;
	end
	else
	begin
		WPP = 1'b1;
		WPB_Int = 1'b1;
	end
end

always @(prot_status)		// Software Protection Status
begin
	if(prot_status[SECTORS-1:0]=='d0)
		SWP = 2'b00;
	else if((|prot_status==1'b1) && (&prot_status==1'b0))
		SWP = 2'b01;
	else if(&prot_status==1'b1)
		SWP = 2'b11;
end

always @(SPRL or SPM or EPE or WPP or SWP or WEL or RDYnBSY)
begin
	status_reg1 = {SPRL,SPM,EPE,WPP,SWP,WEL,RDYnBSY};
end

always @(RSTE or SLE or RDYnBSY)
begin
        status_reg2 = {1'b0,1'b0,1'b0,RSTE,SLE,1'b0,1'b0,RDYnBSY};
end

always @(QE)
begin
	CFG_reg = {QE,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};
end

// ******* to receive opcode and to switch to respective blocks ******* //
always @(negedge CSB)  // the device will now become active
begin : get_opcode

	get_data;  // get opcode here

	if (foreground_op_enable == 1'b0)					// No foreground or background opcode accepted
		$display("No opcode is allowed: %d delay is required before device can be selected", tVCSL);
	else if (deep_power_down == 1'b1) 					// Can be only after background has been enabled
		case (read_data)
			8'hAB:	-> RDPD;					// Resume from Deep Power-down
			default :	$display("Opcode %h is not allowed: device in Deep Power-down", read_data);
		endcase
    	else
		case (read_data)							// based on opcode, trigger an action
			8'h0B :	begin						// Read Array
						rd_dummy = 1;
						-> RA;
					end
			8'h03 :	begin						// Read Array (low freq)
						rd_dummy = 0;
						-> RA;
					end
          	8'h1B :	begin						// Read Array (High freq)
						rd_dummy = 2;
						-> RA;
					end
         		8'h20 :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW);
					else
						-> BE4;					// Block erase 4KB
         		8'h52 :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW);
					else
						-> BE32;					// Block erase 32KB
         		8'hD8 :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW); 
					else
						-> BE64;					// Block erase 64KB
         		8'h60 :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW);
					else
						-> CE;					// Chip erase
         		8'hC7 :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW);
					else
						-> CE;					// Chip erase
         		8'h02 :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW);
					else
						-> BP;					// Byte Program
          	8'hA2 :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW);	
					else
						-> DIPG;					// Dual Byte Program 
         		8'h33 :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW);// Sector Lock Register 
					else
						-> SLD;					// Sector Lock Register
         		8'h34 :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW);
					else
						-> FSL;					// Freeze Sector Lockdown
         		8'h35 :	-> RSLR;						// Read Sector Lock Down register
         		8'h06 :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW); 
					else
						-> WE;					// Write Enable
          	8'h04 :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW);	
					else
						-> WD;					// Write Disable
          	8'h36 :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW);
					else
						-> PS;					// Protect Sector
          	8'h39 :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW);	
					else
						-> UPS;					// Un-Protect Sector
			8'h3C :	-> RSPR;						// Read Sector Protection Register
			8'h05 :	-> RSR;						// Read Status Register
          	8'h01 :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW);	
					else
						-> WSR1;					// Write Status Register Byte1 
          	8'h31 :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW);	
					else
						-> WSR2;					// Write Status Register Byte2 
			8'h9F :	-> MIR;						// Read Manufacturer and Device ID
          	8'hB9 :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW);	
					else
						-> EDPD;					// Enter Deep Power-down 
          	8'h9B :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW);	
					else
						-> POSR;					// Program OTP Security Register 
          	8'h77 :	begin						
                   			rd_dummy = 2;
                    		-> ROSR;					// Read OTP Security register
               		end
          	8'hF0 : 	-> RST;						//Reset
          	8'h3B :	begin						// Dual Ouput Read Array
                    		rd_dummy = 1;
                    		-> DORA;
              			end
          	8'h3F: 	-> RCFGR;						// Read Configuration Register 
          	8'h3E :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW);	
					else
						-> WCFGR;					// Write Configuration Register 
          	8'h6B :	if (QE == 1'b0)
						$display("Quad Feature is not enabled");
					else
					begin						// Quad Ouput Read Array
                    		rd_dummy = 1;
                    		-> QORA;
              			end
          	8'h32 :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW);	
					else if (QE == 1'b0)
                              $display("Quad Feature is not enabled");
					else
						-> QIPG;					// Quad Byte Program 
			default :	$display("Unrecognized opcode  %h", read_data);
		endcase
end

// *********************** TASKS / FUNCTIONS ************************** //
// get_data is a task to get 4 bits of data. This data could be an address,
// data or anything. It just obtains 4 bits of data obtained on SI
task get_data;

integer i;
begin
	for (i=7; i>=0; i = i-1)
	begin
		@(posedge CLK);  
		read_data[i] = SI;
	end
end
endtask

// task read_out_array is to read from main Memory
task read_out_array;
input [23:0] read_addr;
integer i;

begin
     begin
		temp_data = memory [read_addr];
     	i = 7;
		while (CSB == 1'b0) // continue transmitting, while, CSB is Low
		begin
			@(negedge CLK);
			dout_phase = 1'b1;
			SO_reg = 1'bx;
			#tV;
			SO_reg = temp_data[i];
			if (i == 0) 
			begin
				$display("Data: %h read from memory location %h",temp_data,read_addr);
				read_addr = read_addr + 1; // next byte
         			i = 7;
				if (read_addr >= MEMSIZE)
				read_addr = 0; // Note that rollover occurs at end of memory,
					temp_data = memory [read_addr];
			end
			else
				i = i -1;	// next bit
	 	end
	end     // reading over, because CSB has gone high

end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////////////
task protect_sector;
input [23:0] protect_address;
integer i;
begin
	//$display("Entered Protect sector for device %s ", DEVICE);
	for (i=0; i<SECTORS; i=i+1)
	begin
		if (protect_address[MADDRESS-1:16] == i)
			prot_status[i] = 1'b1;
	end 
end
endtask

task unprotect_sector;
input [23:0] unprotect_address;
integer i;
begin
	//$display("Entered Unprotect sector for device %s ", DEVICE);
	for (i=0; i<SECTORS; i=i+1)
	begin
		if (unprotect_address[MADDRESS-1:16] == i)
			prot_status[i] = 1'b0;
	end 
end
endtask

task check_protection;
input [23:0] check_address;
integer i;

begin
	//$display("check_address: %h",check_address);
	protected = 1'b0;
	for (i=0; i<SECTORS; i=i+1)
	begin
		if (check_address[MADDRESS-1:16] == i )
			protected = prot_status[i];
	end
end
endtask


// Sending Sector Protection status
task send_protection_status;
integer local_i;
integer i;
reg [7:0] send_status;	// status value, 'ff' if protected, '00' if unprotected
begin
	if(protected==1'b1)
		send_status = 8'hff;
	else
		send_status = 8'h00;
	local_i = 7;
	while (CSB == 1'b0) // continue transmitting, while, CSB is Low
	begin
		@(negedge CLK);
		dout_phase = 1'b1;
		SO_reg = 1'bx;
		#tV;
          SO_reg = send_status[local_i];
		if (local_i == 0) 
			local_i = 7;
		else
			local_i = local_i - 1; // next bit
     end	 // sending status over, because CSB has gone high
 
end
endtask

//-------------------------------------------------------------------------------------------
// receive data for byte/page programming
task buffer_write;
input [7:0]in_j;
reg [8:0] count;
begin
	count = 0;
	while (CSB==1'b0)
	begin
		if (sdinquad_en==1'b1)							// x4- input
			for (pp_i=1; pp_i>=0; pp_i = pp_i-1)
			begin
				@(posedge CLK);  
				read_data[pp_i*4] = SI;
				read_data[pp_i*4+1] = SO;
				read_data[pp_i*4+2] = WPB;
				read_data[pp_i*4+3] = HOLDB;
			end
		else if (sdindual_en==1'b1)						// x2- input	
			for (pp_i=3; pp_i>=0; pp_i = pp_i-1)
			begin
				@(posedge CLK);  
				read_data[pp_i*2] = SI;
				read_data[pp_i*2+1] = SO;
			end
		else											// x1- input
			for (pp_i=7; pp_i>=0; pp_i = pp_i-1)
			begin
				@(posedge CLK);  
				read_data[pp_i] = SI;
			end
		int_buffer[in_j] = read_data;
      	//$display("The pph value %h,%h ",int_buffer[in_j],in_j);
		in_j = in_j+1;				// next buffer address 
		count = count+1;			// next byte
		pp_h = count;
		if(count >= 256)
			count = 256;
		//$display("One byte of data: %h received for Page Program",read_data);
	end
end
endtask

// Byte program for devices. also used for page program
task byte_program;
input [23:0] write_address;
input [7:0] write_data;
begin
		memory[write_address]= memory[write_address] & write_data;
		$display("One Byte of data %h written in memory in location %h, %h", write_data, write_address, memory[write_address]);
end
endtask

// Erase a 4kB block
task erase_4kb;
input [23:0] erase_address;

reg [12:0] erase4_i;
reg [23:0] block_addr4;

begin   
	//$display("4kB Block with start address %h is going to be erased", block_addr4);
	erase_start_4 = 13'b0_0000_0000_0000;
	block_addr4 = {erase_address[23:12],12'b0000_0000_0000};
	for(erase4_i=erase_start_4; erase4_i <= 13'b0_1111_1111_1111; erase4_i=erase4_i+1)
	begin
         	memory [block_addr4 + erase4_i] = 8'hff;				
        	#12207;
		if( memory [block_addr4 + erase4_i] != 8'hff)
		begin
			//$display("Memory is not erased properly!!!");
		end
 		if(reset_request == 1'b1)
		begin
         		//$display("resetting erase operation");
			#(tRST - 12207) ;
			RDYnBSY = 1'b0;
			exit_reset;
			reset_request = 1'b0;
    			disable erase_4kb;
		end
    end
end
endtask

// Erase a 32kB block
task erase_32kb;
input [23:0] erase_address;

reg [15:0] erase32_i;
reg [23:0] block_addr32;

begin   
	//$display("32kB Block with start address %h is going to be erased", block_addr32);
        erase_start_32 = 16'b0_000_0000_0000_0000;
        block_addr32 = {erase_address[23:15],15'b000_0000_0000_0000};
	for(erase32_i=erase_start_32; erase32_i <= 16'b0_111_1111_1111_1111; erase32_i=erase32_i+1)
	begin
       	memory [block_addr32 + erase32_i] = 8'hff;				
         	#9763;
		if( memory [block_addr32 + erase32_i] != 8'hff)
		begin
			//$display("Memory is not erased properly!!!");
    			EPE = 1'b1;				// Set Error Flag and keep erasing another block
		end
 		if(reset_request == 1'b1)
		begin
         		//$display("resetting erase operation");
			#(tRST - 9763) ;
			RDYnBSY = 1'b0;
			exit_reset;
			reset = 1'b1;
    			disable erase_32kb;
		end
    end
end
endtask

// Erase a 64kB block
task erase_64kb;
input [23:0] erase_address;

reg [16:0] erase64_i;
reg [23:0] block_addr64;

begin   
	erase_start_64 = 16'b0_000_0000_0000_0000;
	block_addr64 = {erase_address[23:16],16'b0000_0000_0000};
	//$display("64kB Block with start address %h is going to be erased", block_addr64);
	for(erase64_i=erase_start_64; erase64_i <= 17'b0_1111_1111_1111_1111; erase64_i=erase64_i+1)
	begin
        	memory [block_addr64 + erase64_i] = 8'hff;				
          #6104;
		if( memory [block_addr64 + erase64_i] != 8'hff)
		begin
			//$display("Memory is not erased properly!!!");
    			EPE = 1'b1;				// Set Error Flag and keep erasing another block
		end
 		if(reset_request == 1'b1)
		begin
         		//$display("resetting erase operation");
			#(tRST - 6104) ;
			RDYnBSY = 1'b0;
			exit_reset;
			reset = 1'b1;
    			disable erase_64kb;
		end
    end
end
endtask

// Chip Erase
task erase_chip;
reg [23:0] erase_i;

begin   
	$display("Chip Erase is going to be started");
	for(erase_i=0; erase_i < MEMSIZE; erase_i=erase_i+1)
	begin
         	memory [erase_i] = 8'hff;				
          #7629;
		if( memory [erase_i] != 8'hff)
		begin
			$display("Memory is not erased properly!!!");
    			EPE = 1'b1;				// Set Error Flag and keep erasing another block
		end
 		if(reset_request == 1'b1)
		begin
         		$display("resetting erase operation");
			#(tRST - 7629) ;
			RDYnBSY = 1'b0;
			exit_reset;
			reset = 1'b1;
    			disable erase_chip;
		end
	end
end
endtask

task exit_reset;     
begin
	erasing_block4	= 1'b0;
	erasing_block32	= 1'b0;
	erasing_block64	= 1'b0;
	erasing_chip	= 1'b0;
	byte_prog	= 1'b0;
	dual_byte_prog	= 1'b0;
	quad_byte_prog = 1'b0;
	reset_request = 1'b0;
	WEL = 1'b0;
end
endtask 
       

// ******************* Execution of Opcodes ********************* //

// ************* Deep Power-down ***************** //
always @(EDPD)
begin : EDPD_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		$display("Device is busy. Deep Power-down command cannot be issued");
		disable EDPD_ ;     
	end
	// if it comes here, means, the above if was false.

   	if (tMAX==1'b1)
		$display("WARNING: Frequency should be less than fMAX.");

	@ (posedge CSB);
	if (abort == 1'b1)
	begin
		$display("Chip Select deasserted at non-even byte boundary.  Abort Deep Power-Down.");
		disable EDPD_;
	end
	//RDYnBSY = 1'b1;
	deep_power_down = 1'b1;
	#tEDPD;
	RDYnBSY = 1'b0;
	$display("Device %s enters into Deep Power-down mode. Send 'Resume from Deep Power-down' to resume", DEVICE);    
end

// ************* Resume from Deep Power-down ***************** //
always @(RDPD)
begin : RDPD_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		$display("Device is busy. Deep Power-down command cannot be issued");
		disable RDPD_ ;     
	end
	// if it comes here, means, the above if was false.

   	if (tMAX==1'b1)
		$display("WARNING: Frequency should be less than fMAX");
	@ (posedge CSB);
	if (abort == 1'b1)
	begin
		$display("Chip Select deasserted at non-even byte boundary.  Abort Resume from Deep Power-Down.");
		disable RDPD_;
	end
	//RDYnBSY = 1'b1;
	#tRDPD deep_power_down = 1'b0;
	RDYnBSY = 1'b0;
	$display("Device %s Resumes from Deep Power-down mode", DEVICE);
end

// ************* Manufacturing ID Read ******************** //
always @(MIR)
begin: MIR_
	//AT25DF641.v series allow MIR while the device is BUSY !!!!
	//if (RDYnBSY == 1'b1) // device is already busy
	//	begin
	//		$display("Device is busy. Manufacturing ID Read cannot be issued");
	//		disable MIR_ ;     
	//	end
	// if it comes here, means, the above if was false.

   	if (tMAX==1'b1)
		$display("WARNING: Frequency should be less than fMAX.");

	j = 40;
	while (CSB == 1'b0)
	begin
		@(negedge CLK);
		dout_phase = 1'b1;
	 	SO_reg = 1'bx;
		#tV;
		SO_reg = MAN_ID[j-1];
		if (j == 0)
		begin
			$display("Manufacture ID and Device ID of Device %s sent", DEVICE);
			dout_phase = 1'b0;
              	disable MIR_;
		end
		else
         		j = j - 1;
	end // output next bit on next falling edge of SCK
	$display("Manufacture ID and Device ID of Device %s sent", DEVICE);
end

                        
// ************* Read Status Register ******************** //
always @ (RSR)
begin : RSR_
	if (tMAX==1'b1)
		$display("WARNING: Frequency should be less than fMAX");
     j = 15;
    	while (CSB == 1'b0)
    	begin
		@(negedge CLK);
		dout_phase = 1'b1;
	 	SO_reg = 1'bx;
		#tV;
		SO_reg = status_reg[j];
         	if(j == 0)
         	begin
    			//$display("Status register Byte 1 and Byte 2  content of Device %s transmitted", DEVICE);
         		j = 15;
         	end
		else
			j = j - 1;	// next bit
   	end
end

// ************ Write Status Register Byte 1******************** //
always @(WSR1)
begin : WSR1_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		$display("Device %s is busy. Write Status Register is not allowed", DEVICE);
		disable WSR1_;
	end
	// if it comes here, means, the above if was false.

   	if (tMAX==1'b1)
		$display("WARNING: Frequency should be less than fMAX");

 	get_data;
     SPRL_val = read_data [7];
     stat_reg_temp = read_data [5:2];
	
	@ (posedge CSB);
     if ((WEL==1'b1) && (abort==1'b0) && (cmd_2byte==1'b1))
    	begin
         	if(WPB_Int==1'b0 && SPRL==1'b0 && SPRL_val==1'b1)
              	$display("SPRL Hardware locked");
         	else if(WPB_Int==1'b1 && SPRL==1'b0 && SPRL_val==1'b1)
              	$display("SPRL Software locked");
         	else if(WPB_Int==1'b0 && SPRL==1'b1 && SPRL_val==1'b1)
              	$display("SPRL Hardware locked. Lock cannot be done");
         	else if(WPB_Int==1'b1 && SPRL==1'b1 && SPRL_val==1'b1)
              	$display("SPRL Software locked. Lock cannot be done");
         	else if(WPB_Int==1'b0 && SPRL==1'b1 && SPRL_val==1'b0)
              	$display("SPRL Hardware locked. Unlock cannot be done");
         	else if(WPB_Int==1'b1 && SPRL==1'b1 && SPRL_val==1'b0)
              	$display("Sector Protection Register UnLocked");
         	else
              	$display("SPRL in unlocked state");

         	if(stat_reg_temp==4'b1111 && SPRL==1'b0)
              	global_protect = 1'b1;
         	else if(stat_reg_temp==4'b0000 && SPRL==1'b0)
              	global_unprotect = 1'b1;
         	else if(SPRL==1'b1 && (stat_reg_temp==4'b0000 || stat_reg_temp==4'b1111))
         		begin
              		$display("SPRL locked. Global Protect/Unprotect cannot be done");
              		global_protect = 1'b0;
              		global_unprotect = 1'b0;
          	end

		if(SPRL==1'b0 && global_protect==1'b1)
              	$display("Global Protection issued for Sector protection register");
         	else if(SPRL==1'b0 && global_unprotect==1'b1)
              	$display("Global Unprotect issued for Sector protection register");
         	else if(SPRL==1'b1 && (global_protect==1'b1 || global_unprotect==1'b1))
              	$display("SPRL locked. Global Protect/Unprotect cannot be done");

         	if(SPRL==1'b0 && SPRL_val==1'b1)
    		begin
         		//RDYnBSY = 1'b1;
         		lock = 1'b1;
         		#tWRSR;
    		end
         	else if(SPRL==1'b1 && SPRL_val==1'b0)
         	begin
         		//RDYnBSY = 1'b1;
         		unlock = 1'b1;
         		#tWRSR;
         	end
         	else if(global_protect==1'b1 || global_unprotect==1'b1)
         	begin
         		//RDYnBSY = 1'b1;
         		#tWRSR;
         	end
   	end
     else if ((abort==1'b1) | (WEL==1'b0) | (cmd_2byte==1'b0))
         	$display("WEL bit not set or Chip Select deasserted at non-even byte boundary. Abort Write Status Register");

     lock = 1'b0;
     unlock = 1'b0;
     RDYnBSY = 1'b0;
     global_protect = 1'b0;
     global_unprotect = 1'b0;
     WEL = 1'b0;
     $display("Write Status Register operation completed");
end

//************ Write Status Register Byte 2 *************//
always @(WSR2)
begin : WSR2_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		$display("Device %s is busy. Write Status Register is not allowed", DEVICE);
		disable WSR2_;
	end
	// if it comes here, means, the above if was false.

	if (tMAX==1'b1)
	$display("WARNING: Frequency should be less than fMAX.");

	get_data;
    	@(posedge CSB);
	begin	
		if ((abort==1'b1) || (WEL==1'b0) || (cmd_2byte==1'b0)) 
		begin
			$display("Either Chip Select deasserted at non even byte boundary or WEL bit not set.  Abort Write Status Register ");
			WEL = 1'b0;
			disable WSR2_;
		end
		if ((abort==1'b0) && (WEL==1'b1) && (cmd_2byte==1'b1))
		begin
			//RDYnBSY = 1'b1;
         		RSTE  = read_data[4] ;
         		SLE = (Freez_sector_lockdown == 1'b1) ? 0 : read_data[3];
			#tWRSR
			$display("Write Status Register Byte2  operation completed");
		end
		WEL = 1'b0;
		RDYnBSY = 1'b0;
    	end
end

//************ Write Configuration Register *************//
always @(WCFGR)
begin : WCFGR_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		$display("Device %s is busy. Write Configuration is not allowed", DEVICE);
		disable WCFGR_;
	end
	// if it comes here, means, the above if was false.

	if (tMAX==1'b1)
	$display("WARNING: Frequency should be less than fMAX.");

	get_data;
	config_byte = read_data[7:0];

    	@(posedge CSB);
	begin	
		if ((abort==1'b1) || (WEL==1'b0) || (cmd_2byte==1'b0)) 
		begin
			$display("Either Chip Select deasserted at non even byte boundary or WEL bit not set.  Abort Write Configuration Register ");
			WEL = 1'b0;
			disable WCFGR_;
		end
		if ((abort==1'b0) && (WEL==1'b1) && (cmd_2byte==1'b1))
		begin
			RDYnBSY = 1'b1;
			Config_reg[0] = {8{!config_byte[7]}};
			#tWRCR;
			QE = ~(&Config_reg[0]);
			$display("Write Configuration Register  operation completed");
		end
		WEL = 1'b0;
		RDYnBSY = 1'b0;
    	end
end

// ************ Write Enable ******************** //
always @(WE)
begin : WE_
	if (RDYnBSY == 1'b1) // device is already busy
    	begin
         	$display("Device %s is busy. Write Enable is not allowed", DEVICE);
         	disable WE_;
    	end
   	if (tMAX==1'b1)
		$display("WARNING: Frequency should be less than fMAX");
      
	@ (posedge CSB);
	if (abort == 1'b1)
	begin
		$display("Chip Select deasserted at non-even byte boundary.  Abort  Write Enable Command");
         	disable WE_;
	end
	$display("Write Enable Latch Set");
	WEL = 1'b1;
   
end

// ************ Write Disable ******************** //
always @(WD)
begin : WD_
	if (RDYnBSY == 1'b1) // device is already busy
    	begin
         	$display("Device %s is busy. Write Disable is not allowed", DEVICE);
         	disable WD_;
    	end

   	if (tMAX==1'b1)
		$display("WARNING: Frequency should be less than fMAX.");

	@ (posedge CSB);
	if (abort==1'b1)
	begin
		$display("Chip Select deasserted at non-even byte boundary.  Abort  Write Disable Command");
         	disable WD_;
	end
	$display("Write Enable Latch Reset");
	WEL = 1'b0;
end

// ******************** Read Array ********************** //
always @(RA)
begin : RA_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		$display("Device %s is busy. Read Array is not allowed", DEVICE);
		disable RA_;
	end
	// if it comes here, means, the above if was false.

	if ((rd_dummy==0)  && (tRDLF==1'b1))						// RD_03h
		$display("WARNING: Frequency should be less than fRDLF");
	else if ((rd_dummy==1) & (tRDDO==1'b1))						// RD_0Bh  
	 	$display(" WARNING: Frequency is greater that fRDDO");
	else if ((rd_dummy==2) & (tMAX==1'b1))						// RD_1Bh 
	 	$display(" WARNING: Frequency is greater that fMAX");

	get_data;
	temp_addr [23:16] = read_data [7:0];
	get_data;
	temp_addr [15:8] = read_data [7:0];
	get_data;
	temp_addr [7:0] = read_data [7:0];

	current_address = {5'h00 , temp_addr[18:0]};

     for(i = rd_dummy ; i>0 ; i = i - 1)
     begin
		dummy_phase = 1'b1;
         	for (j = 7; j >= 0; j = j - 1) // these are dont-care, so discarded
		begin
			@(posedge CLK);  
			read_dummy[j] = SI;
	    	end
	    	read_dummy = 8'h0;
		dummy_phase = 1'b0;
	end

	read_out_array(current_address); // read continuously from memory untill CSB deasserted
	current_address = 24'b0;
        
end

// ****************** Protect Sector ****************** //
always @(PS)
begin : PS_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		$display("Device %s is busy. Protect Sector is not allowed", DEVICE);
		disable PS_ ;     
	end
	// if it comes here, means, the above if was false.

	if (tMAX==1'b1)
	$display("WARNING: Frequency should be less than fMAX");

	get_data;
	temp_addr [23:16] = read_data [7:0];
	get_data; 
	temp_addr [15:8] = read_data [7:0];
	get_data;
	temp_addr [7:0] = read_data [7:0];

	current_address = {5'h00 , temp_addr[18:0]};

	@ (posedge CSB);
	if ((abort == 1'b1) | (WEL==1'b0) | (cmd_4byte==1'b0))
	begin
    		$display("The CSB deasserted at Non even byte boundary or WEL bit not set. Aborting Protect sector" );
		WEL = 1'b0;
    		disable PS_;
    	end
	if (SPRL==1'b1) 
	begin
		$display("Sector Protection Registers are Locked.  Aborting Protect Sector.");
		WEL = 1'b0;				
        	disable PS_;
     end
	$display("Sector for Address %h is Protected", current_address);
	RDYnBSY = 1'b1;
	protect_sector(current_address);
	#tSECP;
	WEL = 1'b0;
	RDYnBSY = 1'b0;
	current_address = 24'b0;
end

// ****************** Un-Protect Sector ****************** //
always @(UPS)
begin : UPS_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		$display("Device %s is busy. Un-Protect Sector is not allowed", DEVICE);
		disable UPS_ ;     
	end
	// if it comes here, means, the above if was false.

   	if (tMAX==1'b1)
	$display("WARNING: Frequency should be less than fMAX");

	get_data;
	temp_addr [23:16] = read_data [7:0];
	get_data;
	temp_addr [15:8] = read_data [7:0];
	get_data;
	temp_addr [7:0] = read_data [7:0];
	current_address = temp_addr;

	current_address = {5'h00 , temp_addr[18:0]};

	@ (posedge CSB);
	if ((abort==1'b1) | (WEL==1'b0) | (cmd_4byte==1'b0))
	begin
        	$display("The CSB deasserted at Non even byte boundary or WEL bit is not set. Aborting Un-Protect sector" );
		WEL = 1'b0;
        	disable UPS_;
      end
	if (SPRL==1'b1) 
	begin
		$display("Sector Un-Protection Registers are Locked.  Aborting Protect Sector.");
		WEL = 1'b0;
    		disable UPS_;
    	end
	RDYnBSY = 1'b1;
	unprotect_sector(current_address);
	#tSECUP;
	$display("Sector for Address %h is UnProtected", current_address);
	WEL = 1'b0;
	RDYnBSY = 1'b0;
	current_address = 24'b0;
end

// ****************** Read Sector Protection Register ****************** //
always @(RSPR)
begin : RSPR_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		$display("Device %s is busy. Read Sector Protection Register is not allowed", DEVICE);
		disable RSPR_ ;
	end
	// if it comes here, means, the above if was false.

   if (tMAX==1'b1)
	$display("WARNING: Frequency should be less than fMAX");

	get_data;
	temp_addr [23:16] = read_data [7:0];
	get_data;
	temp_addr [15:8] = read_data [7:0];
	get_data;
	temp_addr [7:0] = read_data [7:0];

	current_address = {5'h00 , temp_addr[18:0]};

	check_protection(current_address);

	if(protected==1'b1)
		$display("Sector for Address %h is Protected", current_address);
	else
		$display("Sector for Address %h is UnProtected", current_address);
	send_protection_status;	// sending the Sector Protection Register content in SO
	current_address = 24'b0;
	$display("Read Sector Protection Register completed");
end

// ********************* Byte Program ********************* //
always @(BP)
begin : BP_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		$display("Device %s is busy. Byte Program is not allowed", DEVICE);
		disable BP_ ; 
	end
	// if it comes here, means, the above if was false.
        

     if (tMAX==1'b1)
		$display("WARNING: Frequency should be less than fMAX");

	// to receive 3 bytes of address
	get_data;
	temp_addr [23:16] = read_data [7:0];
	get_data;
	temp_addr [15:8] = read_data [7:0];
	get_data;
	temp_addr [7:0] = read_data [7:0];

	current_address = {5'h00 , temp_addr[18:0]};

	check_protection(current_address);
    	check_lock_down(current_address);
	buffer_address = current_address[7:0];
     EPE = 1'b0; 
	buffer_write(buffer_address);								// page program - receives data

	if((abort == 1) | (WEL==1'b0) | (cmd_5byte==1'b0))			// page program should not proceed if CSB deasserted at intermediate points
	begin
		$display("Chip Select deasserted in non-even byte boundary or WEL bit is not set. Abort Byte/Page Program command");
		WEL = 1'b0;
		disable BP_ ;
	end
    	if((sect_locked==1'b1) | (protected==1'b1))
    	begin
		$display("Sector for Address %h is either Protected or Locked. Byte Program cannot be performed", current_address);
		WEL = 1'b0;
    		disable BP_ ;
    	end
	$display("Sector for Address %h is UnProtected, Byte Program can be performed", current_address);
	RDYnBSY = 1'b1;
	byte_prog = 1'b1;
	page_program(current_address[7:0]);
	if (reset == 1'b1)
    	begin
         	$display("Device is in reset mode");
         	reset = 1'b0;
         	disable BP_;
	end
	$display("Byte write completed");
	pp		 = 0;
	pp_h		 = 0;
	pp_i		 = 0;
	WEL		 = 1'b0;
	RDYnBSY		 = 1'b0;
	byte_prog	 = 1'b0;
	current_address  = 24'b0;
	pp_address	 = 8'b0;
	data_in		 = 8'b0;
end

task page_program;
input [7:0] pp_address;
begin
   		if(pp_h < 256)
         		full_page = 1'b0;
		else
		begin
         		full_page = 1'b1;
			pp_h = 256;
		end
		pp_start = 0;
		for(pp = pp_start; pp < pp_h; pp = pp+1)
		begin
			data_in = int_buffer[pp_address];
			byte_program({current_address[23:8],pp_address}, data_in);
			pp_address = pp_address + 1'b1;
			if ((full_page==1'b0) && (pp<141))	#tBP;		// multiply with #tBP for up to 141 bytes 
			else if (full_page==1'b1) #3906;				// tPP / 256 bytes
			else if (full_page==1'b0)	;					// already reach up to tPP
         		if(reset_request == 1'b1)
			begin
				#(tRST - tBP)	;					// reset latency
				RDYnBSY	 = 1'b0;
				byte_prog = 1'b0;
				reset_request = 1'b0;
				reset = 1'b1;
				exit_reset;
				disable page_program ;
			end
		end
end
endtask


// ********************* 4kB Block Erase ********************* //
always @(BE4)
begin : BE4_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		$display("Device %s is busy. 4KB Block Erase is not allowed", DEVICE);
		disable BE4_ ;
	end
	// if it comes here, means, the above if was false.

   	if (tMAX==1'b1)
	$display("WARNING: Frequency should be less than fMAX.");

	get_data;
	temp_addr [23:16] = read_data [7:0];
	get_data;
	temp_addr [15:8] = read_data [7:0];
	get_data;
	temp_addr [7:0] = read_data [7:0];

	current_address = {5'h00 , temp_addr[18:0]};

     check_lock_down(current_address);
	check_protection(current_address);

	@ (posedge CSB);
	if ((abort==1'b1) | (WEL==1'b0) | (cmd_4byte==1'b0))
	begin
		$display("Chip Select deasserted in non-even byte boundary or WEL bit is not set. Abort Byte/Page Program command");
		WEL = 1'b0;
		disable BE4_ ;
	end
    	EPE = 1'b0; 
	if((protected==1'b1) | (sect_locked==1'b1))
	begin
		$display("Sector for Address %h is either Protected or Locked. 4KB Block Erase cannot be performed", current_address);
		WEL = 1'b0;
		disable BE4_ ;
	end
	$display("Sector for Address %h is UnProtected, 4KB Block Erase can be performed", current_address);
	RDYnBSY = 1'b1;
	erasing_block4 = 1'b1;
	erase_4kb(current_address);
	if (reset == 1'b1)
	begin
    		$display("Device is in reset mode");
		reset = 1'b0;
		disable BE4_;
	end
   	$display("4kB Block with start address %h erased", {current_address[23:12],12'b0});
	WEL = 1'b0;
	RDYnBSY = 1'b0;
	erasing_block4 = 1'b0;
	current_address = 24'b0;
end

// ********************* 32kB Block Erase ********************* //
always @(BE32)
begin : BE32_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		$display("Device %s is busy. 32KB Block Erase is not allowed", DEVICE);
		disable BE32_ ;
	end
	// if it comes here, means, the above if was false.

   	if (tMAX==1'b1)
	$display("WARNING: Frequency should be less than fMAX.");

	get_data;
	temp_addr [23:16] = read_data [7:0];
	get_data;
	temp_addr [15:8] = read_data [7:0];
	get_data;
	temp_addr [7:0] = read_data [7:0];

	current_address = {5'h00 , temp_addr[18:0]};

     check_lock_down(current_address);
	check_protection(current_address);

	@ (posedge CSB);
	if ((abort==1'b1) | (WEL==1'b0) | (cmd_4byte==1'b0))
	begin
		$display("Chip Select deasserted in non-even byte boundary or WEL is not set. Abort Byte/Page Program command");
		WEL = 1'b0;
		disable BE32_ ;
	end
     EPE = 1'b0; 
     if((sect_locked==1'b1) | (protected==1'b1))
    	begin
    		$display("Sector Address %h is either Locked Down or Protected.  32KB Block Erase cannot be performed", current_address);
    		WEL = 1'b0;
    		disable BE32_;
    	end
	$display("Sector for Address %h is UnProtected, 32KB Block Erase can be performed", current_address);
	RDYnBSY = 1'b1;
	erasing_block32 = 1'b1;
	erase_32kb(current_address);
	if (reset == 1'b1)
	begin
    		$display("Reset 32KB Erase Command.");
		reset = 1'b0;
		disable BE32_;
	end
	$display("32kB Block with start address %h erased", {current_address[23:15],15'b0});
	WEL = 1'b0;
	RDYnBSY = 1'b0;
	erasing_block32 = 1'b0;
	current_address = 24'b0;
end

// ********************* 64kB Block Erase ********************* //
always @(BE64)
begin : BE64_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		$display("Device %s is busy. 64KB Block Erase is not allowed", DEVICE);
		disable BE64_ ;
	end
	// if it comes here, means, the above if was false.

   	if (tMAX==1'b1)
	$display("WARNING: Frequency should be less than fMAX.");

	get_data;
	temp_addr [23:16] = read_data [7:0];
	get_data;
	temp_addr [15:8] = read_data [7:0];
	get_data;
	temp_addr [7:0] = read_data [7:0];

	current_address = {5'h00 , temp_addr[18:0]};

     check_lock_down(current_address);
	check_protection(current_address);

	@ (posedge CSB);
	if ((abort==1'b1) | (WEL==1'b0) | (cmd_4byte==1'b0))
		begin
			$display("Chip Select deasserted in non-even byte boundary or WEL is not set. Abort Byte/Page Program command");
			WEL = 1'b0;
			disable BE64_ ;
		end
     EPE = 1'b0; 
     if((sect_locked==1'b1) | (protected==1'b1))
     begin
     	$display("Sector Address %h is Locked Down.  64KB Block Erase cannot be performed", current_address);
       	WEL = 1'b0;
        	disable BE64_;
     end
	$display("Sector for Address %h is UnProtected, 64KB Block Erase can be performed", current_address);
	RDYnBSY = 1'b1;
	erasing_block64 = 1'b1;
	erase_64kb(current_address);
	if (reset == 1'b1)
	begin
    		$display("Reset 64K Block Erase command");
		reset = 1'b0;
		disable BE64_ ;
	end
	$display("64kB Block with start address %h erased", {current_address[23:16],16'b0}); 
	WEL = 1'b0;
	RDYnBSY = 1'b0;
	erasing_block64 = 1'b0;
	current_address = 24'b0;
end

// ********************* Chip Erase ********************* //
always @(CE)
begin : CE_ 
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		$display("Device %s is busy. Chip Erase is not allowed", DEVICE);
		disable CE_ ;
	end
	// if it comes here, means, the above if was false.

   	if (tMAX==1'b1)
	$display("WARNING: Frequency should be less than fMAX.");

	@(posedge CSB);
	if ((abort==1'b1) || (WEL==1'b0) || (cmd_1byte==1'b0))
	begin
		$display("Chip Select deasserted in non-even byte boundary or WEL is not set. Abort Chip Erase command");
		WEL = 1'b0;
		disable CE_ ;
	end
     EPE = 1'b0; 
    	if((sect_lock_flag==1'b1) || (|SWP==1'b1))
     begin
     	$display("Not all sectors are Un-locked or Un-Protected.  Abort Chip Erase.");
        	WEL = 1'b0;
        	disable CE_;
    	end
	$display("Chip Erase inprogress");
	RDYnBSY = 1'b1;
	erasing_chip = 1'b1;
 	erase_chip;
	if (reset == 1'b1)
	begin
    		$display("Reset Chip Erase command");
		reset = 1'b0;
		disable CE_ ;
	end
	$display("Chip Erase is completed"); 
	WEL = 1'b0;
	RDYnBSY = 1'b0;
	erasing_chip = 1'b0;
end

// ********************** Frequeny Checking ********************** //
always @ (negedge SCK)
begin
	tperiod <= $time;
	tperiod1 <= tperiod;
end

always @(tperiod or tperiod1)
begin
	//if ((tperiod - tperiod1) < (tSCKH + tSCKH))
     if (fSCK > 150)
     begin
		freq_error = 1'b1;
	//	$display("Time period detected is %t", (tSCKH + tSCKH)); 
	//	$display("Frequency exceeds max limit (14285 ms). Time period detected is %t", (tperiod - tperiod1)); 
	end
	else
		freq_error = 1'b0;

end // always
//**************************frequency validation**********************///
always @ (SCK)
begin
     if(SCK == 1'b1)
     begin
     	clk_val    <= $time;
     	clk_val_d  <= clk_val;
     end
     
end
always @ (SCK)
begin
     clk_diff <= clk_val - clk_val_d;
end

always @ (SCK)
begin
      if (clk_diff  > time_10ns || clk_diff == time_10ns)
      tMAX <= 1'b0;
      else if(clk_diff  < time_10ns)
      tMAX <= 1'b1;

      if(clk_diff > time_12ns || clk_diff == time_12ns)
      tRDDO <= 1'b0;
      else if(clk_diff < time_12ns)
      tRDDO <= 1'b1;

      if(clk_diff > time_20ns || clk_diff == time_20ns)
      tRDLF <= 1'b0;
      else if(clk_diff < time_20ns)
      tRDLF <= 1'b1;

end

// ************************************************************* //
specify
	specparam tCSLS = 5;
	specparam tCSLH = 5;
	specparam tCSHS = 5;
	specparam tCSHH = 5;
	specparam tCSH = 50;
	specparam tHHH = 5;
	specparam tHLS = 5;
	specparam tHLH = 5;
	specparam tHHS = 5;
	specparam tDS     = 2 ;         // Data in Setup time
	specparam tDH     = 1 ;         // Data in Hold time
	specparam tCLKH   = 4.3;
	specparam tCLKL   = 4.3;

	$width (posedge SCK, tCLKH);
	$width (negedge SCK, tCLKL);
  
/* 
	$setup (SI, posedge SCK &&& ~(dout_phase || dummy_phase), tDS);
	$hold (posedge SCK, SI &&& ~(dout_phase || dummy_phase), tDH);

	$setup (SO, posedge SCK &&& (((sdindual_en || sdinquad_en)) && ~dout_phase), tDS);
	$hold (posedge SCK, SO &&& (((sdindual_en || sdinquad_en)) && ~dout_phase), tDH);

	$setup (HOLDB, posedge SCK &&& (sdinquad_en && ~dout_phase), tDS);
	$hold (posedge SCK, HOLDB &&& (sdinquad_en && ~dout_phase), tDH);

	$setup (WPB, posedge SCK &&& (sdinquad_en && ~dout_phase), tDS);
	$hold (posedge SCK, WPB &&& (sdinquad_en && ~dout_phase), tDH);

	$setup (HOLDB, posedge SCK &&& (~CSB && ~QE), tHLS);
	$hold (negedge SCK, HOLDB &&& (~CSB && ~QE), tHLH);
	$setup (HOLDB, negedge SCK &&& (~CSB && ~QE), tHHS);
	$hold (posedge SCK, HOLDB &&& (~CSB && ~QE), tHHH);
 */

	$setup (CSB, posedge SCK, tCSLS);
	$hold ( posedge SCK, CSB, tCSLH);
	$setup (posedge CSB, posedge SCK, tCSHS);
	$hold ( posedge SCK, posedge CSB, tCSHH);
	$width (posedge CSB, tCSH);
endspecify

// ************************************************************* //
// For HOLDB pin spec.

assign CLK = ~HOLD_EN & SCK;
assign #(tHLQZ, tHHQX) SO_EN = ((HOLD_EN==1'b0) & (dout_phase==1'b1)) ? 1'b1 : 1'b0;
assign #(tHLQZ, tHHQX) SI_EN = ((HOLD_EN==1'b0) & (dout_phase==1'b1) & ((sdindual_en==1'b1)|(sdinquad_en==1'b1))) ? 1'b1 : 1'b0;
assign #(tHLQZ, tHHQX) WPB_EN = ((HOLD_EN==1'b0) & (dout_phase==1'b1) & (sdinquad_en==1'b1)) ? 1'b1 : 1'b0;
assign #(tHLQZ, tHHQX) HOLDB_EN = ((HOLD_EN==1'b0) & (dout_phase==1'b1) & (sdinquad_en==1'b1)) ? 1'b1 : 1'b0;


wire CSB_DEL;
assign #(20, 0) CSB_DEL = CSB;

//**************************Byte Boundary checking**********************///
//SPI Clock Counter
always @(posedge CLK or posedge CSB_DEL)
begin : sckcnt_
	if (CSB_DEL==1'b1)
		sckcnt	<= 0;
	else	
		sckcnt 	<= sckcnt + 1;
end

//
always @(sckcnt)
begin
	if (sdinquad_en==1'b1)	 
		abort_boundary = (sckcnt[0] == 1'b1) ? 1'b1 : 1'b0;
	else if (sdindual_en==1'b1)	 
		abort_boundary = (|sckcnt[1:0] == 1'b1) ? 1'b1 : 1'b0;
	else
		abort_boundary =  (|sckcnt[2:0] == 1'b1) ? 1'b1 : 1'b0;
end

//Command regs 
always @(posedge CLK or posedge CSB_DEL)
begin : cmd_regs
	if (CSB_DEL == 1'b1)
	begin
		cmd_1byte <=	1'b0; 
		cmd_2byte <=	1'b0;
		cmd_4byte <=	1'b0;
		cmd_5byte <=	1'b0;
	end
	else if (sckcnt == 5'h07)
		cmd_1byte <= 1'b1;
	else if (sckcnt == 5'h0f)
		cmd_2byte <= 1'b1;
	else if (sckcnt == 5'h1f)
		cmd_4byte <= 1'b1;
	else	if ((sckcnt == 8'h21) && (sdinquad_en==1'b1))
		cmd_5byte <= 1'b1;
	else	if ((sckcnt == 8'h23) && (sdindual_en==1'b1))
		cmd_5byte <= 1'b1;
	else	if (sckcnt == 8'h27)
		cmd_5byte <= 1'b1;
	else
	begin
		cmd_1byte <= cmd_1byte;
		cmd_2byte <= cmd_2byte;
		cmd_4byte <= cmd_4byte;
		cmd_5byte <= cmd_5byte;
	end
end

// hold latch  
always @(QE or HOLDB or SCK or CSB)
begin : hold_en_ 
	if (~QE)
	begin
		if (CSB==1'b1)
		begin
			HOLD_EN	<= 0;
			abort_holdb <= ~HOLDB;
		end
		else	if (SCK==1'b0)
			HOLD_EN 	<= ~HOLDB;
	end
	else if (QE)
	begin
		HOLD_EN <= 0;
		abort_holdb <= 0;
	end
end

always @(abort_boundary or abort_holdb)
begin
	abort = abort_boundary | abort_holdb;
end

///// Output control Registers
always @(SI_EN)
begin : SI_on_ 
	SI_on = SI_EN ;
end 

always @(SO_EN)
begin : SO_on_ 
	SO_on = SO_EN ;
end 

always @(WPB_EN)
begin : WPB_on_ 
	WPB_on = WPB_EN ;
end 

always @(HOLDB_EN)
begin : HOLDB_on_ 
	HOLDB_on = HOLDB_EN ;
end 

//Sector Lock Down
always @ (SLD)
begin : SLD_
	if (RDYnBSY == 1'b1) // device is already busy
		begin
			$display("Device is busy. Sector Lock Down cannot be Issued");
			disable SLD_ ;   
		end
     get_data;
	temp_addr [23:16] = read_data [7:0];
	get_data;
	temp_addr [15:8] = read_data [7:0];
	get_data;
	temp_addr [7:0] = read_data [7:0];

	current_address = {5'h00 , temp_addr[18:0]};

     get_data;
	con_byte = read_data[7:0];

	@(posedge CSB);
	if ((abort == 1'b1) | (WEL==1'b0) | (cmd_5byte==1'b0))
		begin
    			$display("The CSB deasserted at Non even byte boundary or WEL is not SET.  Aborting Sector Lock Down" );
			WEL = 1'b0;
        		disable SLD_;
		end
     if (con_byte != 8'hd0)
    		begin
       		$display("Confirmation byte received is Wrong Aborting Sector Lock Down");
               WEL = 1'b0;
       		disable SLD_; 
       	end
     if (SLE==1'b0)
		begin
			$display("SLE bit not set or permanently disabled. Abort Sector Lockdown command");
               WEL = 1'b0;
			disable SLD_ ;
		end
	else
    	sec_lockdown  = 1'b1;
	sect_lock_flag = 1'b1;
    	RDYnBSY = 1'b1;
    	#tLOCK;
	sector_lock_down(current_address);
    	WEL  = 1'b0;
    	sec_lockdown  = 1'b0;
    	RDYnBSY = 1'b0;
end

//Freeze sector lock Down
always @ (FSL)
begin : FSL_
	if (RDYnBSY == 1'b1) // device is already busy
		begin
			$display("Device is busy. Freez Sector Lock Down cannot be Issued");$display("Unrecognized opcode  %h", read_data);
			disable FSL_ ;   
		end
     get_data;
	temp_addr [23:16] = read_data [7:0];
	get_data;
	temp_addr [15:8] = read_data [7:0];
	get_data;
	temp_addr [7:0] = read_data [7:0];

	current_address = {5'h00 , temp_addr[18:0]};
	specific_address = 24'h05aa40;			// for 4Meg

     get_data;   
     con_byte = read_data[7:0];
        
     @(posedge CSB);
	if ((abort == 1'b1) || (WEL==1'b0) || (SLE==1'b0) || (cmd_5byte==1'b0))
	begin
		$display("The CSB deasserted at Non even byte boundary or WEL or SLE is not SET. Aborting Freeze Sector Lock Down" );
    		WEL = 1'b0;
    		disable FSL_;
	end
    	if((current_address != specific_address) || (con_byte != 8'hd0))
	begin
		$display("Neither correct Specific Address nor Confirmation Byte received.  Aborting Freeze Sector Lock Down" );
    		WEL = 1'b0;
    		disable FSL_;
	end
    	$display("Freeze Lock Down no Further Modification to Sector Lock Down");
	Freez_sec_lockdown = 1'b1;
    	RDYnBSY = 1'b1;
    	#tLOCK;
	Freez_lockdown[0] = 8'hFF;
    	Freez_sector_lockdown = 1'b1;
    	SLE = 1'b0;
    	WEL = 1'b0;
    	RDYnBSY = 1'b0;
	Freez_sec_lockdown = 1'b0;
end 

//Read Sector Lock Down register
always @ (RSLR)
begin :RSLR_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		$display("Device %s is busy. Read Array is not allowed", DEVICE);
		disable RSLR_;
	end
     get_data;
	temp_addr [23:16] = read_data [7:0];
	get_data;
	temp_addr [15:8] = read_data [7:0];
	get_data;
	temp_addr [7:0] = read_data [7:0];

	current_address = {5'h00 , temp_addr[18:0]};
        
     check_lock_down(current_address);
     if(sect_locked==1'b1)
		$display("Sector for Address %h is Locked", current_address);
	else
		$display("Sector for Address %h is UNLocked", current_address);
	send_sector_lock_status;	// sending the Sector Protection Register content in SO
	current_address = 24'b0;
	$display("Read Sector Lock down  Register completed");
         
end
 
//Programe OTP Security register
always @ (POSR)
begin :POSR_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		$display("Device %s is busy. OTP is not allowed", DEVICE);
		disable POSR_;
	end
	if (tMAX==1'b1)
	$display("WARNING: Frequency should be less than fMAX.");

	// to receive 3 bytes of address
	get_data;
	temp_addr [23:16] = read_data [7:0];
	get_data;
	temp_addr [15:8] = read_data [7:0];
	get_data;
	temp_addr [7:0] = read_data [7:0];

	current_address = {5'h00 , temp_addr[18:0]};
        
     page_otp_program(current_address[5:0]);				// return pp_h value

	if ((abort == 1'b1) || (WEL==1'b0) || (cmd_5byte==1'b0))
	begin
		$display("The CSB deasserted at Non even byte boundary or WEL is not set.  Aborting Program OTP Security Register" );
         	WEL = 1'b0;
    		disable POSR_;
	end
     if (security_flag == 1'b1)
	begin
         	$display("Security OTP Register has been modified before.  Abort Program OTP Security Register");
          WEL = 1'b0;
		disable POSR_ ;
	end
	RDYnBSY = 1'b1;
	OTP_address = current_address[5:0];
	otp_sec_prog = 1'b1;
	for(pp = 0; pp < pp_h; pp = pp+1)
	begin
		data_in = OTP_buffer[OTP_address];
		OTP_program(OTP_address, data_in);
		OTP_address = OTP_address + 1'b1;
	end
	security_flag = 1'b1;
	$display("OTP write completed");
	#tOTPP;
	pp_h		 = 0;
	pp_j		 = 0;
	pp_i		 = 0;
	WEL		 = 1'b0;
	RDYnBSY		 = 1'b0;
	current_address  = 24'b0;
	OTP_address	 = 8'b0;
	data_in		 = 8'b0;
	otp_sec_prog = 1'b0;
end 

task page_otp_program;
input [5:0]pp_j;
reg [6:0]count_OTP;
begin
	count_OTP = 0;
	while(CSB==1'b0)
	begin
		for (pp_i=7; pp_i>=0; pp_i = pp_i-1)
		begin
			@(posedge CLK);  
			read_data[pp_i] = SI;
		end
		OTP_buffer[pp_j] = read_data;
          $display("The ppj value %h,%h ",read_data,pp_j);
		pp_j = pp_j+1;
          count_OTP = count_OTP+1;
		pp_h = count_OTP;
		if(count_OTP >= 63)
			count_OTP = 63;

		$display("One byte of data: %h received for OTP Program",read_data);
	end
end
endtask


task OTP_program;
input [5:0] write_address;
input [7:0] write_data;
begin
	security_reg[write_address] = write_data;
	$display("One Byte of data %h written in security location %h", write_data, write_address);
end
endtask


//Read OTP Security Register
always @(ROSR)
begin : ROSR_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		$display("Device %s is busy. Read OTP is not allowed", DEVICE);
		disable ROSR_;
	end
	// if it comes here, means, the above if was false.

   if (tMAX==1'b1)
	$display("WARNING: Frequency should be less than fMAX");

	get_data;
	temp_addr [23:16] = read_data [7:0];
	get_data;
	temp_addr [15:8] = read_data [7:0];
	get_data;
	temp_addr [7:0] = read_data [7:0];
	current_address = temp_addr;

	OTP_rd_address = current_address[6:0];

	for(i = rd_dummy ; i>0 ; i = i - 1)
    	begin
        	for (j = 7; j >= 0; j = j - 1) // these are dont-care, so discarded
		begin
			@(posedge CLK);  
			read_dummy[j] = SI;
    		end
    		read_dummy = 8'h0;
	end

	read_OTP_security(OTP_rd_address); // read continuously from memory untill CSB deasserted
	current_address = 24'b0;
end

task read_OTP_security ;
input [6:0] read_addr;
integer i;

begin
	temp_data = OTP_reg [read_addr];		// access the Manu upper 64-bytes
     j = 7;
	while (CSB == 1'b0) // continue transmitting, while, CSB is Low
	begin
		@(negedge CLK);
		dout_phase = 1'b1;
		SO_reg = 1'bx;
		#tV;
		SO_reg = temp_data[j];
		if (j == 0) 
		begin
			$display("Data: %h read from OTP memory location %h",temp_data,read_addr);
			read_addr = read_addr + 1; // next byte
         		j = 7;
			temp_data = OTP_reg [read_addr];
		end
		else
			j = j - 1; // next bit
	end		// reading over, because CSB has gone high
end
endtask

always @(*)
begin
	for (j=0; j<128; j=j+1)
	begin
		if (j<64)
			OTP_reg[j] = security_reg[j];
		else
			OTP_reg[j] = factory_reg[j-64];
	end
end

//--------------------------------------------------------
//Read Configuration Register
always @(RCFGR)
begin : RCFGR_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		$display("Device %s is busy. Read CFG is not allowed", DEVICE);
		disable RCFGR_;
	end
	// if it comes here, means, the above if was false.

   if (tMAX==1'b1)
	$display("WARNING: Frequency should be less than fMAX");
     j = 7;
    	while (CSB == 1'b0)
    	begin
		@(negedge CLK);
		dout_phase = 1'b1;
	 	SO_reg = 1'bx;
		#tV;
		SO_reg = CFG_reg[j];
         	if(j == 0)
         	begin
    			//$display("Configuration register of Device %s transmitted", DEVICE);
         		j = 7;
         	end
		else
			j = j - 1;	// next bit
   	end
end
//--------------------------------------------------------

task sector_lock_down;
input [23:0] Sector_lock_address;
integer i;
begin
	for (i=0; i<SECTORS; i=i+1)
		if (Sector_lock_address[MADDRESS-1:16]==i)
		begin
			lock_reg[i] = 8'hff;
			lock_status[i] = 1'b1;
		end
end
endtask

task check_lock_down;
input [23:0] check_address;
integer i;
begin
	sect_locked = 1'b0;
	for (i=0; i<SECTORS; i=i+1)
		if (check_address[MADDRESS-1:16]==i)
			sect_locked = lock_status[i];
end
endtask

task send_sector_lock_status;
integer local_i;
integer i;
reg [7:0] send_status;	// status value, 'ff' if protected, '00' if unprotected
begin
	if(sect_locked==1'b1)
		send_status = 8'hff;
	else
		send_status = 8'h00;
     local_i = 7;
	while (CSB == 1'b0) // continue transmitting, while, CSB is Low
	begin
		@(negedge CLK);
		dout_phase = 1'b1;
		SO_reg = 1'bx;
		#tV;
          SO_reg = send_status[local_i];
		if (local_i == 0) 
			local_i = 7;
		else
			local_i = local_i - 1; // next bit
     end         // sending status over, because CSB has gone high
 
end
endtask

always @ (DORA)
begin : DORA_
     if (RDYnBSY == 1'b1) // device is already busy
		begin
			$display("Device is busy. Dual Output read array cannot performed");
			disable DORA_ ;   
		end
     if (tRDDO==1'b1)
	$display("WARNING: Frequency should be less than fRDDO");
     get_data;
	temp_addr [23:16] = read_data [7:0];
	get_data;
	temp_addr [15:8] = read_data [7:0];
	get_data;
	temp_addr [7:0] = read_data [7:0];

	current_address = {5'h00 , temp_addr[18:0]};


     for(i = rd_dummy ; i>0 ; i = i - 1)
     begin
         	for (j=7; j>= 0; j=j-1) // these are dont-care, so discarded
		begin
			@(posedge CLK);  
			read_dummy[j] = SI;
	    	end
	    	read_dummy = 8'h0;
	end
	sdindual_en = 1'b1;
	Dual_out_array(current_address); // read continuously from memory untill CSB deasserted
	current_address = 24'b0;
end
task Dual_out_array ;
input [23:0] read_addr;
integer i;

begin
      //$display("Attempt to Read a Suspended Sector.  The data is undefined ");
	temp_data = memory [read_addr];
	i = 3;
	while (CSB == 1'b0) // continue transmitting, while, CSB is Low
	begin
		@(negedge CLK);
		dout_phase = 1'b1;
		SO_reg = 1'bx;
    		SI_reg = 1'bx;
		#tV;
         	SI_reg = temp_data[i*2];
		SO_reg = temp_data[i*2+1];
		if (i == 0) 
		begin
			$display("Data: %h read from memory location %h",temp_data,read_addr);
			read_addr = read_addr + 1; // next byte
    			i = 3;
			if (read_addr >= MEMSIZE)
				read_addr = 0; // Note that rollover occurs at end of memory,
			temp_data = memory [read_addr];
		end
		else
			i = i -1; // next bit
	end	// reading over, because CSB has gone high
end
endtask

//-----------------------------------------------------------------------------------------
always @ (QORA)
begin : QORA_
     if (RDYnBSY == 1'b1) // device is already busy
		begin
			$display("Device is busy. Quad Output read array cannot performed");
			disable QORA_ ;   
		end
     if (tRDDO==1'b1)
	$display("WARNING: Frequency should be less than fRDDO");
     get_data;
	temp_addr [23:16] = read_data [7:0];
	get_data;
	temp_addr [15:8] = read_data [7:0];
	get_data;
	temp_addr [7:0] = read_data [7:0];

	current_address = {5'h00 , temp_addr[18:0]};


     for(i = rd_dummy ; i>0 ; i = i - 1)
     begin
         	for (j=7; j>= 0; j=j-1) // these are dont-care, so discarded
		begin
			@(posedge CLK);  
			read_dummy[j] = SI;
	    	end
	    	read_dummy = 8'h0;
	end
	sdinquad_en = 1'b1;
	Quad_out_array(current_address); // read continuously from memory untill CSB deasserted
	current_address = 24'b0;
end

task Quad_out_array ;
input [23:0] read_addr;
integer i;

begin
      //$display("Attempt to Read a Suspended Sector.  The data is undefined ");
	temp_data = memory [read_addr];
	i = 1;
	while (CSB == 1'b0) // continue transmitting, while, CSB is Low
	begin
		@(negedge CLK);
		dout_phase = 1'b1;
    		SI_reg = 1'bx;
		SO_reg = 1'bx;
		WPB_reg = 1'bx;
		HOLDB_reg = 1'bx;
		#tV;
         	SI_reg = temp_data[i*4];
		SO_reg = temp_data[i*4+1];
		WPB_reg = temp_data[i*4+2];
		HOLDB_reg = temp_data[i*4+3];
		if (i == 0) 
		begin
			$display("Data: %h read from memory location %h",temp_data,read_addr);
			read_addr = read_addr + 1; // next byte
    			i = 1;
			if (read_addr >= MEMSIZE)
				read_addr = 0; // Note that rollover occurs at end of memory,
			temp_data = memory [read_addr];
		end
		else
			i = i -1; // next bit
	end	// reading over, because CSB has gone high
end
endtask

//---------------------------------------------------------------------------------------------------
always @(DIPG)
begin : DIPG_
     if (RDYnBSY == 1'b1) // device is already busy
		begin
			$display("Device is busy. Dual Output read array cannot performed");
			disable DIPG_ ;   
		end

       // to receive 3 bytes of address
	get_data;
	temp_addr [23:16] = read_data [7:0];
	get_data;
	temp_addr [15:8] = read_data [7:0];
	get_data;
	temp_addr [7:0] = read_data [7:0];

	sdindual_en = 1'b1;
	current_address = {5'h00 , temp_addr[18:0]};

	check_protection(current_address);
    	check_lock_down(current_address);

     buffer_write(current_address[7:0]);						// page program - receives data
     
	if((abort == 1) || (WEL==1'b0) || (cmd_5byte==1'b0))	// page program should not proceed if CSB deasserted at intermediate points
	begin
		$display("Chip Select deasserted in non-even byte boundary or WEL is not set. Abort Dual Byte/Page Program command");
		WEL = 1'b0;
		sdindual_en = 1'b0;
		disable DIPG_ ;
	end
     if(sect_locked == 1'b1)
    	begin
    		$display("Sector Lock Down issued to this address. Dual Byte/Page Program is not allowed");
    		WEL = 1'b0;
		sdindual_en = 1'b0;
    		disable DIPG_;
    	end
	if(protected==1'b1) 
	begin
		$display("Sector for Address %h is Protected . Dual Byte Program cannot be performed", current_address);
		WEL = 1'b0;
		sdindual_en = 1'b0;
		disable DIPG_ ;
	end
	$display("Sector for Address %h is UnProtected, Dual Byte Program can be performed", current_address);
	sdindual_en = 1'b0;
	RDYnBSY = 1'b1;
	dual_byte_prog = 1'b1;
	page_program(current_address[7:0]);
	if (reset == 1'b1)
    	begin
         	$display("Device is in reset mode");
         	reset = 1'b0;
         	disable DIPG_;
	end
	$display("Dual Byte write completed");
	pp		 = 0;
	pp_h		 = 0;
	pp_i		 = 0;
	WEL		 = 1'b0;
	RDYnBSY		 = 1'b0;
	dual_byte_prog	 = 1'b0;
	current_address  = 24'b0;
	pp_address	 = 8'b0;
	data_in		 = 8'b0;
end

//---------------------------------------------------------------------------------------------------
always @(QIPG)
begin : QIPG_
     if (RDYnBSY == 1'b1) // device is already busy
		begin
			$display("Device is busy. Quad Input Page Program cannot performed");
			disable QIPG_ ;   
		end

       // to receive 3 bytes of address
	get_data;
	temp_addr [23:16] = read_data [7:0];
	get_data;
	temp_addr [15:8] = read_data [7:0];
	get_data;
	temp_addr [7:0] = read_data [7:0];

	sdinquad_en = 1'b1;
	current_address = {5'h00 , temp_addr[18:0]};

	check_protection(current_address);
    	check_lock_down(current_address);

     buffer_write(current_address[7:0]);						// page program - receives data
     
	if((abort == 1) || (WEL==1'b0) || (cmd_5byte==1'b0))	// page program should not proceed if CSB deasserted at intermediate points
	begin
		$display("Chip Select deasserted in non-even byte boundary or WEL is not set. Abort Quad Byte/Page Program command");
		WEL = 1'b0;
		sdinquad_en = 1'b0;
		disable QIPG_ ;
	end
     if(sect_locked == 1'b1)
    	begin
    		$display("Sector Lock Down issued to this address. Quad Byte/Page Program is not allowed");
    		WEL = 1'b0;
		sdinquad_en = 1'b0;
    		disable QIPG_;
    	end
	if(protected==1'b1) 
	begin
		$display("Sector for Address %h is Protected . Quad Byte Program cannot be performed", current_address);
		WEL = 1'b0;
		sdinquad_en = 1'b0;
		disable QIPG_ ;
	end
	$display("Sector for Address %h is UnProtected, Quad Byte Program can be performed", current_address);
	sdinquad_en = 1'b0;
	RDYnBSY = 1'b1;
	quad_byte_prog = 1'b1;
	page_program(current_address[7:0]);
	if (reset == 1'b1)
    	begin
         	$display("Device is in reset mode");
         	reset = 1'b0;
         	disable QIPG_;
	end
	$display("Quad Byte write completed");
	pp		 = 0;
	pp_h		 = 0;
	pp_i		 = 0;
	WEL		 = 1'b0;
	RDYnBSY		 = 1'b0;
	quad_byte_prog	 = 1'b0;
	current_address  = 24'b0;
	pp_address	 = 8'b0;
	data_in		 = 8'b0;
end

//-----------------------------------------------------------------------------------------------------------
always @ (RST)
begin:RST_
	if (tMAX==1'b1)
		$display("WARNING: Frequency should be less than fMAX");
	get_data;
     	con_byte = read_data[7:0];

	@(posedge CSB);
	if ((abort == 1'b1) | (cmd_2byte==1'b0))
	begin
     	$display("Chip Select deasserted at non-even byte boundary.  Abort Reset Command");
		disable RST_;
	end
     if(con_byte != 8'hD0)
    	begin
    		$display("The Confirmation Byte received is wrong %h.  Abort Reset Command",con_byte);
    		disable RST_;
    	end
     if(RSTE == 1'b0)
     begin
     	$display("RSTE Bit is not set.  Abort Reset Command");
       	disable RST_;
     end
	if (RDYnBSY==1'b0)
     begin
     	$display("Device is not busy.  Abort Reset Command");
       	disable RST_;
     end
	if ((otp_sec_prog==1'b1) || (sec_lockdown==1'b1) || (Freez_sec_lockdown==1'b1))
     begin
     	$display("Chip is not in memory modified mode.  Abort Reset Command");
       	disable RST_;
     end
	reset_request = 1'b1;
     $display("The Reset signal Issued and Device Entered into Idle State");
end

// ******** Posedge CSB. Stop all reading, recvng. commands/addresses etc. ********* //

always @(posedge CSB)
begin
	disable RA_;		// Read Array (low freq and normal freq)
	disable MIR_;		// MIR will stop, if CSB goes high
	disable RSR_;		// Status reading should stop.
	disable RCFGR_;	// CFG reading should stop.
	disable DORA_;		// Dual Output Read Array.
	disable QORA_;		// Quad Output Read Array.
	disable ROSR_;		// OTP Security Register.

	disable read_out_array;		// send data in SO
	disable Dual_out_array;		// send data in SO
	disable Quad_out_array;		// send data in SO
	disable send_protection_status; // Send Protection status
	disable send_sector_lock_status; // Send LOCk Protection status
	disable buffer_write;
	disable page_otp_program;
     disable read_OTP_security;
	temp_data = 8'b0;
	rd_dummy  = 0;
	dummy_phase = 1'b0;

	#tDIS SO_on = 1'b0;  // SO is now in high-impedance
	SO_reg = 1'b0;
     SI_reg = 1'b0;
     SI_on  = 1'b0;
     WPB_on  = 1'b0;
     HOLDB_on  = 1'b0;
	dout_phase = 1'b0;
	sdindual_en = 1'b0;
	sdinquad_en = 1'b0;
end
       
//----------------------------------------------------------------------------------
// ******** Posedge CSB_DEL.  commands/addresses etc. ********* //

always @(posedge CSB_DEL)
begin
	disable get_data;		// Stop address/data retrieval
	disable get_opcode;
	read_data = 8'b0;
end
      
endmodule 
