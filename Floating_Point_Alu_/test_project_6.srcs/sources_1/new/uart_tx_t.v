`timescale 1ns / 1ps

module uart_tx_t
    #(   
    parameter c_clkfreq    = 100_000_000,
    parameter c_baudrate   = 115_200         // Her bir clock'ta geçen bit sayýsý.
    )
    (
    input       i_clk,
    input       i_Tx_start,	
    input [7:0] i_Tx_Byte,
    output      o_Tx_Active,		
    output reg  o_Tx_Serial,
    output      o_Tx_Done	
    );
   			                                                  // Veri hattýndan saniyede geçen bit sayýsý.
    localparam CLKS_PER_BIT = c_clkfreq/c_baudrate;	         // Her bir clock'ta geçen bit sayýsý.
  
    localparam s_IDLE         = 2'b00;
    localparam s_TX_START_BIT = 2'b01;
    localparam s_TX_DATA_BITS = 2'b10;
    localparam s_TX_STOP_BIT  = 2'b11;
    
   
    reg [2:0]                       r_durum     	 = 0;	
    reg [$clog2(CLKS_PER_BIT)-1:0]  r_Clock_Count = 0;
    reg [2:0]                       r_Bit_Index   = 0;
    reg [7:0]                       r_Tx_Data     = 0;
    reg                             r_Tx_Done     = 0;
    reg                             r_Tx_Active   = 0;
     
    always @(posedge (i_clk))
        begin
       
        case (r_durum)
            s_IDLE :
            begin
                o_Tx_Serial   <= 1'b1;                          // IDLE durumunda veri hattý logic 1 seviyesinde.
                r_Tx_Done     <= 1'b0;
                r_Clock_Count <= 0;
                r_Bit_Index   <= 0;
             
                if (i_Tx_start == 1'b1)
                begin
                    r_Tx_Active <= 1'b1;
                    r_Tx_Data   <= i_Tx_Byte;
                    r_durum     <= s_TX_START_BIT;
                end
                else
                r_durum <= s_IDLE;
            end 
         
         
            // Veri göndermeye baþlamak için veri hattý "CLKS_PER_BIT-1" kadar logic 0'da kalýr.
            s_TX_START_BIT :
            begin
                o_Tx_Serial <= 1'b0;
             
                // Start biti için "CLKS_PER_BIT-1" kadar beklenir.
                if (r_Clock_Count < CLKS_PER_BIT-1)
                begin
                    r_Clock_Count <= r_Clock_Count + 1;
                    r_durum  	  <= s_TX_START_BIT;
                end else begin
                    r_Clock_Count <= 0;
                    r_durum       <= s_TX_DATA_BITS;
                end
            end 
         
         
            // Her bir veri biti aktarýlýrken "CLKS_PER_BIT-1" kadar beklenir.         
            s_TX_DATA_BITS :
            begin
                o_Tx_Serial <= r_Tx_Data[r_Bit_Index];
             
                if (r_Clock_Count < CLKS_PER_BIT-1)
                begin
                    r_Clock_Count <= r_Clock_Count + 1;
                    r_durum       <= s_TX_DATA_BITS;
                end else begin
                    r_Clock_Count <= 0;
                 
                    // Tüm bitler gönderildi mi kontrol edilir.
                    if (r_Bit_Index < 7)
                    begin
                        r_Bit_Index <= r_Bit_Index + 1;
                        r_durum     <= s_TX_DATA_BITS;
                    end else begin
                        r_Bit_Index <= 0;
                        r_durum     <= s_TX_STOP_BIT;
                    end
                end
            end 
         
         
            // Stop bit gönderilir, STOP bit logic 1'dir.
            s_TX_STOP_BIT :
            begin
                o_Tx_Serial <= 1'b1;
             
                // Stop biti için "CLKS_PER_BIT-1" kadar beklenir.
                if (r_Clock_Count < CLKS_PER_BIT-1)
                begin
                    r_Clock_Count <= r_Clock_Count + 1;
                    r_durum       <= s_TX_STOP_BIT;
                end else begin
                    r_Tx_Done     <= 1'b1;
                    r_Clock_Count <= 0;
                    r_durum       <= s_IDLE;
                    r_Tx_Active   <= 1'b0;
                end
            end 
         
        endcase
        end
    
    assign o_Tx_Active = r_Tx_Active;
    assign o_Tx_Done   = r_Tx_Done;
   
endmodule