`timescale 1ns / 1ps

module tb();
    wire   led;
    reg    clk = 0;
    reg    reset;
    reg    i_Rx_Serial;
    wire    o_Tx_Serial;
    wire    serial_bus_line;


    //uart_tx PC
    //tx
    reg         i_Tx_start_tb;
    reg [7:0]   i_Tx_Byte_tb = 0;
    wire        o_Tx_Done_tb;

uart_top#(          .c_clkfreq  (100_000_000),
                    .c_baudrate (115_200))
     DUT
    (
        .clk        (clk),
        .reset      (reset),
        .i_Rx_Serial(i_Rx_Serial),
        .o_Tx_Serial(o_Tx_Serial),
        .led(led)
    );


uart_tx_t 
    #(
        .c_clkfreq  (100_000_000),
        .c_baudrate (115_200)
    )
    DUT_tb
    (
        .i_clk         (clk),
        .i_Tx_start    (i_Tx_start_tb),	
        .i_Tx_Byte     (i_Tx_Byte_tb),
        .o_Tx_Active   (),		
        .o_Tx_Serial   (serial_bus_line),   
        .o_Tx_Done     (o_Tx_Done_tb)
    );

  always #5 clk = ~clk;
  
  //reset
  initial begin
  
    reset = 1'b1;
    #100;
    reset = 1'b0;
  
  end
   
   
// initial begin
    
//    // ram e veri yazma
//    i_Tx_start_tb = 1'b1;
//    i_Tx_Byte_tb = 8'h01;
//    @(posedge o_Tx_Done_tb);
//    i_Tx_Byte_tb = 8'h01;
//    @(posedge o_Tx_Done_tb);
//    i_Tx_Byte_tb = 8'd46;
//    @(posedge o_Tx_Done_tb);
//    i_Tx_Byte_tb = 8'd2;
//    @(negedge led);
//    @(posedge o_Tx_Done_tb);
//    i_Tx_Byte_tb = 8'd46;
//    @(posedge o_Tx_Done_tb); 
//    i_Tx_Byte_tb = 8'd84;
//    @(posedge o_Tx_Done_tb);
//    i_Tx_Byte_tb = 8'h01;
//    @(posedge o_Tx_Done_tb);
//    i_Tx_Byte_tb = 8'h01;
//    @(posedge o_Tx_Done_tb);
//    i_Tx_Byte_tb = 8'd46;
//    @(posedge o_Tx_Done_tb);
//    i_Tx_Byte_tb = 8'd2;
//    @(posedge o_Tx_Done_tb);
//    i_Tx_Byte_tb =8'h0d;
//    @(negedge led);
//    #25000;
//    $stop;
   always  begin 
  // initial begin
  //nokta:  00101110
  //toplama:01010100
  //çýkarma:01110011
  //çarpma :01100011
  //bölme  :01100010
  //eþittir:00001101
        i_Rx_Serial <= 1'b0;
        #8688;
        //1
        i_Rx_Serial <= 1'b1;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b1;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        
        i_Rx_Serial <= 1'b1;
        #8688;
        
        #150000;
        #75000;
        
        i_Rx_Serial <= 1'b0;
        #8688;
        //00101110 .
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b1;
        #8688;
        i_Rx_Serial <= 1'b1;
        #8688;
        i_Rx_Serial <= 1'b1;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b1;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        
        i_Rx_Serial <= 1'b1;
        #8688;
        
        #150000;
        #75000;
        
        i_Rx_Serial <= 1'b0;
        #8688;
        //5
        i_Rx_Serial <= 1'b1;
        #8688;
        i_Rx_Serial <= 1'b1;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        
        i_Rx_Serial <= 1'b1;
        #8688;
        #150000;
        #75000;
        
        i_Rx_Serial <= 1'b0;
        #8688;
        //01010100 +
        i_Rx_Serial <= 1'b1;
        #8688;
        i_Rx_Serial <= 1'b1;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b1;
        #8688;
        i_Rx_Serial <= 1'b1;
        #8688;
        i_Rx_Serial <= 1'b1;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        
        i_Rx_Serial <= 1'b1;
        #8688;
        #150000;
        #75000;
        
        i_Rx_Serial <= 1'b0;
        #8688;
        //1
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b1;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        
        i_Rx_Serial <= 1'b1;
        #8688;
        
        #150000;
        #75000;
        
        i_Rx_Serial <= 1'b0;
        #8688;
        //00101110 .
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b1;
        #8688;
        i_Rx_Serial <= 1'b1;
        #8688;
        i_Rx_Serial <= 1'b1;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b1;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        
        i_Rx_Serial <= 1'b1;
        #8688;
        
        #150000;
        #75000;
        
        i_Rx_Serial <= 1'b0;
        #8688;
        //5
        i_Rx_Serial <= 1'b1;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        
        i_Rx_Serial <= 1'b1;
        #8688;
        #150000;
        #75000;
        i_Rx_Serial <= 1'b0;
        #8688;
        //00001101 eþittir
        i_Rx_Serial <= 1'b1;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b1;
        #8688;
        i_Rx_Serial <= 1'b1;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        i_Rx_Serial <= 1'b0;
        #8688;
        
        i_Rx_Serial <= 1'b1;
        #8688;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #150000;
        #75000;
        #75000;
        #150000;
        #75000;
        
         
         $stop;

       
    //ram den okuma
//    i_Tx_Byte_tb = 8'hBB;
//    @(posedge o_Tx_Done_tb);
//    i_Tx_Byte_tb = 8'h00;
//    @(posedge o_Tx_Done_tb);
//    i_Tx_start_tb = 1'b0;
//    @(negedge led); 
   
 end

endmodule