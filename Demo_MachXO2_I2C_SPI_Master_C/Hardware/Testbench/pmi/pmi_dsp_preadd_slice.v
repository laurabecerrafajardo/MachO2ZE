// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Copyright (c) 2005-2011 by Lattice Semiconductor Corporation
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
// Simulation Library File for PMI DSP-based PRE-ADD SLICE
//
// Parameter Definition
//Name                               Value                             Default
/*
---------------------------------------------------------------------------------
  pmi_data_m0a_width                 2 to 18                             18
  pmi_data_m0b_width                 2 to 18                             18
  pmi_data_m1a_width                 2 to 18                             18
  pmi_data_m1b_width                 2 to 18                             18
  pmi_data_m0c_width                 2 to 18                             18
  pmi_data_m1c_width                 2 to 18                             18
  pmi_gsr                            "enable"|"disable"               "enable"
  pmi_family                         "ECP4"                             "ECP4"
  pmi_reg_input_m0a_pre_clk          "CLK0"|"CLK1"|"CLK2"|"CLK3"        "CLK0"
  pmi_reg_input_m0a_pre_ce           "CE0"|"CE1"|"CE2"|"CE3"            "CE0"
  pmi_reg_input_m0a_pre_rst          "RST0"|"RST1"|"RST2"|"RST3"        "RST0"
  pmi_reg_input_m0b_pre_clk          "CLK0"|"CLK1"|"CLK2"|"CLK3"        "CLK0"
  pmi_reg_input_m0b_pre_ce           "CE0"|"CE1"|"CE2"|"CE3"            "CE0"
  pmi_reg_input_m0b_pre_rst          "RST0"|"RST1"|"RST2"|"RST3"        "RST0"
  pmi_reg_input_m0a_mult_clk         "CLK0"|"CLK1"|"CLK2"|"CLK3"        "CLK0"
  pmi_reg_input_m0a_mult_ce          "CE0"|"CE1"|"CE2"|"CE3"            "CE0"
  pmi_reg_input_m0a_mult_rst         "RST0"|"RST1"|"RST2"|"RST3"        "RST0"
  pmi_reg_input_m0b_mult_clk         "CLK0"|"CLK1"|"CLK2"|"CLK3"        "CLK0"
  pmi_reg_input_m0b_mult_ce          "CE0"|"CE1"|"CE2"|"CE3"            "CE0"
  pmi_reg_input_m0b_mult_rst         "RST0"|"RST1"|"RST2"|"RST3"        "RST0"
  pmi_reg_input_m1a_pre_clk          "CLK0"|"CLK1"|"CLK2"|"CLK3"        "CLK0"
  pmi_reg_input_m1a_pre_ce           "CE0"|"CE1"|"CE2"|"CE3"            "CE0"
  pmi_reg_input_m1a_pre_rst          "RST0"|"RST1"|"RST2"|"RST3"        "RST0"
  pmi_reg_input_m1b_pre_clk          "CLK0"|"CLK1"|"CLK2"|"CLK3"        "CLK0"
  pmi_reg_input_m1b_pre_ce           "CE0"|"CE1"|"CE2"|"CE3"            "CE0"
  pmi_reg_input_m1b_pre_rst          "RST0"|"RST1"|"RST2"|"RST3"        "RST0"
  pmi_reg_input_m1a_mult_clk         "CLK0"|"CLK1"|"CLK2"|"CLK3"        "CLK0"
  pmi_reg_input_m1a_mult_ce          "CE0"|"CE1"|"CE2"|"CE3"            "CE0"
  pmi_reg_input_m1a_mult_rst         "RST0"|"RST1"|"RST2"|"RST3"        "RST0"
  pmi_reg_input_m1b_mult_clk         "CLK0"|"CLK1"|"CLK2"|"CLK3"        "CLK0"
  pmi_reg_input_m1b_mult_ce          "CE0"|"CE1"|"CE2"|"CE3"            "CE0"
  pmi_reg_input_m1b_mult_rst         "RST0"|"RST1"|"RST2"|"RST3"        "RST0"
  pmi_reg_input_m0c_clk              "CLK0"|"CLK1"|"CLK2"|"CLK3"        "CLK0"
  pmi_reg_input_m0c_ce               "CE0"|"CE1"|"CE2"|"CE3"            "CE0"
  pmi_reg_input_m0c_rst              "RST0"|"RST1"|"RST2"|"RST3"        "RST0"
  pmi_reg_input_m1c_clk              "CLK0"|"CLK1"|"CLK2"|"CLK3"        "CLK0"
  pmi_reg_input_m1c_ce               "CE0"|"CE1"|"CE2"|"CE3"            "CE0"
  pmi_reg_input_m1c_rst              "RST0"|"RST1"|"RST2"|"RST3"        "RST0"
  pmi_reg_input_cfb_clk              "CLK0"|"CLK1"|"CLK2"|"CLK3"        "CLK0"
  pmi_reg_input_cfb_ce               "CE0"|"CE1"|"CE2"|"CE3"            "CE0"
  pmi_reg_input_cfb_rst              "RST0"|"RST1"|"RST2"|"RST3"        "RST0"
  pmi_reg_pipeline0_clk              "CLK0"|"CLK1"|"CLK2"|"CLK3"        "CLK0"
  pmi_reg_pipeline0_ce               "CE0"|"CE1"|"CE2"|"CE3"            "CE0"
  pmi_reg_pipeline0_rst              "RST0"|"RST1"|"RST2"|"RST3"        "RST0"
  pmi_reg_pipeline1_clk              "CLK0"|"CLK1"|"CLK2"|"CLK3"        "CLK0"
  pmi_reg_pipeline1_ce               "CE0"|"CE1"|"CE2"|"CE3"            "CE0"
  pmi_reg_pipeline1_rst              "RST0"|"RST1"|"RST2"|"RST3"        "RST0"
  pmi_reg_output_clk                 "CLK0"|"CLK1"|"CLK2"|"CLK3"        "CLK0"
  pmi_reg_output_ce                  "CE0"|"CE1"|"CE2"|"CE3"            "CE0"
  pmi_reg_output_rst                 "RST0"|"RST1"|"RST2"|"RST3"        "RST0"
  pmi_reg_oppre0_clk                 "CLK0"|"CLK1"|"CLK2"|"CLK3"        "CLK0"
  pmi_reg_oppre0_ce                  "CE0"|"CE1"|"CE2"|"CE3"            "CE0"
  pmi_reg_oppre0_rst                 "RST0"|"RST1"|"RST2"|"RST3"        "RST0"
  pmi_reg_oppre1_clk                 "CLK0"|"CLK1"|"CLK2"|"CLK3"        "CLK0"
  pmi_reg_oppre1_ce                  "CE0"|"CE1"|"CE2"|"CE3"            "CE0"
  pmi_reg_oppre1_rst                 "RST0"|"RST1"|"RST2"|"RST3"        "RST0" 
  pmi_reg_opcodein0_clk              "CLK0"|"CLK1"|"CLK2"|"CLK3"        "CLK0"
  pmi_reg_opcodein0_ce               "CE0"|"CE1"|"CE2"|"CE3"            "CE0"
  pmi_reg_opcodein0_rst              "RST0"|"RST1"|"RST2"|"RST3"        "RST0"
  pmi_reg_opcodein1_clk              "CLK0"|"CLK1"|"CLK2"|"CLK3"        "CLK0"
  pmi_reg_opcodein1_ce               "CE0"|"CE1"|"CE2"|"CE3"            "CE0"
  pmi_reg_opcodein1_rst              "RST0"|"RST1"|"RST2"|"RST3"        "RST0"  
  pmi_cascade_match_reg              "on"|"off"                         "off"
  pmi_m0_sourceb_mode                "B"|"C"|"HIGHSPEED"                "B"
  pmi_m1_sourceb_mode                "B"|"C"|"HIGHSPEED"                "B"
  pmi_pre0_sourcea_mode  "A_SHIFT"|"C_SHIFT"|"A_C_DYNAMIC"|"HIGHSPEED"  "A_SHIFT"
  pmi_pre0_sourceb_mode              "SHIFT"|"PARALLEL"|"INTERNAL"      "SHIFT"
  pmi_pre0_symmetry_mode             "DIRECT"|"INTERNAL"                "DIRECT"
  pmi_pre1_sourcea_mode  "A_SHIFT"|"C_SHIFT"|"A_C_DYNAMIC"|"HIGHSPEED"  "A_SHIFT"
  pmi_pre1_sourceb_mode              "SHIFT"|"PARALLEL"|"INTERNAL"      "SHIFT"
  pmi_pre1_fb_mux                    "SHIFT"|"SHIFT_BYPASS"|"DISABLED"  "SHIFT"
  pmi_pre1_symmetry_mode             "DIRECT"|"INTERNAL"                "DIRECT"
  pmi_highspeed_clk                  "CLK0"|"CLK1"|"CLK2"|"CLK3"        "CLK0"
  pmi_clk0_div                       "ENABLED"|"DISABLED"               "ENABLED"
  pmi_clk1_div                       "ENABLED"|"DISABLED"               "ENABLED"
  pmi_clk2_div                       "ENABLED"|"DISABLED"               "ENABLED"
  pmi_clk2_div                       "ENABLED"|"DISABLED"               "ENABLED" 
---------------------------------------------------------------------------------
*/
// fpga\verilog\pkg\versclibs\data\pmi\pmi_dsp_preadd_slice.v 1.0 08-FEB-2011 13:15:58 PPUTREVU
//

`timescale  1 ns / 1 ps

module pmi_dsp_preadd_slice #(
    parameter pmi_data_m0a_width = 18,
    parameter pmi_data_m0b_width = 18,
    parameter pmi_data_m1a_width = 18,
    parameter pmi_data_m1b_width = 18,
    parameter pmi_data_m0c_width = 18,
    parameter pmi_data_m1c_width = 18,			      
    parameter pmi_gsr = "enable",
    parameter pmi_family = "ECP4",
    parameter pmi_reg_input_m0a_pre_clk = "CLK0",
    parameter pmi_reg_input_m0a_pre_ce = "CE0",
    parameter pmi_reg_input_m0a_pre_rst = "RST0",
    parameter pmi_reg_input_m0b_pre_clk = "CLK0",
    parameter pmi_reg_input_m0b_pre_ce = "CE0",
    parameter pmi_reg_input_m0b_pre_rst = "RST0",
    parameter pmi_reg_input_m0a_mult_clk = "CLK0",
    parameter pmi_reg_input_m0a_mult_ce = "CE0",
    parameter pmi_reg_input_m0a_mult_rst = "RST0",
    parameter pmi_reg_input_m0b_mult_clk = "CLK0",
    parameter pmi_reg_input_m0b_mult_ce = "CE0",
    parameter pmi_reg_input_m0b_mult_rst = "RST0",
    parameter pmi_reg_input_m1a_pre_clk = "CLK0",
    parameter pmi_reg_input_m1a_pre_ce = "CE0",
    parameter pmi_reg_input_m1a_pre_rst = "RST0",
    parameter pmi_reg_input_m1b_pre_clk = "CLK0",
    parameter pmi_reg_input_m1b_pre_ce = "CE0",
    parameter pmi_reg_input_m1b_pre_rst = "RST0",
    parameter pmi_reg_input_m1a_mult_clk = "CLK0",
    parameter pmi_reg_input_m1a_mult_ce = "CE0",
    parameter pmi_reg_input_m1a_mult_rst = "RST0",
    parameter pmi_reg_input_m1b_mult_clk = "CLK0",
    parameter pmi_reg_input_m1b_mult_ce = "CE0",
    parameter pmi_reg_input_m1b_mult_rst = "RST0",			      
    parameter pmi_reg_input_m0c_clk = "CLK0",
    parameter pmi_reg_input_m0c_ce = "CE0",
    parameter pmi_reg_input_m0c_rst = "RST0",
    parameter pmi_reg_input_m1c_clk = "CLK0",
    parameter pmi_reg_input_m1c_ce = "CE0",
    parameter pmi_reg_input_m1c_rst = "RST0",
    parameter pmi_reg_input_cfb_clk = "CLK0",
    parameter pmi_reg_input_cfb_ce = "CE0",
    parameter pmi_reg_input_cfb_rst = "RST0",
    parameter pmi_reg_pipeline0_clk = "CLK0",
    parameter pmi_reg_pipeline0_ce = "CE0",
    parameter pmi_reg_pipeline0_rst = "RST0",
    parameter pmi_reg_pipeline1_clk = "CLK0",
    parameter pmi_reg_pipeline1_ce = "CE0",
    parameter pmi_reg_pipeline1_rst = "RST0",
    parameter pmi_reg_output_clk = "CLK0",
    parameter pmi_reg_output_ce = "CE0",
    parameter pmi_reg_output_rst = "RST0",
    parameter pmi_reg_oppre0_clk = "CLK0",
    parameter pmi_reg_oppre0_ce = "CE0",
    parameter pmi_reg_oppre0_rst = "RST0",
    parameter pmi_reg_oppre1_clk = "CLK0",
    parameter pmi_reg_oppre1_ce = "CE0",
    parameter pmi_reg_oppre1_rst = "RST0",
    parameter pmi_reg_opcodein0_clk = "CLK0",
    parameter pmi_reg_opcodein0_ce = "CE0",
    parameter pmi_reg_opcodein0_rst = "RST0",
    parameter pmi_reg_opcodein1_clk = "CLK0",
    parameter pmi_reg_opcodein1_ce = "CE0",
    parameter pmi_reg_opcodein1_rst = "RST0",
    parameter pmi_cas_match_reg = "off",
    parameter pmi_m0_sourceb_mode = "B",
    parameter pmi_m1_sourceb_mode = "B",
    parameter pmi_pre0_sourcea_mode = "A_SHIFT",
    parameter pmi_pre0_sourceb_mode = "SHIFT",
    parameter pmi_pre0_symmetry_mode = "DIRECT",
    parameter pmi_pre1_sourcea_mode = "A_SHIFT",
    parameter pmi_pre1_sourceb_mode = "SHIFT",
    parameter pmi_pre1_fb_mux = "SHIFT",
    parameter pmi_pre1_symmetry_mode = "DIRECT",
    parameter pmi_highspeed_clk = "NONE",
    parameter pmi_clk0_div = "ENABLED",
    parameter pmi_clk1_div = "ENABLED",
    parameter pmi_clk2_div = "ENABLED",
    parameter pmi_clk3_div = "ENABLED",			      
    parameter module_type = "pmi_dsp_preadd_slice")

  (input [pmi_data_m0a_width-1:0] M0A, 
   input [pmi_data_m0b_width-1:0] M0B, 
   input [pmi_data_m1a_width-1:0] M1A, 
   input [pmi_data_m1b_width-1:0] M1B, 
   input [pmi_data_m0c_width-1:0] M0C, 
   input [pmi_data_m1c_width-1:0] M1C, 
   input SIGNM0A, SIGNM0B, SIGNM1A, SIGNM1B,
   input SOURCEM0A, SOURCEM1A,
   input [53:0] CFB, CIN,
   input SIGNCIN,
   input [17:0] SRIA, SRIB,
   input [1:0] AMUXSEL, BMUXSEL,
   input [2:0] CMUXSEL,
   input [1:0] OPPRE,
   input [3:0] CLK, CE, RST,
   output [53:0] R, CO,
   output SIGNR,
   output [17:0] SROA, SROB)/*synthesis syn_black_box*/;

//pragma translate_off

   wire 		      scuba_vhi;
   wire 		      scuba_vlo;
   wire [17:0] tSRIA, tM0A, tSRIB, tM1A;
   wire [53:0] C;

//sign extension fpr M0A, M0B, M1A, M1B
   wire [17:0] sM0A = (pmi_data_m0a_width == 18) ? M0A : 
       {{(18-pmi_data_m0a_width){M0A[pmi_data_m0a_width-1]}}, M0A};
   wire [17:0] sM0B = (pmi_data_m0b_width == 18) ? M0B : 
       {{(18-pmi_data_m0b_width){M0B[pmi_data_m0b_width-1]}}, M0B};
   wire [17:0] sM1A = (pmi_data_m1a_width == 18) ? M1A : 
       {{(18-pmi_data_m1a_width){M1A[pmi_data_m1a_width-1]}}, M1A};
   wire [17:0] sM1B = (pmi_data_m1b_width == 18) ? M1B : 
       {{(18-pmi_data_m1b_width){M1B[pmi_data_m1b_width-1]}}, M1B};
   wire [17:0] sM0C = (pmi_data_m0c_width == 18) ? M0C : 
       {{(18-pmi_data_m0c_width){M0C[pmi_data_m0c_width-1]}}, M0C};
   wire [17:0] sM1C = (pmi_data_m1c_width == 18) ? M1C : 
       {{(18-pmi_data_m1c_width){M1C[pmi_data_m1c_width-1]}}, M1C};

   assign      C = 54'b0;
   assign      scuba_vhi = 1'b1;
   assign      scuba_vlo = 1'b0;

    defparam dsp_preadd_0.SYMMETRY_MODE = pmi_pre0_symmetry_mode ;
    defparam dsp_preadd_0.FB_MUX = "DISABLED" ; // ALWAYS DISABLED
    defparam dsp_preadd_0.SOURCEB_MODE = pmi_pre0_sourceb_mode ;
    defparam dsp_preadd_0.SOURCEA_MODE = pmi_pre0_sourcea_mode ;
    defparam dsp_preadd_0.CAS_MATCH_REG = "FALSE" ; // ALWAYS FALSE
    defparam dsp_preadd_0.RESETMODE = "ASYNC" ; // NO PMI Param
    defparam dsp_preadd_0.GSR = "ENABLED" ;
    defparam dsp_preadd_0.REG_OPPRE_RST = pmi_reg_oppre0_rst; 
    defparam dsp_preadd_0.REG_OPPRE_CE = pmi_reg_oppre0_ce; 
    defparam dsp_preadd_0.REG_OPPRE_CLK = pmi_reg_oppre0_clk ; 
    defparam dsp_preadd_0.REG_INPUTC_RST = pmi_reg_input_m0c_rst ;
    defparam dsp_preadd_0.REG_INPUTC_CE = pmi_reg_input_m0c_ce;
    defparam dsp_preadd_0.REG_INPUTC_CLK = pmi_reg_input_m0c_clk;
    defparam dsp_preadd_0.REG_INPUTB_RST = pmi_reg_input_m0b_pre_rst;
    defparam dsp_preadd_0.REG_INPUTB_CE = pmi_reg_input_m0b_pre_ce;
    defparam dsp_preadd_0.REG_INPUTB_CLK = pmi_reg_input_m0b_pre_clk ;
    defparam dsp_preadd_0.REG_INPUTA_RST = pmi_reg_input_m0a_pre_rst;
    defparam dsp_preadd_0.REG_INPUTA_CE = pmi_reg_input_m0a_pre_ce ;
    defparam dsp_preadd_0.REG_INPUTA_CLK = pmi_reg_input_m0a_pre_clk ;
    defparam dsp_preadd_0.HIGHSPEED_CLK = pmi_highspeed_clk;
    defparam dsp_preadd_0.CLK0_DIV = pmi_clk0_div;
    defparam dsp_preadd_0.CLK1_DIV = pmi_clk1_div;
    defparam dsp_preadd_0.CLK2_DIV = pmi_clk2_div;
    defparam dsp_preadd_0.CLK3_DIV = pmi_clk3_div;
    PRADD18A dsp_preadd_0 (.PA17(sM0A[17]), .PA16(sM0A[16]), .PA15(sM0A[15]), .PA14(sM0A[14]),
        .PA13(sM0A[13]), .PA12(sM0A[12]), .PA11(sM0A[11]), .PA10(sM0A[10]), .PA9(sM0A[9]), 
        .PA8(sM0A[8]), .PA7(sM0A[7]), .PA6(sM0A[6]), .PA5(sM0A[5]), .PA4(sM0A[4]), .PA3(sM0A[3]), 
        .PA2(sM0A[2]), .PA1(sM0A[1]), .PA0(sM0A[0]), .PB17(sM0B[17]), .PB16(sM0B[16]), 
        .PB15(sM0B[15]), .PB14(sM0B[14]), .PB13(sM0B[13]), .PB12(sM0B[12]), .PB11(sM0B[11]), 
        .PB10(sM0B[10]), .PB9(sM0B[9]), .PB8(sM0B[8]), .PB7(sM0B[7]), .PB6(sM0B[6]), .PB5(sM0B[5]), 
        .PB4(sM0B[4]), .PB3(sM0B[3]), .PB2(sM0B[2]), .PB1(sM0B[1]), .PB0(sM0B[0]), 
        .C17(sM0C[17]), .C16(sM0C[16]), .C15(sM0C[15]), .C14(sM0C[14]), 
        .C13(sM0C[13]), .C12(sM0C[12]), .C11(sM0C[11]), .C10(sM0C[10]), .C9(sM0C[9]), 
        .C8(sM0C[8]), .C7(sM0C[7]), .C6(sM0C[6]), .C5(sM0C[5]), .C4(sM0C[4]), .C3(sM0C[3]), 
        .C2(sM0C[2]), .C1(sM0C[1]), .C0(sM0C[0]), 
        .SOURCEA(SOURCEM0A),
        .OPPRE(OPPRE[0]), 
        .CE0(CE[0]), .CE1(CE[1]), .CE2(CE[2]), .CE3(CE[3]),
        .CLK0(CLK[0]), .CLK1(CLK[1]), .CLK2(CLK[2]), .CLK3(CLK[3]),
        .RST0(RST[0]), .RST1(RST[1]), .RST2(RST[2]), .RST3(RST[3]),
        .SRIA17(SRIA[17]), .SRIA16(SRIA[16]), .SRIA15(SRIA[15]), .SRIA14(SRIA[14]), 
        .SRIA13(SRIA[13]), .SRIA12(SRIA[12]), .SRIA11(SRIA[11]), .SRIA10(SRIA[10]), .SRIA9(SRIA[9]), 
        .SRIA8(SRIA[8]), .SRIA7(SRIA[7]), .SRIA6(SRIA[6]), .SRIA5(SRIA[5]), .SRIA4(SRIA[4]), 
        .SRIA3(SRIA[3]), .SRIA2(SRIA[2]), .SRIA1(SRIA[1]), .SRIA0(SRIA[0]),
        .SRIB17(tSRIB[17]), .SRIB16(tSRIB[16]), .SRIB15(tSRIB[15]), .SRIB14(tSRIB[14]), 
        .SRIB13(tSRIB[13]), .SRIB12(tSRIB[12]), .SRIB11(tSRIB[11]), .SRIB10(tSRIB[10]), .SRIB9(tSRIB[9]), 
        .SRIB8(tSRIB[8]), .SRIB7(tSRIB[7]), .SRIB6(tSRIB[6]), .SRIB5(tSRIB[5]), .SRIB4(tSRIB[4]), 
        .SRIB3(tSRIB[3]), .SRIB2(tSRIB[2]), .SRIB1(tSRIB[1]), .SRIB0(tSRIB[0]),
        .SROA17(tSRIA[17]), .SROA16(tSRIA[16]), .SROA15(tSRIA[15]), .SROA14(tSRIA[14]), 
        .SROA13(tSRIA[13]), .SROA12(tSRIA[12]), .SROA11(tSRIA[11]), .SROA10(tSRIA[10]), .SROA9(tSRIA[9]), 
        .SROA8(tSRIA[8]), .SROA7(tSRIA[7]), .SROA6(tSRIA[6]), .SROA5(tSRIA[5]), .SROA4(tSRIA[4]), 
        .SROA3(tSRIA[3]), .SROA2(tSRIA[2]), .SROA1(tSRIA[1]), .SROA0(tSRIA[0]),
        .SROB17(SROB[17]), .SROB16(SROB[16]), .SROB15(SROB[15]), .SROB14(SROB[14]), 
        .SROB13(SROB[13]), .SROB12(SROB[12]), .SROB11(SROB[11]), .SROB10(SROB[10]), .SROB9(SROB[9]), 
        .SROB8(SROB[8]), .SROB7(SROB[7]), .SROB6(SROB[6]), .SROB5(SROB[5]), .SROB4(SROB[4]), 
        .SROB3(SROB[3]), .SROB2(SROB[2]), .SROB1(SROB[1]), .SROB0(SROB[0]),
        .PO17(tM0A[17]), .PO16(tM0A[16]), .PO15(tM0A[15]), .PO14(tM0A[14]), 
        .PO13(tM0A[13]), .PO12(tM0A[12]), .PO11(tM0A[11]), .PO10(tM0A[10]), .PO9(tM0A[9]), 
        .PO8(tM0A[8]), .PO7(tM0A[7]), .PO6(tM0A[6]), .PO5(tM0A[5]), .PO4(tM0A[4]), 
        .PO3(tM0A[3]), .PO2(tM0A[2]), .PO1(tM0A[1]), .PO0(tM0A[0])
    );


    defparam dsp_preadd_1.SYMMETRY_MODE = pmi_pre1_symmetry_mode;
    defparam dsp_preadd_1.FB_MUX = pmi_pre1_fb_mux ;
    defparam dsp_preadd_1.SOURCEB_MODE = pmi_pre1_sourceb_mode ; 
    defparam dsp_preadd_1.SOURCEA_MODE =  pmi_pre1_sourcea_mode;
    defparam dsp_preadd_1.CAS_MATCH_REG = pmi_cas_match_reg ;
    defparam dsp_preadd_1.RESETMODE = "ASYNC" ;
    defparam dsp_preadd_1.GSR = "ENABLED" ;
    defparam dsp_preadd_0.REG_OPPRE_RST = pmi_reg_oppre1_rst; 
    defparam dsp_preadd_0.REG_OPPRE_CE = pmi_reg_oppre1_ce; 
    defparam dsp_preadd_0.REG_OPPRE_CLK = pmi_reg_oppre1_clk ; 
    defparam dsp_preadd_1.REG_INPUTC_RST = pmi_reg_input_m1c_rst ;
    defparam dsp_preadd_1.REG_INPUTC_CE = pmi_reg_input_m1c_ce;
    defparam dsp_preadd_1.REG_INPUTC_CLK = pmi_reg_input_m1c_clk;
    defparam dsp_preadd_1.REG_INPUTB_RST = pmi_reg_input_m1b_pre_rst;
    defparam dsp_preadd_1.REG_INPUTB_CE = pmi_reg_input_m1b_pre_ce;
    defparam dsp_preadd_1.REG_INPUTB_CLK = pmi_reg_input_m1b_pre_clk ;
    defparam dsp_preadd_1.REG_INPUTA_RST = pmi_reg_input_m1a_pre_rst;
    defparam dsp_preadd_1.REG_INPUTA_CE = pmi_reg_input_m1a_pre_ce ;
    defparam dsp_preadd_1.REG_INPUTA_CLK = pmi_reg_input_m1a_pre_clk ;
    defparam dsp_preadd_1.HIGHSPEED_CLK = pmi_highspeed_clk;
    defparam dsp_preadd_1.CLK0_DIV = pmi_clk0_div;
    defparam dsp_preadd_1.CLK1_DIV = pmi_clk1_div;
    defparam dsp_preadd_1.CLK2_DIV = pmi_clk2_div;
    defparam dsp_preadd_1.CLK3_DIV = pmi_clk3_div;
    PRADD18A dsp_preadd_1 (.PA17(sM1A[17]), .PA16(sM1A[16]), .PA15(sM1A[15]), .PA14(sM1A[14]), 
        .PA13(sM1A[13]), .PA12(sM1A[12]), .PA11(sM1A[11]), .PA10(sM1A[10]), .PA9(sM1A[9]), 
        .PA8(sM1A[8]), .PA7(sM1A[7]), .PA6(sM1A[6]), .PA5(sM1A[5]), .PA4(sM1A[4]), .PA3(sM1A[3]), 
        .PA2(sM1A[2]), .PA1(sM1A[1]), .PA0(sM1A[0]), .PB17(sM1B[17]), .PB16(sM1B[16]), 
        .PB15(sM1B[15]), .PB14(sM1B[14]), .PB13(sM1B[13]), .PB12(sM1B[12]), .PB11(sM1B[11]), 
        .PB10(sM1B[10]), .PB9(sM1B[9]), .PB8(sM1B[8]), .PB7(sM1B[7]), .PB6(sM1B[6]), .PB5(sM1B[5]), 
        .PB4(sM1B[4]), .PB3(sM1B[3]), .PB2(sM1B[2]), .PB1(sM1B[1]), .PB0(sM1B[0]), 
        .C17(sM1C[17]), .C16(sM1C[16]), .C15(sM1C[15]), .C14(sM1C[14]), 
        .C13(sM1C[13]), .C12(sM1C[12]), .C11(sM1C[11]), .C10(sM1C[10]), .C9(sM1C[9]), 
        .C8(sM1C[8]), .C7(sM1C[7]), .C6(sM1C[6]), .C5(sM1C[5]), .C4(sM1C[4]), .C3(sM1C[3]), 
        .C2(sM1C[2]), .C1(sM1C[1]), .C0(sM1C[0]), 		   
        .SOURCEA(SOURCEM1A), 
        .OPPRE(OPPRE[1]), 
        .CE0(CE[0]), .CE1(CE[1]), .CE2(CE[2]), .CE3(CE[3]),
        .CLK0(CLK[0]), .CLK1(CLK[1]), .CLK2(CLK[2]), .CLK3(CLK[3]),
        .RST0(RST[0]), .RST1(RST[1]), .RST2(RST[2]), .RST3(RST[3]),
        .SRIA17(tSRIA[17]), .SRIA16(tSRIA[16]), .SRIA15(tSRIA[15]), .SRIA14(tSRIA[14]), 
        .SRIA13(tSRIA[13]), .SRIA12(tSRIA[12]), .SRIA11(tSRIA[11]), .SRIA10(tSRIA[10]), .SRIA9(tSRIA[9]), 
        .SRIA8(tSRIA[8]), .SRIA7(tSRIA[7]), .SRIA6(tSRIA[6]), .SRIA5(tSRIA[5]), .SRIA4(tSRIA[4]), 
        .SRIA3(tSRIA[3]), .SRIA2(tSRIA[2]), .SRIA1(tSRIA[1]), .SRIA0(tSRIA[0]),
        .SRIB17(SRIB[17]), .SRIB16(SRIB[16]), .SRIB15(SRIB[15]), .SRIB14(SRIB[14]), 
        .SRIB13(SRIB[13]), .SRIB12(SRIB[12]), .SRIB11(SRIB[11]), .SRIB10(SRIB[10]), .SRIB9(SRIB[9]), 
        .SRIB8(SRIB[8]), .SRIB7(SRIB[7]), .SRIB6(SRIB[6]), .SRIB5(SRIB[5]), .SRIB4(SRIB[4]), 
        .SRIB3(SRIB[3]), .SRIB2(SRIB[2]), .SRIB1(SRIB[1]), .SRIB0(SRIB[0]),
        .SROA17(SROA[17]), .SROA16(SROA[16]), .SROA15(SROA[15]), .SROA14(SROA[14]), 
        .SROA13(SROA[13]), .SROA12(SROA[12]), .SROA11(SROA[11]), .SROA10(SROA[10]), .SROA9(SROA[9]), 
        .SROA8(SROA[8]), .SROA7(SROA[7]), .SROA6(SROA[6]), .SROA5(SROA[5]), .SROA4(SROA[4]), 
        .SROA3(SROA[3]), .SROA2(SROA[2]), .SROA1(SROA[1]), .SROA0(SROA[0]),
        .SROB17(tSRIB[17]), .SROB16(tSRIB[16]), .SROB15(tSRIB[15]), .SROB14(tSRIB[14]), 
        .SROB13(tSRIB[13]), .SROB12(tSRIB[12]), .SROB11(tSRIB[11]), .SROB10(tSRIB[10]), .SROB9(tSRIB[9]), 
        .SROB8(tSRIB[8]), .SROB7(tSRIB[7]), .SROB6(tSRIB[6]), .SROB5(tSRIB[5]), .SROB4(tSRIB[4]), 
        .SROB3(tSRIB[3]), .SROB2(tSRIB[2]), .SROB1(tSRIB[1]), .SROB0(tSRIB[0]),
        .PO17(tM1A[17]), .PO16(tM1A[16]), .PO15(tM1A[15]), .PO14(tM1A[14]), 
        .PO13(tM1A[13]), .PO12(tM1A[12]), .PO11(tM1A[11]), .PO10(tM1A[10]), .PO9(tM1A[9]), 
        .PO8(tM1A[8]), .PO7(tM1A[7]), .PO6(tM1A[6]), .PO5(tM1A[5]), .PO4(tM1A[4]), 
        .PO3(tM1A[3]), .PO2(tM1A[2]), .PO1(tM1A[1]), .PO0(tM1A[0])
    );


    defparam dsp_mult_0.SOURCEB_MODE = (pmi_m0_sourceb_mode == "B") ? "B_SHIFT" : (pmi_m0_sourceb_mode == "C") ? "C_SHIFT" : "HIGHSPEED" ;
    defparam dsp_mult_0.MULT_BYPASS = "DISABLED" ;
    defparam dsp_mult_0.CAS_MATCH_REG = "FALSE" ; // ALWAYS FALSE
    defparam dsp_mult_0.RESETMODE = "ASYNC" ;
    defparam dsp_mult_0.GSR = "ENABLED" ;
    defparam dsp_mult_0.REG_OUTPUT_RST = "RST0" ;
    defparam dsp_mult_0.REG_OUTPUT_CE = "CE0" ;
    defparam dsp_mult_0.REG_OUTPUT_CLK = "NONE" ; // ALWAYS NONE
    defparam dsp_mult_0.REG_PIPELINE_RST = pmi_reg_pipeline0_rst ;
    defparam dsp_mult_0.REG_PIPELINE_CE = pmi_reg_pipeline0_ce ;
    defparam dsp_mult_0.REG_PIPELINE_CLK = pmi_reg_pipeline0_clk ;
    defparam dsp_mult_0.REG_INPUTC_RST = pmi_reg_input_m0c_rst ;
    defparam dsp_mult_0.REG_INPUTC_CE = pmi_reg_input_m0c_ce ;
    defparam dsp_mult_0.REG_INPUTC_CLK = pmi_reg_input_m0c_clk ;
    defparam dsp_mult_0.REG_INPUTB_RST = pmi_reg_input_m0b_mult_rst;
    defparam dsp_mult_0.REG_INPUTB_CE = pmi_reg_input_m0b_mult_ce ;
    defparam dsp_mult_0.REG_INPUTB_CLK = pmi_reg_input_m0b_mult_clk ;
    defparam dsp_mult_0.REG_INPUTA_RST = pmi_reg_input_m0a_mult_rst;
    defparam dsp_mult_0.REG_INPUTA_CE =  pmi_reg_input_m0a_mult_ce;
    defparam dsp_mult_0.REG_INPUTA_CLK = pmi_reg_input_m0a_mult_clk ;
    defparam dsp_mult_0.HIGHSPEED_CLK = pmi_highspeed_clk;
    defparam dsp_mult_0.CLK0_DIV = pmi_clk0_div;
    defparam dsp_mult_0.CLK1_DIV = pmi_clk1_div;
    defparam dsp_mult_0.CLK2_DIV = pmi_clk2_div;
    defparam dsp_mult_0.CLK3_DIV = pmi_clk3_div;
    MULT18X18D dsp_mult_0 (.A17(tM0A[17]), .A16(tM0A [16]), .A15(tM0A[15]), .A14(tM0A[14]), 
        .A13(tM0A[13]), .A12(tM0A[12]), .A11(tM0A[11]), .A10(tM0A[10]), .A9(tM0A[9]), 
        .A8(tM0A[8]), .A7(tM0A[7]), .A6(tM0A[6]), .A5(tM0A[5]), .A4(tM0A[4]), .A3(tM0A[3]), 
        .A2(tM0A[2]), .A1(tM0A[1]), .A0(tM0A[0]), .B17(sM0B[17]), .B16(sM0B[16]), 
        .B15(sM0B[15]), .B14(sM0B[14]), .B13(sM0B[13]), .B12(sM0B[12]), .B11(sM0B[11]), 
        .B10(sM0B[10]), .B9(sM0B[9]), .B8(sM0B[8]), .B7(sM0B[7]), .B6(sM0B[6]), .B5(sM0B[5]), 
        .B4(sM0B[4]), .B3(sM0B[3]), .B2(sM0B[2]), .B1(sM0B[1]), .B0(sM0B[0]), 
        .C17(M0C[17]), .C16(M0C[16]), .C15(M0C[15]), .C14(M0C[14]), .C13(M0C[13]), 
        .C12(M0C[12]), .C11(M0C[11]), .C10(M0C[10]), .C9(M0C[9]), .C8(M0C[8]), .C7(M0C[7]), 
        .C6(M0C[6]), .C5(M0C[5]), .C4(M0C[4]), .C3(M0C[3]), .C2(M0C[2]), 
        .C1(M0C[1]), .C0(M0C[0]),
        .SIGNEDA(SIGNM0A), .SIGNEDB(SIGNM0B), .SOURCEA(1'b0), .SOURCEB(1'b0), 
        .CE0(CE[0]), .CE1(CE[1]), .CE2(CE[2]), .CE3(CE[3]),
        .CLK0(CLK[0]), .CLK1(CLK[1]), .CLK2(CLK[2]), .CLK3(CLK[3]),
        .RST0(RST[0]), .RST1(RST[1]), .RST2(RST[2]), .RST3(RST[3]),
        .SRIA17(1'b0), 
        .SRIA16(1'b0), .SRIA15(1'b0), .SRIA14(1'b0), .SRIA13(1'b0), 
        .SRIA12(1'b0), .SRIA11(1'b0), .SRIA10(1'b0), .SRIA9(1'b0), 
        .SRIA8(1'b0), .SRIA7(1'b0), .SRIA6(1'b0), .SRIA5(1'b0), 
        .SRIA4(1'b0), .SRIA3(1'b0), .SRIA2(1'b0), .SRIA1(1'b0), 
        .SRIA0(1'b0), .SRIB17(1'b0), .SRIB16(1'b0), .SRIB15(1'b0), 
        .SRIB14(1'b0), .SRIB13(1'b0), .SRIB12(1'b0), .SRIB11(1'b0), 
        .SRIB10(1'b0), .SRIB9(1'b0), .SRIB8(1'b0), .SRIB7(1'b0), 
        .SRIB6(1'b0), .SRIB5(1'b0), .SRIB4(1'b0), .SRIB3(1'b0), 
        .SRIB2(1'b0), .SRIB1(1'b0), .SRIB0(1'b0), .SROA17(), 
        .SROA16(), .SROA15(), .SROA14(), .SROA13(), .SROA12(), .SROA11(), 
        .SROA10(), .SROA9(), .SROA8(), .SROA7(), .SROA6(), .SROA5(), .SROA4(), 
        .SROA3(), .SROA2(), .SROA1(), .SROA0(), .SROB17(), .SROB16(), .SROB15(), 
        .SROB14(), .SROB13(), .SROB12(), .SROB11(), .SROB10(), .SROB9(), 
        .SROB8(), .SROB7(), .SROB6(), .SROB5(), .SROB4(), .SROB3(), .SROB2(), 
        .SROB1(), .SROB0(), .ROA17(mult_out_roa_0_17), .ROA16(mult_out_roa_0_16), 
        .ROA15(mult_out_roa_0_15), .ROA14(mult_out_roa_0_14), 
        .ROA13(mult_out_roa_0_13), .ROA12(mult_out_roa_0_12), 
        .ROA11(mult_out_roa_0_11), .ROA10(mult_out_roa_0_10), 
        .ROA9(mult_out_roa_0_9), .ROA8(mult_out_roa_0_8), 
        .ROA7(mult_out_roa_0_7), .ROA6(mult_out_roa_0_6), 
        .ROA5(mult_out_roa_0_5), .ROA4(mult_out_roa_0_4), 
        .ROA3(mult_out_roa_0_3), .ROA2(mult_out_roa_0_2), 
        .ROA1(mult_out_roa_0_1), .ROA0(mult_out_roa_0_0), 
        .ROB17(mult_out_rob_0_17), .ROB16(mult_out_rob_0_16), 
        .ROB15(mult_out_rob_0_15), .ROB14(mult_out_rob_0_14), 
        .ROB13(mult_out_rob_0_13), .ROB12(mult_out_rob_0_12), 
        .ROB11(mult_out_rob_0_11), .ROB10(mult_out_rob_0_10), 
        .ROB9(mult_out_rob_0_9), .ROB8(mult_out_rob_0_8), 
        .ROB7(mult_out_rob_0_7), .ROB6(mult_out_rob_0_6), 
        .ROB5(mult_out_rob_0_5), .ROB4(mult_out_rob_0_4), 
        .ROB3(mult_out_rob_0_3), .ROB2(mult_out_rob_0_2), 
        .ROB1(mult_out_rob_0_1), .ROB0(mult_out_rob_0_0),
        .ROC17(), .ROC16(), .ROC15(), 
        .ROC14(), .ROC13(), .ROC12(), .ROC11(), .ROC10(), .ROC9(), 
        .ROC8(), .ROC7(), .ROC6(), .ROC5(), .ROC4(), .ROC3(), .ROC2(), 
        .ROC1(), .ROC0(),
        .P35(mult_out_p_0_35), .P34(mult_out_p_0_34), .P33(mult_out_p_0_33), 
        .P32(mult_out_p_0_32), .P31(mult_out_p_0_31), .P30(mult_out_p_0_30), 
        .P29(mult_out_p_0_29), .P28(mult_out_p_0_28), .P27(mult_out_p_0_27), 
        .P26(mult_out_p_0_26), .P25(mult_out_p_0_25), .P24(mult_out_p_0_24), 
        .P23(mult_out_p_0_23), .P22(mult_out_p_0_22), .P21(mult_out_p_0_21), 
        .P20(mult_out_p_0_20), .P19(mult_out_p_0_19), .P18(mult_out_p_0_18), 
        .P17(mult_out_p_0_17), .P16(mult_out_p_0_16), .P15(mult_out_p_0_15), 
        .P14(mult_out_p_0_14), .P13(mult_out_p_0_13), .P12(mult_out_p_0_12), 
        .P11(mult_out_p_0_11), .P10(mult_out_p_0_10), .P9(mult_out_p_0_9), 
        .P8(mult_out_p_0_8), .P7(mult_out_p_0_7), .P6(mult_out_p_0_6), 
        .P5(mult_out_p_0_5), .P4(mult_out_p_0_4), .P3(mult_out_p_0_3), 
        .P2(mult_out_p_0_2), .P1(mult_out_p_0_1), .P0(mult_out_p_0_0), 
        .SIGNEDP(mult_out_signedp_0));

    defparam dsp_mult_1.SOURCEB_MODE = (pmi_m1_sourceb_mode == "B") ? "B_SHIFT" : (pmi_m1_sourceb_mode == "C") ? "C_SHIFT" : "HIGHSPEED" ;
    defparam dsp_mult_1.MULT_BYPASS = "DISABLED" ;
    defparam dsp_mult_1.CAS_MATCH_REG = "FALSE" ; // ALWAYS FALSE
    defparam dsp_mult_1.RESETMODE = "ASYNC" ;
    defparam dsp_mult_1.GSR = "ENABLED" ;
    defparam dsp_mult_1.REG_OUTPUT_RST = "RST0" ;
    defparam dsp_mult_1.REG_OUTPUT_CE = "CE0" ;
    defparam dsp_mult_1.REG_OUTPUT_CLK = "NONE" ; // ALWAYS NONE
    defparam dsp_mult_1.REG_PIPELINE_RST = pmi_reg_pipeline1_rst ;
    defparam dsp_mult_1.REG_PIPELINE_CE = pmi_reg_pipeline1_ce ;
    defparam dsp_mult_1.REG_PIPELINE_CLK = pmi_reg_pipeline1_clk ;
    defparam dsp_mult_1.REG_INPUTC_RST = pmi_reg_input_m1c_rst ;
    defparam dsp_mult_1.REG_INPUTC_CE = pmi_reg_input_m1c_ce ;
    defparam dsp_mult_1.REG_INPUTC_CLK = pmi_reg_input_m1c_clk ;
    defparam dsp_mult_1.REG_INPUTB_RST = pmi_reg_input_m1b_mult_rst;
    defparam dsp_mult_1.REG_INPUTB_CE = pmi_reg_input_m1b_mult_ce ;
    defparam dsp_mult_1.REG_INPUTB_CLK = pmi_reg_input_m1b_mult_clk ;
    defparam dsp_mult_1.REG_INPUTA_RST = pmi_reg_input_m1a_mult_rst;
    defparam dsp_mult_1.REG_INPUTA_CE =  pmi_reg_input_m1a_mult_ce;
    defparam dsp_mult_1.REG_INPUTA_CLK = pmi_reg_input_m1a_mult_clk ;
    defparam dsp_mult_1.HIGHSPEED_CLK = pmi_highspeed_clk;
    defparam dsp_mult_1.CLK0_DIV = pmi_clk0_div;
    defparam dsp_mult_1.CLK1_DIV = pmi_clk1_div;
    defparam dsp_mult_1.CLK2_DIV = pmi_clk2_div;
    defparam dsp_mult_1.CLK3_DIV = pmi_clk3_div;
    MULT18X18D dsp_mult_1 (.A17(tM1A[17]), .A16(tM1A [16]), .A15(tM1A[15]), .A14(tM1A[14]), 
        .A13(tM1A[13]), .A12(tM1A[12]), .A11(tM1A[11]), .A10(tM1A[10]), .A9(tM1A[9]), 
        .A8(tM1A[8]), .A7(tM1A[7]), .A6(tM1A[6]), .A5(tM1A[5]), .A4(tM1A[4]), .A3(tM1A[3]), 
        .A2(tM1A[2]), .A1(tM1A[1]), .A0(tM1A[0]), .B17(sM1B[17]), .B16(sM1B[16]), 
        .B15(sM1B[15]), .B14(sM1B[14]), .B13(sM1B[13]), .B12(sM1B[12]), .B11(sM1B[11]), 
        .B10(sM1B[10]), .B9(sM1B[9]), .B8(sM1B[8]), .B7(sM1B[7]), .B6(sM1B[6]), .B5(sM1B[5]), 
        .B4(sM1B[4]), .B3(sM1B[3]), .B2(sM1B[2]), .B1(sM1B[1]), .B0(sM1B[0]), 
        .C17(M0C[17]), .C16(M0C[16]), .C15(M0C[15]), .C14(M0C[14]), .C13(M0C[13]), 
        .C12(M0C[12]), .C11(M0C[11]), .C10(M0C[10]), .C9(M0C[9]), .C8(M0C[8]), .C7(M0C[7]), 
        .C6(M0C[6]), .C5(M0C[5]), .C4(M0C[4]), .C3(M0C[3]), .C2(M0C[2]), 
        .C1(M0C[1]), .C0(M0C[0]),
        .SIGNEDA(SIGNM1A), .SIGNEDB(SIGNM1B), .SOURCEA(1'b0), .SOURCEB(1'b0), 
        .CE0(CE[0]), .CE1(CE[1]), .CE2(CE[2]), .CE3(CE[3]),
        .CLK0(CLK[0]), .CLK1(CLK[1]), .CLK2(CLK[2]), .CLK3(CLK[3]),
        .RST0(RST[0]), .RST1(RST[1]), .RST2(RST[2]), .RST3(RST[3]),
        .SRIA17(1'b0), 
        .SRIA16(1'b0), .SRIA15(1'b0), .SRIA14(1'b0), .SRIA13(1'b0), 
        .SRIA12(1'b0), .SRIA11(1'b0), .SRIA10(1'b0), .SRIA9(1'b0), 
        .SRIA8(1'b0), .SRIA7(1'b0), .SRIA6(1'b0), .SRIA5(1'b0), 
        .SRIA4(1'b0), .SRIA3(1'b0), .SRIA2(1'b0), .SRIA1(1'b0), 
        .SRIA0(1'b0), .SRIB17(1'b0), .SRIB16(1'b0), .SRIB15(1'b0), 
        .SRIB14(1'b0), .SRIB13(1'b0), .SRIB12(1'b0), .SRIB11(1'b0), 
        .SRIB10(1'b0), .SRIB9(1'b0), .SRIB8(1'b0), .SRIB7(1'b0), 
        .SRIB6(1'b0), .SRIB5(1'b0), .SRIB4(1'b0), .SRIB3(1'b0), 
        .SRIB2(1'b0), .SRIB1(1'b0), .SRIB0(1'b0), .SROA17(), 
        .SROA16(), .SROA15(), .SROA14(), .SROA13(), .SROA12(), .SROA11(), 
        .SROA10(), .SROA9(), .SROA8(), .SROA7(), .SROA6(), .SROA5(), .SROA4(), 
        .SROA3(), .SROA2(), .SROA1(), .SROA0(), .SROB17(), .SROB16(), .SROB15(), 
        .SROB14(), .SROB13(), .SROB12(), .SROB11(), .SROB10(), .SROB9(), 
        .SROB8(), .SROB7(), .SROB6(), .SROB5(), .SROB4(), .SROB3(), .SROB2(), 
        .SROB1(), .SROB0(), .ROA17(mult_out_roa_1_17), .ROA16(mult_out_roa_1_16), 
        .ROA15(mult_out_roa_1_15), .ROA14(mult_out_roa_1_14), 
        .ROA13(mult_out_roa_1_13), .ROA12(mult_out_roa_1_12), 
        .ROA11(mult_out_roa_1_11), .ROA10(mult_out_roa_1_10), 
        .ROA9(mult_out_roa_1_9), .ROA8(mult_out_roa_1_8), 
        .ROA7(mult_out_roa_1_7), .ROA6(mult_out_roa_1_6), 
        .ROA5(mult_out_roa_1_5), .ROA4(mult_out_roa_1_4), 
        .ROA3(mult_out_roa_1_3), .ROA2(mult_out_roa_1_2), 
        .ROA1(mult_out_roa_1_1), .ROA0(mult_out_roa_1_0), 
        .ROB17(mult_out_rob_1_17), .ROB16(mult_out_rob_1_16), 
        .ROB15(mult_out_rob_1_15), .ROB14(mult_out_rob_1_14), 
        .ROB13(mult_out_rob_1_13), .ROB12(mult_out_rob_1_12), 
        .ROB11(mult_out_rob_1_11), .ROB10(mult_out_rob_1_10), 
        .ROB9(mult_out_rob_1_9), .ROB8(mult_out_rob_1_8), 
        .ROB7(mult_out_rob_1_7), .ROB6(mult_out_rob_1_6), 
        .ROB5(mult_out_rob_1_5), .ROB4(mult_out_rob_1_4), 
        .ROB3(mult_out_rob_1_3), .ROB2(mult_out_rob_1_2), 
        .ROB1(mult_out_rob_1_1), .ROB0(mult_out_rob_1_0),
        .ROC17(), .ROC16(), .ROC15(), 
        .ROC14(), .ROC13(), .ROC12(), .ROC11(), .ROC10(), .ROC9(), 
        .ROC8(), .ROC7(), .ROC6(), .ROC5(), .ROC4(), .ROC3(), .ROC2(), 
        .ROC1(), .ROC0(),
        .P35(mult_out_p_1_35), .P34(mult_out_p_1_34), .P33(mult_out_p_1_33), 
        .P32(mult_out_p_1_32), .P31(mult_out_p_1_31), .P30(mult_out_p_1_30), 
        .P29(mult_out_p_1_29), .P28(mult_out_p_1_28), .P27(mult_out_p_1_27), 
        .P26(mult_out_p_1_26), .P25(mult_out_p_1_25), .P24(mult_out_p_1_24), 
        .P23(mult_out_p_1_23), .P22(mult_out_p_1_22), .P21(mult_out_p_1_21), 
        .P20(mult_out_p_1_20), .P19(mult_out_p_1_19), .P18(mult_out_p_1_18), 
        .P17(mult_out_p_1_17), .P16(mult_out_p_1_16), .P15(mult_out_p_1_15), 
        .P14(mult_out_p_1_14), .P13(mult_out_p_1_13), .P12(mult_out_p_1_12), 
        .P11(mult_out_p_1_11), .P10(mult_out_p_1_10), .P9(mult_out_p_1_9), 
        .P8(mult_out_p_1_8), .P7(mult_out_p_1_7), .P6(mult_out_p_1_6), 
        .P5(mult_out_p_1_5), .P4(mult_out_p_1_4), .P3(mult_out_p_1_3), 
        .P2(mult_out_p_1_2), .P1(mult_out_p_1_1), .P0(mult_out_p_1_0), 
        .SIGNEDP(mult_out_signedp_1));


    defparam dsp_alu_0.REG_OPCODEIN_1_RST = pmi_reg_opcodein1_rst ;
    defparam dsp_alu_0.REG_OPCODEIN_1_CE = pmi_reg_opcodein1_ce;
    defparam dsp_alu_0.REG_OPCODEIN_1_CLK = pmi_reg_opcodein1_clk;
    defparam dsp_alu_0.REG_OPCODEIN_0_RST = pmi_reg_opcodein0_rst;
    defparam dsp_alu_0.REG_OPCODEIN_0_CE = pmi_reg_opcodein0_ce;
    defparam dsp_alu_0.REG_OPCODEIN_0_CLK = pmi_reg_opcodein0_clk;
    defparam dsp_alu_0.REG_OPCODEOP1_1_CLK = "NONE" ;
    defparam dsp_alu_0.REG_OPCODEOP1_0_CLK = "NONE" ;
    defparam dsp_alu_0.REG_OPCODEOP0_1_RST = "RST0" ;
    defparam dsp_alu_0.REG_OPCODEOP0_1_CE = "CE0" ;
    defparam dsp_alu_0.REG_OPCODEOP0_1_CLK = "NONE" ;
    defparam dsp_alu_0.REG_OPCODEOP0_0_RST = "RST0" ;
    defparam dsp_alu_0.REG_OPCODEOP0_0_CE = "CE0" ;
    defparam dsp_alu_0.REG_OPCODEOP0_0_CLK = "NONE" ;
    defparam dsp_alu_0.REG_INPUTC1_RST = "RST0" ;
    defparam dsp_alu_0.REG_INPUTC1_CE = "CE0" ;
    defparam dsp_alu_0.REG_INPUTC1_CLK = "NONE" ; // C inputs are not used
    defparam dsp_alu_0.REG_INPUTC0_RST = "RST0" ;
    defparam dsp_alu_0.REG_INPUTC0_CE = "CE0" ;
    defparam dsp_alu_0.REG_INPUTC0_CLK = "NONE" ; // C inputs are not used
    defparam dsp_alu_0.REG_INPUTCFB_RST = pmi_reg_input_cfb_rst ;
    defparam dsp_alu_0.REG_INPUTCFB_CE = pmi_reg_input_cfb_ce ;
    defparam dsp_alu_0.REG_INPUTCFB_CLK = pmi_reg_input_cfb_clk ;
    defparam dsp_alu_0.LEGACY = "DISABLED";
    defparam dsp_alu_0.REG_FLAG_RST = "RST0" ;
    defparam dsp_alu_0.REG_FLAG_CE = "CE0" ;
    defparam dsp_alu_0.REG_FLAG_CLK = "NONE" ;
    defparam dsp_alu_0.REG_OUTPUT1_RST = pmi_reg_output_rst ;
    defparam dsp_alu_0.REG_OUTPUT1_CE = pmi_reg_output_ce ;
    defparam dsp_alu_0.REG_OUTPUT1_CLK = pmi_reg_output_clk ;
    defparam dsp_alu_0.REG_OUTPUT0_RST = pmi_reg_output_rst ;
    defparam dsp_alu_0.REG_OUTPUT0_CE = pmi_reg_output_ce ;
    defparam dsp_alu_0.REG_OUTPUT0_CLK = pmi_reg_output_clk ;
    defparam dsp_alu_0.MULT9_MODE = "DISABLED" ;
    defparam dsp_alu_0.RNDPAT = "0x00000000000000" ;
    defparam dsp_alu_0.MASKPAT = "0x00000000000000" ;
    defparam dsp_alu_0.MCPAT = "0x00000000000000" ;
    defparam dsp_alu_0.MASK01 = "0x00000000000000" ;
    defparam dsp_alu_0.MASKPAT_SOURCE = "STATIC" ;
    defparam dsp_alu_0.MCPAT_SOURCE = "STATIC" ;
    defparam dsp_alu_0.RESETMODE = "ASYNC" ;
    defparam dsp_alu_0.GSR = "ENABLED" ;
    defparam dsp_alu_0.CLK0_DIV = pmi_clk0_div;
    defparam dsp_alu_0.CLK1_DIV = pmi_clk1_div;
    defparam dsp_alu_0.CLK2_DIV = pmi_clk2_div;
    defparam dsp_alu_0.CLK3_DIV = pmi_clk3_div;
    ALU54B dsp_alu_0 (
        .CE0(CE[0]), .CE1(CE[1]), .CE2(CE[2]), .CE3(CE[3]),
        .CLK0(CLK[0]), .CLK1(CLK[1]), .CLK2(CLK[2]), .CLK3(CLK[3]),
        .RST0(RST[0]), .RST1(RST[1]), .RST2(RST[2]), .RST3(RST[3]),
        .SIGNEDIA(mult_out_signedp_0), .SIGNEDIB(mult_out_signedp_1), 
        .A35(mult_out_rob_0_17), .A34(mult_out_rob_0_16), 
        .A33(mult_out_rob_0_15), .A32(mult_out_rob_0_14), 
        .A31(mult_out_rob_0_13), .A30(mult_out_rob_0_12), 
        .A29(mult_out_rob_0_11), .A28(mult_out_rob_0_10), 
        .A27(mult_out_rob_0_9), .A26(mult_out_rob_0_8), 
        .A25(mult_out_rob_0_7), .A24(mult_out_rob_0_6), 
        .A23(mult_out_rob_0_5), .A22(mult_out_rob_0_4), 
        .A21(mult_out_rob_0_3), .A20(mult_out_rob_0_2), 
        .A19(mult_out_rob_0_1), .A18(mult_out_rob_0_0), 
        .A17(mult_out_roa_0_17), .A16(mult_out_roa_0_16), 
        .A15(mult_out_roa_0_15), .A14(mult_out_roa_0_14), 
        .A13(mult_out_roa_0_13), .A12(mult_out_roa_0_12), 
        .A11(mult_out_roa_0_11), .A10(mult_out_roa_0_10), 
        .A9(mult_out_roa_0_9), .A8(mult_out_roa_0_8), .A7(mult_out_roa_0_7), 
        .A6(mult_out_roa_0_6), .A5(mult_out_roa_0_5), .A4(mult_out_roa_0_4), 
        .A3(mult_out_roa_0_3), .A2(mult_out_roa_0_2), .A1(mult_out_roa_0_1), 
        .A0(mult_out_roa_0_0), .B35(mult_out_rob_1_17), 
        .B34(mult_out_rob_1_16), .B33(mult_out_rob_1_15), 
        .B32(mult_out_rob_1_14), .B31(mult_out_rob_1_13), 
        .B30(mult_out_rob_1_12), .B29(mult_out_rob_1_11), 
        .B28(mult_out_rob_1_10), .B27(mult_out_rob_1_9), 
        .B26(mult_out_rob_1_8), .B25(mult_out_rob_1_7), 
        .B24(mult_out_rob_1_6), .B23(mult_out_rob_1_5), 
        .B22(mult_out_rob_1_4), .B21(mult_out_rob_1_3), 
        .B20(mult_out_rob_1_2), .B19(mult_out_rob_1_1), 
        .B18(mult_out_rob_1_0), .B17(mult_out_roa_1_17), 
        .B16(mult_out_roa_1_16), .B15(mult_out_roa_1_15), 
        .B14(mult_out_roa_1_14), .B13(mult_out_roa_1_13), 
        .B12(mult_out_roa_1_12), .B11(mult_out_roa_1_11), 
        .B10(mult_out_roa_1_10), .B9(mult_out_roa_1_9), 
        .B8(mult_out_roa_1_8), .B7(mult_out_roa_1_7), .B6(mult_out_roa_1_6), 
        .B5(mult_out_roa_1_5), .B4(mult_out_roa_1_4), .B3(mult_out_roa_1_3), 
        .B2(mult_out_roa_1_2), .B1(mult_out_roa_1_1), .B0(mult_out_roa_1_0), 
        .C53(C[53]), .C52(C[52]), .C51(C[51]), .C50(C[50]),
        .C49(C[49]), .C48(C[48]), .C47(C[47]), .C46(C[46]), .C45(C[45]),
        .C44(C[44]), .C43(C[43]), .C42(C[42]), .C41(C[41]), .C40(C[40]),
        .C39(C[39]), .C38(C[38]), .C37(C[37]), .C36(C[36]), .C35(C[35]),
        .C34(C[34]), .C33(C[33]), .C32(C[32]), .C31(C[31]), .C30(C[30]),
        .C29(C[29]), .C28(C[28]), .C27(C[27]), .C26(C[26]), .C25(C[25]),
        .C24(C[24]), .C23(C[23]), .C22(C[22]), .C21(C[21]), .C20(C[20]),
        .C19(C[19]), .C18(C[18]), .C17(C[17]), .C16(C[16]), .C15(C[15]),
        .C14(C[14]), .C13(C[13]), .C12(C[12]), .C11(C[11]), .C10(C[10]),
        .C9(C[9]), .C8(C[8]), .C7(C[7]), .C6(C[6]), .C5(C[5]),
        .C4(C[4]), .C3(C[3]), .C2(C[2]), .C1(C[1]), .C0(C[0]),
        .CFB53(CFB[53]), .CFB52(CFB[52]), .CFB51(CFB[51]), .CFB50(CFB[50]),
        .CFB49(CFB[49]), .CFB48(CFB[48]), .CFB47(CFB[47]), .CFB46(CFB[46]), .CFB45(CFB[45]),
        .CFB44(CFB[44]), .CFB43(CFB[43]), .CFB42(CFB[42]), .CFB41(CFB[41]), .CFB40(CFB[40]),
        .CFB39(CFB[39]), .CFB38(CFB[38]), .CFB37(CFB[37]), .CFB36(CFB[36]), .CFB35(CFB[35]),
        .CFB34(CFB[34]), .CFB33(CFB[33]), .CFB32(CFB[32]), .CFB31(CFB[31]), .CFB30(CFB[30]),
        .CFB29(CFB[29]), .CFB28(CFB[28]), .CFB27(CFB[27]), .CFB26(CFB[26]), .CFB25(CFB[25]),
        .CFB24(CFB[24]), .CFB23(CFB[23]), .CFB22(CFB[22]), .CFB21(CFB[21]), .CFB20(CFB[20]),
        .CFB19(CFB[19]), .CFB18(CFB[18]), .CFB17(CFB[17]), .CFB16(CFB[16]), .CFB15(CFB[15]),
        .CFB14(CFB[14]), .CFB13(CFB[13]), .CFB12(CFB[12]), .CFB11(CFB[11]), .CFB10(CFB[10]),
        .CFB9(CFB[9]), .CFB8(CFB[8]), .CFB7(CFB[7]), .CFB6(CFB[6]), .CFB5(CFB[5]),
        .CFB4(CFB[4]), .CFB3(CFB[3]), .CFB2(CFB[2]), .CFB1(CFB[1]), .CFB0(CFB[0]),
        .MA35(mult_out_p_0_35), 
        .MA34(mult_out_p_0_34), .MA33(mult_out_p_0_33), 
        .MA32(mult_out_p_0_32), .MA31(mult_out_p_0_31), 
        .MA30(mult_out_p_0_30), .MA29(mult_out_p_0_29), 
        .MA28(mult_out_p_0_28), .MA27(mult_out_p_0_27), 
        .MA26(mult_out_p_0_26), .MA25(mult_out_p_0_25), 
        .MA24(mult_out_p_0_24), .MA23(mult_out_p_0_23), 
        .MA22(mult_out_p_0_22), .MA21(mult_out_p_0_21), 
        .MA20(mult_out_p_0_20), .MA19(mult_out_p_0_19), 
        .MA18(mult_out_p_0_18), .MA17(mult_out_p_0_17), 
        .MA16(mult_out_p_0_16), .MA15(mult_out_p_0_15), 
        .MA14(mult_out_p_0_14), .MA13(mult_out_p_0_13), 
        .MA12(mult_out_p_0_12), .MA11(mult_out_p_0_11), 
        .MA10(mult_out_p_0_10), .MA9(mult_out_p_0_9), .MA8(mult_out_p_0_8), 
        .MA7(mult_out_p_0_7), .MA6(mult_out_p_0_6), .MA5(mult_out_p_0_5), 
        .MA4(mult_out_p_0_4), .MA3(mult_out_p_0_3), .MA2(mult_out_p_0_2), 
        .MA1(mult_out_p_0_1), .MA0(mult_out_p_0_0), .MB35(mult_out_p_1_35), 
        .MB34(mult_out_p_1_34), .MB33(mult_out_p_1_33), 
        .MB32(mult_out_p_1_32), .MB31(mult_out_p_1_31), 
        .MB30(mult_out_p_1_30), .MB29(mult_out_p_1_29), 
        .MB28(mult_out_p_1_28), .MB27(mult_out_p_1_27), 
        .MB26(mult_out_p_1_26), .MB25(mult_out_p_1_25), 
        .MB24(mult_out_p_1_24), .MB23(mult_out_p_1_23), 
        .MB22(mult_out_p_1_22), .MB21(mult_out_p_1_21), 
        .MB20(mult_out_p_1_20), .MB19(mult_out_p_1_19), 
        .MB18(mult_out_p_1_18), .MB17(mult_out_p_1_17), 
        .MB16(mult_out_p_1_16), .MB15(mult_out_p_1_15), 
        .MB14(mult_out_p_1_14), .MB13(mult_out_p_1_13), 
        .MB12(mult_out_p_1_12), .MB11(mult_out_p_1_11), 
        .MB10(mult_out_p_1_10), .MB9(mult_out_p_1_9), .MB8(mult_out_p_1_8), 
        .MB7(mult_out_p_1_7), .MB6(mult_out_p_1_6), .MB5(mult_out_p_1_5), 
        .MB4(mult_out_p_1_4), .MB3(mult_out_p_1_3), .MB2(mult_out_p_1_2), 
        .MB1(mult_out_p_1_1), .MB0(mult_out_p_1_0),
        .CIN53(CIN[53]), .CIN52(CIN[52]), .CIN51(CIN[51]), .CIN50(CIN[50]),
        .CIN49(CIN[49]), .CIN48(CIN[48]), .CIN47(CIN[47]), .CIN46(CIN[46]), .CIN45(CIN[45]),
        .CIN44(CIN[44]), .CIN43(CIN[43]), .CIN42(CIN[42]), .CIN41(CIN[41]), .CIN40(CIN[40]),
        .CIN39(CIN[39]), .CIN38(CIN[38]), .CIN37(CIN[37]), .CIN36(CIN[36]), .CIN35(CIN[35]),
        .CIN34(CIN[34]), .CIN33(CIN[33]), .CIN32(CIN[32]), .CIN31(CIN[31]), .CIN30(CIN[30]),
        .CIN29(CIN[29]), .CIN28(CIN[28]), .CIN27(CIN[27]), .CIN26(CIN[26]), .CIN25(CIN[25]),
        .CIN24(CIN[24]), .CIN23(CIN[23]), .CIN22(CIN[22]), .CIN21(CIN[21]), .CIN20(CIN[20]),
        .CIN19(CIN[19]), .CIN18(CIN[18]), .CIN17(CIN[17]), .CIN16(CIN[16]), .CIN15(CIN[15]),
        .CIN14(CIN[14]), .CIN13(CIN[13]), .CIN12(CIN[12]), .CIN11(CIN[11]), .CIN10(CIN[10]),
        .CIN9(CIN[9]), .CIN8(CIN[8]), .CIN7(CIN[7]), .CIN6(CIN[6]), .CIN5(CIN[5]),
        .CIN4(CIN[4]), .CIN3(CIN[3]), .CIN2(CIN[2]), .CIN1(CIN[1]), .CIN0(CIN[0]),
        .SIGNEDCIN(SIGNCIN),
        .OP10(1'b0), .OP9(scuba_vhi), .OP8(1'b0), .OP7(1'b0),
        .OP6(CMUXSEL[2]), .OP5(CMUXSEL[1]), .OP4(CMUXSEL[0]), 
        .OP3(BMUXSEL[1]), .OP2(BMUXSEL[0]), .OP1(AMUXSEL[1]), .OP0(AMUXSEL[0]),
        .R53(R[53]), .R52(R[52]), .R51(R[51]), .R50(R[50]),
        .R49(R[49]), .R48(R[48]), .R47(R[47]), .R46(R[46]), .R45(R[45]),
        .R44(R[44]), .R43(R[43]), .R42(R[42]), .R41(R[41]), .R40(R[40]),
        .R39(R[39]), .R38(R[38]), .R37(R[37]), .R36(R[36]), .R35(R[35]),
        .R34(R[34]), .R33(R[33]), .R32(R[32]), .R31(R[31]), .R30(R[30]),
        .R29(R[29]), .R28(R[28]), .R27(R[27]), .R26(R[26]), .R25(R[25]),
        .R24(R[24]), .R23(R[23]), .R22(R[22]), .R21(R[21]), .R20(R[20]),
        .R19(R[19]), .R18(R[18]), .R17(R[17]), .R16(R[16]), .R15(R[15]),
        .R14(R[14]), .R13(R[13]), .R12(R[12]), .R11(R[11]), .R10(R[10]),
        .R9(R[9]), .R8(R[8]), .R7(R[7]), .R6(R[6]), .R5(R[5]),
        .R4(R[4]), .R3(R[3]), .R2(R[2]), .R1(R[1]), .R0(R[0]),
        .CO53(CO[53]), .CO52(CO[52]), .CO51(CO[51]), .CO50(CO[50]),
        .CO49(CO[49]), .CO48(CO[48]), .CO47(CO[47]), .CO46(CO[46]), .CO45(CO[45]),
        .CO44(CO[44]), .CO43(CO[43]), .CO42(CO[42]), .CO41(CO[41]), .CO40(CO[40]),
        .CO39(CO[39]), .CO38(CO[38]), .CO37(CO[37]), .CO36(CO[36]), .CO35(CO[35]),
        .CO34(CO[34]), .CO33(CO[33]), .CO32(CO[32]), .CO31(CO[31]), .CO30(CO[30]),
        .CO29(CO[29]), .CO28(CO[28]), .CO27(CO[27]), .CO26(CO[26]), .CO25(CO[25]),
        .CO24(CO[24]), .CO23(CO[23]), .CO22(CO[22]), .CO21(CO[21]), .CO20(CO[20]),
        .CO19(CO[19]), .CO18(CO[18]), .CO17(CO[17]), .CO16(CO[16]), .CO15(CO[15]),
        .CO14(CO[14]), .CO13(CO[13]), .CO12(CO[12]), .CO11(CO[11]), .CO10(CO[10]),
        .CO9(CO[9]), .CO8(CO[8]), .CO7(CO[7]), .CO6(CO[6]), .CO5(CO[5]),
        .CO4(CO[4]), .CO3(CO[3]), .CO2(CO[2]), .CO1(CO[1]), .CO0(CO[0]),
        .EQZ(), .EQZM(), .EQOM(), .EQPAT(), 
        .EQPATB(), .OVER(), .UNDER(), .OVERUNDER(), .SIGNEDR(SIGNR));


//pragma translate_on
   
endmodule
