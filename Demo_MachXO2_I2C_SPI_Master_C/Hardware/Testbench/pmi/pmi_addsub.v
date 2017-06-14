// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Copyright (c) 2005-2010 by Lattice Semiconductor Corporation
// --------------------------------------------------------------------
//
//
//                     Lattice Semiconductor Corporation
//                     5555 NE Moore Court
//                     Hillsboro, OR 97214
//                     U.S.A.
//
//                     TEL: 1-800-Lattice  (USA and Canada)
//                          1-408-826-6000 (other locations)
//
//                     web: http://www.latticesemi.com/
//                     email: techsupport@latticesemi.com
//
// --------------------------------------------------------------------
//
// Simulation Library File for PMI AddSub
//
// Paramater Definition
//Name                           Value                           Default
/*
------------------------------------------------------------------------
 pmi_data_width                <integer>                             8
 pmi_result_width              <integer>                             8
 pmi_sign                      "on"|"off"                          "off"
 pmi_family  "EC"|"XP"|"XP2"|"ECP"|"ECP2"|"ECP2M"|"ECP3"|"ECP4"|"XO"|"XO2"|"LPTM"  "EC"
------------------------------------------------------------------------
Note:

 1. Cin should be tied to !Add_sub if Carry-in is not being used.
 
 2. To get addsub without Cout or Overflow, leave Cout and Overflow ports
    unconnected.
 
 3. For signed addsub, Overflow ports should be used; Cout port should be left
    unconneced.
 
 4. For unsigned addsub, Carry port should be used; Overflow port should be 
    left unconnected.

WARNING: Do not change the default parameters in this model. Parameter 
redefinition must be done using defparam or in-line (#) paramater 
redefinition in a top level file that instantiates this model.
 
*/ 
 
// fpga\verilog\pkg\versclibs\data\pmi\pmi_addsub.v 1.11 29-DEC-2010 13:11:46 IALMOHAN

`timescale 1 ns / 1 ps
module pmi_addsub #(parameter pmi_data_width = 8,
		    parameter pmi_result_width = 8,
		    parameter pmi_sign = "off",
		    parameter pmi_family = "EC",
		    parameter module_type = "pmi_addsub"
		    )
  
  (
   input [pmi_data_width-1:0] DataA,
   input [pmi_data_width-1:0] DataB,
   input Cin,
   input Add_Sub,
   output [pmi_data_width-1:0] Result,
   output Cout,
   output Overflow)/*synthesis syn_black_box */;

   //synopsys translate_off
   tri0   Cin_wire;
   //synopsys translate_on

   buf (Cin_wire, Cin);

   //pragma translate_off
   generate
      if (pmi_sign == "off")
      pmi_addsub_unsign #(.pmi_data_width(pmi_data_width),
			  .pmi_result_width(pmi_result_width)
			  )
      unsign_inst (
		   .DataA(DataA),
		   .DataB(DataB),
		   .Cin(Cin_wire),
		   .Add_Sub(Add_Sub),
		   .Result(Result),
		   .Cout(Cout)
		   );
      else
      pmi_addsub_sign #(.pmi_data_width(pmi_data_width),
			.pmi_result_width(pmi_result_width)
		     )
      sign_inst (
		 .DataA(DataA),
		 .DataB(DataB),
		 .Cin(Cin_wire),
		 .Add_Sub(Add_Sub),
		 .Result(Result),
		 .Overflow(Overflow)
		 );
   endgenerate
   //pragma translate_on

endmodule // pmi_addsub

//SubModules

module pmi_addsub_unsign #(parameter pmi_data_width = 8,
			parameter pmi_result_width = 8)
  (
   input [pmi_data_width-1:0] DataA,
   input [pmi_data_width-1:0] DataB,
   input Cin,
   input Add_Sub,
   output [pmi_data_width-1:0] Result,
   output Cout);

   wire [pmi_data_width:0] tmp_addResult = DataA + DataB + Cin;
   wire [pmi_data_width:0] tmp_subResult = DataA - DataB - !Cin;
   
   
   assign Result = (Add_Sub == 1) ? tmp_addResult[pmi_data_width-1:0] : tmp_subResult[pmi_data_width-1:0];

   assign Cout = (Add_Sub == 1) ? tmp_addResult[pmi_data_width] : !tmp_subResult[pmi_data_width];
      
endmodule // pmi_addsub_unsign

module pmi_addsub_sign #(parameter pmi_data_width = 8,
		      parameter pmi_result_width = 8)
  (
   input [pmi_data_width-1:0] DataA,
   input [pmi_data_width-1:0] DataB,
   input Cin,
   input Add_Sub,
   output [pmi_data_width-1:0] Result,
   output Overflow);
   
   wire [pmi_data_width:0] tmp_addResult = DataA + DataB + Cin;
   wire [pmi_data_width:0]   tmp_subResult = (Cin == 1) ? (DataA - DataB) : (DataA - DataB - 1);
   
   wire   tmp_addOverflow = (DataA[pmi_data_width-1] == DataB[pmi_data_width-1]) && (DataA[pmi_data_width-1] != tmp_addResult[pmi_data_width-1]) ? 1:0;

   wire   tmp_subOverflow = (DataA[pmi_data_width-1] != DataB[pmi_data_width-1]) && (DataA[pmi_data_width-1] != tmp_subResult[pmi_data_width-1]) ? 1:0;
      
   assign Result = (Add_Sub == 1) ? tmp_addResult[pmi_data_width-1:0] : tmp_subResult[pmi_data_width-1:0];
      
   assign Overflow = (Add_Sub == 1) ? tmp_addOverflow : tmp_subOverflow;

   
endmodule // pmi_addsub_sign


