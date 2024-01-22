`timescale 1ns / 1ps

module uart_rx_t
    #(   
    parameter c_clkfreq    = 100_000_000,
    parameter c_baudrate   = 115_200         // Her bir clock'ta ge�en bit say�s�.
    )(
    input        i_clk,
    input        i_Rx_Serial,    	// Veri hatt�.
    output       o_Rx_done,		// Verinin al�nd���n� belirtir.
    output [7:0] o_Rx_Byte 		// Al�nan veri.
    
    );
        
    //constrait olarak pinleri tan�mla top mod�lde bir veri g�ndermeyle ilgili bir �rnek yap.
    localparam CLKS_PER_BIT = c_clkfreq/c_baudrate;
    localparam s_IDLE         = 2'b00;	
    localparam s_RX_START_BIT = 2'b01;
    localparam s_RX_DATA_BITS = 2'b10;
    localparam s_RX_STOP_BIT  = 2'b11;
    
    reg           r_Rx_Data_R = 1'b1;		// IDLE durumundan ba�l�yoruz bu y�zden logic 1'de.
    reg           r_Rx_Data   = 1'b1;		// IDLE durumundan ba�l�yoruz bu y�zden logic 1'de.
   
    reg [$clog2(CLKS_PER_BIT)-1:0]      r_Clock_Count = 0;
    reg [2:0]                           r_Bit_counter = 0; //Toplam 8 veri biti.
    reg [7:0]                           r_Rx_Byte     = 0;
    reg                                 r_Rx_done     = 0;
    reg [2:0]                           r_SM_Main     = 0;
   
    // Gelen veriler iki kez kaydedilir. 
    // �ki kez kaydedilen veriler, �rneklemeden kaynaklanan sorunlar� ortadan kald�r�r. 
    // Bu sayede clock etki alan�nda s�k�nt� ��kmaz.
    /*
    always @(posedge (i_clk))
        begin
        r_Rx_Data  <= i_Rx_Serial;
        end
   */
   
   // Gelen veriler iki kez kaydedilir. 
   // �ki kez kaydedilen veriler, �rneklemeden kaynaklanan sorunlar� ortadan kald�r�r. 
   // Bu sayede clock etki alan�nda s�k�nt� ��kmaz.
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
              
                 if (r_Rx_Data == 1'b0)          // Ba�lama bitinin tespiti sa�lan�r.
                     r_SM_Main = s_RX_START_BIT;
                 else
                     r_SM_Main = s_IDLE;
             end
   
    
              
             // �rnekleme yapabilmek i�in ba�lang�� bitinin ortas� al�n�r.
                 s_RX_START_BIT :
                 begin
                     if (r_Clock_Count == (CLKS_PER_BIT-1)/2) // constant' a b�ld���m�z i�in s�k�nt� yok asl�nda burda yap�lan i�lem sa�a kayd�rma "" {1'b0,BAUD_DIV[15:1]}; ""
                     begin
                         if (r_Rx_Data == 1'b0)  //Ba�lang�� bitini alg�lamak i�in veri hatt� sorgulan�r.
                         begin
                             r_Clock_Count <= 0;  // Ba�lang�� biti logic 0'daysa clock sayac� s�f�rlan�r.
                             r_SM_Main     <= s_RX_DATA_BITS;
                         end
                         else
                             r_SM_Main <= s_IDLE;
                         end else begin 
                             r_Clock_Count <= r_Clock_Count + 1;
                             r_SM_Main     <= s_RX_START_BIT;
                         end
                     end 
                     
                     // Verileri �rneklemek i�in "CLKS_PER_BIT-1" kadar beklenir.
                     s_RX_DATA_BITS :
                     begin
                         if (r_Clock_Count < CLKS_PER_BIT-1)
                         begin
                             r_Clock_Count <= r_Clock_Count + 1;
                             r_SM_Main     <= s_RX_DATA_BITS;
                         end else begin
                         r_Clock_Count            <= 0;
                         r_Rx_Byte[r_Bit_counter] <= r_Rx_Data;
                      
                         // T�m bitlerin al�n�p al�nmad��� kontorl edilir.
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
            
                 // Stop bit al�n�r. 
                 s_RX_STOP_BIT :
                 begin
                     // Dur biti i�in "CLKS_PER_BIT-1" kadar beklenir.
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