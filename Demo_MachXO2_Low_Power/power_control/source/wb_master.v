// simple wishbone master used to write a wishbone slave

module wb_master (

  input        rst      ,
  input        clk      ,
  input        start    , // start wishbone transaction
  input  [7:0] addr_in  , // slave address to be written to
  input  [7:0] data_in  , // data to be written

  // wishbone interface
  input        wb_ack_i ,
  output reg   wb_stb_o ,
  output reg   wb_we_o  ,
  output       wb_sel_o ,
  output reg   wb_cyc_o ,
  output [7:0] wb_dat_o ,
  output [7:0] wb_adr_o 

);

reg wb_idle ;

//  WB register transactor
//  Assert stb/cyc until EFB acknowledges with wb_ack_i
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    wb_idle <= 1;
    wb_stb_o <= 0;
    wb_cyc_o <= 0;
    wb_we_o <= 0;
  end else begin
    //  Assert stb/cyc signals to start WB transaction
        if (wb_idle) begin
            if (start) begin
              wb_stb_o <= #1 1;       // delay 1 ns to avoid simulation/hardware mismatch
              wb_cyc_o <= #1 1;       // delay 1 ns to avoid simulation/hardware mismatch
              wb_we_o  <= 1;
              wb_idle <= 0;
            end
    // Monitor ack_o for end of transaction
        end else begin
            if (wb_ack_i) begin
              wb_stb_o <= 0;
              wb_cyc_o <= 0;
              wb_we_o <= 0;
              wb_idle <= 1;
            end
        end
  end
end

  // Common signals driven out to all WB slaves
  assign wb_write =  1 ;
  assign wb_sel_o =  wb_write ;   // For an 8-bit databus, byte enable selected for any transfer
  assign wb_dat_o =  data_in  ;   // 8'hE0    ;   // LM8 data sent to all WB slaves
  assign wb_adr_o =  addr_in  ;   // 8'h55    ;   // LM8 lower address bits sent to all WB slaves

endmodule