`timescale 1ns / 1ps

module uart_rx_t
    #(   
    parameter c_clkfreq    = 100_000_000,
    parameter c_baudrate   = 115_200         // Her bir clock'ta geçen bit sayýsý.
    )(
    input        i_clk,
    input        i_Rx_Serial,    	// Veri hattý.
    output       o_Rx_done,		// Verinin alýndýðýný belirtir.
    output [7:0] o_Rx_Byte 		// Alýnan veri.
    
    );
        
    //constrait olarak pinleri tanýmla top modülde bir veri göndermeyle ilgili bir örnek yap.
    localparam CLKS_PER_BIT = c_clkfreq/c_baudrate;
    localparam s_IDLE         = 2'b00;	
    localparam s_RX_START_BIT = 2'b01;
    localparam s_RX_DATA_BITS = 2'b10;
    localparam s_RX_STOP_BIT  = 2'b11;
    
    reg           r_Rx_Data_R = 1'b1;		// IDLE durumundan baþlýyoruz bu yüzden logic 1'de.
    reg           r_Rx_Data   = 1'b1;		// IDLE durumundan baþlýyoruz bu yüzden logic 1'de.
   
    reg [$clog2(CLKS_PER_BIT)-1:0]      r_Clock_Count = 0;
    reg [2:0]                           r_Bit_counter = 0; //Toplam 8 veri biti.
    reg [7:0]                           r_Rx_Byte     = 0;
    reg                                 r_Rx_done     = 0;
    reg [2:0]                           r_SM_Main     = 0;
   
    // Gelen veriler iki kez kaydedilir. 
    // Ýki kez kaydedilen veriler, örneklemeden kaynaklanan sorunlarý ortadan kaldýrýr. 
    // Bu sayede clock etki alanýnda sýkýntý çýkmaz.
    /*
    always @(posedge (i_clk))
        begin
        r_Rx_Data  <= i_Rx_Serial;
        end
   */
   
   // Gelen veriler iki kez kaydedilir. 
   // Ýki kez kaydedilen veriler, örneklemeden kaynaklanan sorunlarý ortadan kaldýrýr. 
   // Bu sayede clock etki alanýnda sýkýntý çýkmaz.
   always @(posedge (i_clk))
       begin
       r_Rx_Data_R <= i_Rx_Serial;    
       r_Rx_Data   <= r_Rx_Data_R;    
       end
  
  
 
     always @(posedge (i_clk))
         begin
        
         case (r_SM_Main)
             s_IDLE :
             begin
                 r_Rx_done     = 1'b0;
                 r_Clock_Count = 0;
                 r_Bit_counter = 0;
              
                 if (r_Rx_Data == 1'b0)          // Baþlama bitinin tespiti saðlanýr.
                     r_SM_Main = s_RX_START_BIT;
                 else
                     r_SM_Main = s_IDLE;
             end
   
    
              
             // Örnekleme yapabilmek için baþlangýç bitinin ortasý alýnýr.
                 s_RX_START_BIT :
                 begin
                     if (r_Clock_Count == (CLKS_PER_BIT-1)/2) // constant' a böldüðümüz için sýkýntý yok aslýnda burda yapýlan iþlem saða kaydýrma "" {1'b0,BAUD_DIV[15:1]}; ""
                     begin
                         if (r_Rx_Data == 1'b0)  //Baþlangýç bitini algýlamak için veri hattý sorgulanýr.
                         begin
                             r_Clock_Count <= 0;  // Baþlangýç biti logic 0'daysa clock sayacý sýfýrlanýr.
                             r_SM_Main     <= s_RX_DATA_BITS;
                         end
                         else
                             r_SM_Main <= s_IDLE;
                         end else begin 
                             r_Clock_Count <= r_Clock_Count + 1;
                             r_SM_Main     <= s_RX_START_BIT;
                         end
                     end 
                     
                     // Verileri örneklemek için "CLKS_PER_BIT-1" kadar beklenir.
                     s_RX_DATA_BITS :
                     begin
                         if (r_Clock_Count < CLKS_PER_BIT-1)
                         begin
                             r_Clock_Count <= r_Clock_Count + 1;
                             r_SM_Main     <= s_RX_DATA_BITS;
                         end else begin
                         r_Clock_Count            <= 0;
                         r_Rx_Byte[r_Bit_counter] <= r_Rx_Data;
                      
                         // Tüm bitlerin alýnýp alýnmadýðý kontorl edilir.
                         if (r_Bit_counter < 7) 
                         begin
                             r_Bit_counter <= r_Bit_counter + 1; 
                             r_SM_Main     <= s_RX_DATA_BITS;
                         end else begin
                             r_Bit_counter <= 0;
                             r_SM_Main     <= s_RX_STOP_BIT;
                         end
                     end
                 end 
            
                 // Stop bit alýnýr. 
                 s_RX_STOP_BIT :
                 begin
                     // Dur biti için "CLKS_PER_BIT-1" kadar beklenir.
                     if (r_Clock_Count < CLKS_PER_BIT-1)
                     begin
                         r_Clock_Count <= r_Clock_Count + 1;
                         r_SM_Main     <= s_RX_STOP_BIT;
                     end else begin
                         r_Rx_done     <= 1'b1;
                         r_Clock_Count <= 0;
                         r_SM_Main     <= s_IDLE;
                     end
                 end 
            
             endcase
        end   
    
    
    assign o_Rx_done = r_Rx_done; 
    assign o_Rx_Byte = r_Rx_Byte;
   
endmodule