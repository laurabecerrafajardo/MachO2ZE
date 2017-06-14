
module demo_top (
  input   rst               , // 
  input   clk_USB           , // clk                       
  output  COUNT             ,
  
  
  input   Icc_analog_cmp_n  ,
  input   Icc_analog_cmp_p  ,
  output  Icc_analog_out    ,
  input   Icco_analog_cmp_n ,
  input   Icco_analog_cmp_p ,
  output  Icco_analog_out   ,          
  output  EnAMP             ,
  
  // LCD               
  output  LCD_COM0          ,       
  output  LCD_COM1          ,       
  output  LCD_COM2          ,       
  output  LCD_COM3          ,       
  output  LCD_5             ,          
  output  LCD_6             ,          
  output  LCD_7             ,          
  output  LCD_8             ,          
  output  LCD_9             ,          
  output  LCD_10            ,         
  output  LCD_11            ,         
  output  LCD_12                     
);

  parameter COUNT_NUM = 11 ; 
  
  wire [COUNT_NUM-1:0] CO ;     
  wire [7:0] adc_dig_data  /* synthesis syn_noprune = 1 */ ;
  wire [7:0] convert_data  /* synthesis syn_noprune = 1 */ ;
  wire [7:0] int_data1     /* synthesis syn_noprune = 1 */ ; 
  wire [7:0] int_data2     /* synthesis syn_noprune = 1 */ ; 
  wire signed [7:0] display_data /* synthesis syn_noprune = 1 */ ; 
  wire signed [7:0] display_dec  /* synthesis syn_noprune = 1 */ ; 
  wire signed [7:0] display_dec1 /* synthesis syn_noprune = 1 */ ; 
  wire       analog_out   ; 

  // LCD display
  wire [7:0]  LCD1      ;
  wire [7:0]  LCD2      ;
  wire [7:0]  LCD3      ;
  wire [7:0]  LCD4      ;
  wire        LCDDP1    ;
  wire        LCDDP2    ;
  wire        LCDDP3    ;
  wire        LCDCol    ;
  
  // power control
  reg stdby_reg ;
  reg stdby_reg_d ;
  wire user_stdby ;
  wire STDBY ;

  // analog input
  wire Icc_analog_cmp;
  ILVDS i0 ( .A(Icc_analog_cmp_p), .AN(Icc_analog_cmp_n), .Z(Icc_analog_cmp));
//	wire Icco_analog_cmp;
//	ILVDS i1 ( .A(Icco_analog_cmp_p), .AN(Icco_analog_cmp_n), .Z(Icco_analog_cmp));

//Soft Delta-Sigma ADC
ADC_top adc_inst(
  .clk_in         (clk_USB        ),
  .rstn           (1'b1           ),
  .digital_out    (adc_dig_data   ),
  .analog_cmp     (Icc_analog_cmp ),	
  .analog_out     (analog_out     ),
  .sample_rdy     (     )
  );

assign Icc_analog_out = analog_out ;                   
assign EnAMP = 1 ;

// convert ADC output to display in mA, simplified Dec display
assign convert_data = ~adc_dig_data ; // (~adc_dig_data)>>3 ;
assign int_data1 = convert_data>>3 ;
assign int_data2 = convert_data>>4 ;
assign display_data = int_data1 + int_data2 - 1;
assign display_dec1 = display_data - 8'd10 ;
assign display_dec = (display_data<8'd10) ? display_data : { 4'b0001, display_dec1[3:0] } ;

display display_inst (        
  .clk_i     ( clk_USB      ),    
  .rst_n     ( !rst      ),    
  .data_in   ( display_dec ),    // data to be displayed, highly simplified
  .LCD1      ( LCD1     ),    
  .LCD2      ( LCD2     ),    
  .LCD3      ( LCD3     ),    
  .LCD4      ( LCD4     ),    
  .LCDDP1    ( LCDDP1   ),    
  .LCDDP2    ( LCDDP2   ),    
  .LCDDP3    ( LCDDP3   ),    
  .LCDCol    ( LCDCol   ),    
  .LCDEnWB   (   )     
  );                          


lcd_display lcd_display_inst (
  .rst     (1'b1 )  ,  
  .clk_in  (clk_USB )  , 
          
  .LCD1    ( LCD1   )  ,
  .LCD2    ( LCD2   )  ,
  .LCD3    ( LCD3   )  ,
  .LCD4    ( LCD4   )  ,
  .LCDDP1  ( LCDDP1 )  ,
  .LCDDP2  ( LCDDP2 )  ,
  .LCDDP3  ( LCDDP3 )  ,
  .LCDCol  ( LCDCol )  ,

  .LCD_COM0  ( LCD_COM0 ),       
  .LCD_COM1  ( LCD_COM1 ),       
  .LCD_COM2  ( LCD_COM2 ),       
  .LCD_COM3  ( LCD_COM3 ),       
  .LCD_5     ( LCD_5    ),          
  .LCD_6     ( LCD_6    ),          
  .LCD_7     ( LCD_7    ),          
  .LCD_8     ( LCD_8    ),          
  .LCD_9     ( LCD_9    ),          
  .LCD_10    ( LCD_10   ),         
  .LCD_11    ( LCD_11   ),         
  .LCD_12    ( LCD_12   )     

);

// power control
  always@(posedge clk_osc or negedge rst) begin
     if (rst == 0) begin
        stdby_reg   <= 0 ;
        stdby_reg_d <= 0 ;
     end
     else begin
        stdby_reg   <= 1 ;      
        stdby_reg_d <= stdby_reg ;
     end
  end
  
  assign user_stdby = stdby_reg & (~stdby_reg_d) ;

  OSCH 
    #	(.NOM_FREQ ( "66.50") )  // 66.50 24.18
  OSCH_inst 
  (
    .STDBY    ( rst ), // level sensitive. STDBY
    .OSC      ( clk_osc),
    .SEDSTDBY ( )
    ) /* synthesis syn_noprune = 1 */ ;

// counter logic to consume power
genvar i;
generate for (i=0; i<COUNT_NUM; i=i+1) begin: counter
count16_ldrg 
    (	
    .CLK_OSC    ( clk_osc ),
    .DIR        ( 1'b1    ),
    .COUNT      ( CO[i]   )
    );
end endgenerate

assign COUNT = &CO ;

endmodule