`timescale 1ns / 1ps


module uart_top#(   c_clkfreq   = 100_000_000,
                    c_baudrate  = 115_200)
    (
        input   wire    clk,
        input   wire    reset,
        input   wire    i_Rx_Serial,
        output  wire    o_Tx_Serial,
        output  reg     [15:0] led
    );



reg [4:0]   state       = 0;
//reg [3:0]   counter     = 0;
reg [7:0]   transit_val = 0;
reg [7:0]   transit_val1 = 0;
reg [4:0]   state_1     = 0;

//tx
reg         i_Tx_start;
reg [7:0]   i_Tx_Byte = 0;
wire        o_Tx_Done;
wire        o_Tx_Active;

//rx
wire        o_Rx_done;
wire [7:0]  o_Rx_Byte;

//ram
   
reg loop_done ;   
reg     [7:0]    addr_in=0;
reg     [7:0]    data_in;
reg              write_en;
wire    [7:0]    data_o;

reg [31:0] decimal_value_top1;
reg [31:0] decimal_value_top2;
integer i =0,gec=0;
integer  counter=0;
reg [7:0] address=0;               
reg [7:0] data_input             ;
reg write_enable                 ;
wire [31:0] left_first_data_out   ;
wire [31:0] left_second_data_out  ;
wire [31:0] right_first_data_out  ;
wire [31:0]  right_second_data_out;
wire [31:0] process_out          ;
wire        loop_done_out        ;
wire [31:0] decimal_value1       ;
wire [31:0] decimal_value2        ;
//intfp
reg  [31:0] g1_i;      
wire signed [31:0] c_o;
reg en_i_don;
reg [31:0] don1;
reg [31:0] don2;
reg [31:0]don3;
reg [31:0] don4;
reg [31:0] don5;
reg [31:0] don6;
reg [31:0] don7;
//toplama
reg[ 31:0] g1_i_toplama,g2_i_toplama; 
wire [31:0] toplam_o;
reg en_i_toplama;
reg a=32'd10;
//bölme
reg [31:0] a_i_top;
reg  [31:0] b_i_top;   
reg en_i; 
wire [31:0] sonuc_o ;
reg  [31:0] decimal_top_s1;
reg  [31:0] decimal_top_s2;
//sayýlar
reg  [31:0] s1;
reg  [31:0] s2;
//carpma
reg en_i_carpma;
reg [31:0] x1_i_carpma,x2_i_carpma;
wire  [31:0] sonuc_o_carpma  ;
//cikarma   
reg en_sub;           
reg [31:0] A_i_cikarma, B_i_cikarma; 
wire [31:0] fark_out_cikarma ;
//fp_int_don
 reg en_int_fp;
 reg [31:0] g1_int;         
 wire signed [31:0] c_int;  
 reg [31:0] int_sonuc; 
 //basamak
 reg  [15:0] binary_input     ;  
 wire [31:0] multiplied_output ;
 wire [3:0] point_output     ;
 wire zero_output    ;
 //sonuc
 reg [31:0] sonuc_point_poz;
 reg [31:0] sonuc_point_poz_don;  
 reg [31:0] sonuc_segment_fp   ;
 reg [16:0] sonuc_segment_int  ;
 reg [31:0] decimal_top_s1_value;
 reg [31:0] decimal_top_s2_value;
 reg [31:0] sonuc;

localparam  ram_write    = 5'b00000;
localparam  ram_read     = 5'b00001;
localparam  fp_don       = 5'b00010;
localparam  decimalvalue = 5'b00011;
localparam  combining    = 5'b00100;
localparam  topla        = 5'b00101;
localparam  cikar        = 5'b00110;
localparam  carp         = 5'b00111;
localparam  bol          = 5'b01000; 
localparam  sonuc_tx     = 5'b01001;
localparam  transmitter  = 5'b01010;
localparam transmitter1   = 5'b01011;
localparam transmitter_nokta = 5'b01100;   

always@(posedge clk) begin

    if(reset) begin
        
        state       <= 0;
        transit_val <= 0;
        transit_val1<= 0;
        led         <= 0;
        
    end else begin
    
        case(state)       
        
            ram_write: begin
                case(state_1)
                    0: begin
                        if(o_Rx_done) begin
                            led={8'h0,o_Rx_Byte};
                            if(o_Rx_Byte==8'h0d)begin
                            state       <= ram_read;
                            data_in     <= 8'h0d;
                            write_en    <= 1'b1;
                            state_1     <= 0;
                            end else begin
                            data_in     <= o_Rx_Byte;
                            state_1     <= 1;
                            end
                        end
                    end
                    1: begin
                            write_en    <= 1'b1;
                            state_1     <= 2;
                    end
                    2:begin
                    write_en    <= 1'b0;
                    addr_in     <= addr_in+1'b1;
                    state_1     <= 0;
                    end
                endcase
            end
            
            ram_read: begin
                case(state_1) 
                0: begin 
                     write_en    <= 1'b0;
                     addr_in     <=  1'b0;
                     address     <=  1'b0;
                     state_1     <=  1;
                
                end
                1: begin
                       
                   state_1     <=  2;
                end
                
                2: begin
                    data_input  <= data_o; 
                    write_enable <=1'b1;
                    state_1     <= 3;
                end
                 3: begin
                    write_enable <=1'b0;
                    address     <=address+ 1'b1;
                    addr_in     <=addr_in+ 1'b1;
                    state_1     <= 4;
                end
                4:begin
                if(data_input!=8'h0d)begin
                    state_1     <= 1;
                    end else begin
                    state_1     <= 0;
                    state       <=decimalvalue;
                    end
                end
               endcase
            end
            
            
            decimalvalue :begin
              if(loop_done_out)begin
                case(state_1)
                    0:begin
                        if (decimal_value1 == 32'd1) begin
                        decimal_value_top1 <= 32'd10;
                        state_1<=1;
                        end else begin
                        state_1<=1;
                        end
                    end
                    1:begin
                       if (decimal_value1 == 32'd2) begin
                       decimal_value_top1 <= 32'd100;
                       state_1<=2;
                       end else begin
                       state_1<=2;
                       end                                           
                    end
                    2:begin
                      if(decimal_value1 ==32'd3)begin
                      decimal_value_top1 <= a*decimal_value1;
                      state_1<=3;
                      end else begin
                      state_1<=3;
                      end 
                    end
                    3:begin
                        if (decimal_value2 == 32'd1) begin
                        decimal_value_top2 <= 32'd10;
                        state_1<=4;
                        end else begin
                        state_1<=4;
                        end
                    end
                    4:begin
                       if (decimal_value2 == 32'd2) begin
                       decimal_value_top2 <= 32'd100;
                       state_1<=5;
                       end else begin
                       state_1<=5;
                       end                                           
                    end
                    5:begin
                      if(decimal_value2>=32'd3)begin
                      decimal_value_top2 <= a*decimal_value1;
                      state_1<=6;
                      end else begin
                      state_1<=6;
                      end   
                    end
                    6:begin
                     state=fp_don;
                     state_1=0;
                    end
                    
                endcase
                end else begin
                
                
                end
             end
             
             
            fp_don:begin
              
                 case(state_1)
                     0:begin
                      if(left_first_data_out==32'd0)begin
                          don1<=32'd0;
                          gec<=0;
                          state_1=1;
                          end else begin
                          if(gec<43)begin
                          en_i_don<=1;
                          g1_i<=left_first_data_out;
                          gec<=gec+1;
                          end else begin
                          don1<=c_o;
                          gec=0;
                          state_1=1;
                          en_i_don<=0;
                          end
                      end 
                     end 
                     1:begin
                       if(left_second_data_out==32'd0)begin 
                         don2<=32'd0;                       
                         gec<=0;                            
                         state_1=2;                           
                       end else begin                       
                          if(gec<43)begin                   
                          en_i_don<=1;                      
                          g1_i<=left_second_data_out;   
                          gec<=gec+1;                       
                          end else begin                    
                          don2<=c_o;                        
                          gec=0;                            
                          state_1=2;                          
                          en_i_don<=0;                      
                          end                               
                       end                                  
                     end
                     2:begin
                        if(right_first_data_out==32'd0)begin
                         don3              <=32'd0;
                         gec               <=0;
                         state_1           <=3;
                        end else begin
                           if(gec<43)begin
                             en_i_don       <=1;
                             g1_i           <=right_first_data_out;
                             gec            <=gec+1;
                             end else begin
                             don3           <=c_o;
                             gec            <=0;
                             en_i_don       <=0;
                             state_1        <=3;
                           end
                        end 
                     end 
                     3:begin
                         if(right_second_data_out==32'd0)begin
                         don4            <=32'd0;
                         gec             <=0;
                         state_1         <=4;
                         end else begin
                             if(gec<43)begin
                             en_i_don     <=1;
                             g1_i         <=right_second_data_out;
                             gec          <=gec+1;
                             end else begin
                             don4         <=c_o;
                             gec          <=0;
                             en_i_don     <=0;
                             state_1      <=4;
                             end
                         end
                     end 
                     
                     4:begin
                          if(gec<43)begin
                            en_i_don<=1;
                            g1_i<=decimal_value_top1;
                            gec<=gec+1;
                          end else begin
                            don5<=c_o;
                            gec=0;
                            en_i_don<=0;
                            state_1=5;
                          end
                     end
                     5:begin
                        if(gec<43)begin              
                          en_i_don<=1;                 
                          g1_i<=decimal_value_top2;
                          gec<=gec+1;                  
                        end else begin               
                          don6<=c_o;                   
                          gec=0;                       
                          en_i_don<=0;                 
                          state_1=6;                     
                        end                            
                     end
                     6:begin
                     state<=combining;
                     state_1<=0;
                     end
                 endcase

             end 
             combining:begin
              case(state_1)
              0:begin
                 if(don2==32'd0||don5==32'd0)begin
                 decimal_top_s1<=32'd0;
                 gec<=0;
                 state_1<=1;
                 end else begin
                    if(gec<150)begin
                    en_i<=1;
                    a_i_top<=don2;
                    b_i_top<=don5;
                    gec<=gec+1;
                    end else begin
                    decimal_top_s1<=sonuc_o;
                    gec<=0;
                    en_i<=0;
                    state_1<=1;
                    end
                 end
              end
              1:begin
                 if(don4==32'd0||don6==32'd0)begin
                     decimal_top_s2<=32'd0;
                     gec<=0;
                     state_1=2;
                 end else begin
                     if(gec<150)begin
                         a_i_top<=don4;
                         b_i_top<=don6;
                         en_i<=1;
                         gec<=gec+1;
                     end else begin
                         decimal_top_s2<=sonuc_o;
                         gec=0;
                         state_1<=2;
                         en_i<=0;
                     end
                 end          
              end
    
              2:begin
                  if(gec<100)begin
                  en_i_toplama<=1;
                  g1_i_toplama<=don1;
                  g2_i_toplama<=decimal_top_s1;
                  gec<=gec+1;
                  end else begin
                  s1<=toplam_o;
                  gec<=0;
                  en_i_toplama<=0;
                  state_1<=3;
                  
                  end
              end
              3:begin
                 if(gec<100)begin
                 en_i_toplama<=1;
                 g1_i_toplama<=don3;
                 g2_i_toplama<=decimal_top_s2;
                 gec<=gec+1;
                 end else begin
                 s2<=toplam_o;
                 gec<=0;
                 en_i_toplama<=0;
                 state_1<=4;
                 end
              end
              4:begin

              if(process_out==32'h54)begin
              state<=topla;
              state_1<=0;
              end else if(process_out==32'd98)begin
              state<=bol;
              state_1<=0;
              end else if(process_out==32'd99)begin
              state<=carp;
              state_1<=0;
              end else begin
              state<=cikar;
              state_1<=0;
              end
              
              end  
              
               
             endcase
            end
       
       
         topla : begin
           case(state_1)
               0:begin
                          if(gec<100)begin
                          g1_i_toplama<=s1;
                          g2_i_toplama<=s2;
                          en_i_toplama<=1;
                          gec<=gec+1;
                          end else begin
                          gec=0;
                          state_1<=1;
                          en_i_toplama<=0;
                          sonuc<=toplam_o;
                          
                          end
                end
                1:begin
                state       <=sonuc_tx;
                state_1     <=0;
                end          
           endcase           
          end
           
          cikar:begin
                 case(state_1)
                     0:begin
                        if(gec<100)begin           
                        en_sub      <=1;                
                        A_i_cikarma<=s1;         
                        B_i_cikarma<=s2;         
                        gec<=gec+1;              
                        end else begin      
                        gec<=0;  
                        en_sub<=0;                  
                        state_1<=1;                
                        sonuc<=fark_out_cikarma;             
                        end
                     end
                     1:begin
                     
                       state       <=sonuc_tx;
                       state_1     <=0;
                     end
                 endcase
          end 
          carp:begin
                     case(state_1)
                        0:begin
                           if(gec<100)begin
                           en_i_carpma<=1;
                           x1_i_carpma<=s1;
                           x2_i_carpma<=s2;
                           gec<=gec+1;
                           end else begin
                           gec<=0;
                           state_1<=1;
                           en_i_carpma<=0;
                           sonuc<=sonuc_o_carpma;
                           end
                        end 
                        1:begin
                        state       <=sonuc_tx;
                        state_1     <=0;
                        
                        end
                         
                     endcase
          end
          bol:begin
               case(state_1)
                     0:begin
                           if(gec<100)begin
                           en_i<=1;
                           a_i_top<=s1;
                           b_i_top<=s2;
                           gec<=gec+1;
                           end else begin
                           gec<=0;
                           state_1<=1;
                           en_i<=0;
                           sonuc<=sonuc_o;
                           end 
                     end
                     1:begin
                       state       <=sonuc_tx;
                       state_1     <=0;
                     end
               endcase
           
          
          
          end
          
          sonuc_tx:begin
          
               case(state_1) 
                   0:begin
                      if(gec<70)begin
                      en_int_fp=1;
                      g1_int=sonuc;
                      gec<=gec+1;
                      end else begin
                      int_sonuc<=c_int;
                      gec<=0;
                      state_1<=1;
                      en_int_fp<=0;
                      end 
                   end
                   1:begin
                      if(gec<6)begin
                      binary_input<=int_sonuc;
                      gec<=gec+1;
                      end else begin
                      sonuc_point_poz<=multiplied_output;
                      gec<=0;
                      state_1<=2;
                      end            
                   end
                   2:begin
                      if(gec<44)begin           
                      en_i_don<=1;              
                      g1_i<=sonuc_point_poz;
                      gec<=gec+1;               
                      end else begin            
                      sonuc_point_poz_don<=c_o; 
                      gec<=0;                    
                      en_i_don<=0;              
                      state_1<=3;                 
                      end                       
                   end
                   3:begin
                      if(gec<100)begin                       
                      en_i_carpma=1;                     
                      x1_i_carpma<=sonuc;                
                      x2_i_carpma<=sonuc_point_poz_don;  
                      gec<=gec+1;                        
                      end else begin                      
                      sonuc_segment_fp<=sonuc_o_carpma;   
                      gec<=0;                              
                      state_1<=4;                           
                      en_i_carpma<=0;                      
                      end                                 
                   end
                   4:begin
                      if(gec<100)begin            
                      en_int_fp=1;               
                      g1_int=sonuc_segment_fp;   
                      gec<=gec+1;                
                      end else begin             
                      sonuc_segment_int<=c_int;  
                      gec<=0;                     
                      state_1<=5;                  
                      en_int_fp<=0;               
                      end                        
                   end
                   5:begin
                      transit_val <=sonuc_segment_int[15:8];
                      state_1<=6;
                   end
                   6:begin
                      transit_val1 <=sonuc_segment_int[7:0];
                      state_1<=7;
                   end
                   7:begin
                      state       <=transmitter; 
                      state_1     <=0; 
                   end
               endcase
               
          end
          
          transmitter: begin
                  case(state_1) 
                    0:begin
                    i_Tx_Byte   <= transit_val;
                    i_Tx_start  <= 1'b1;
                    state_1     <=1;
                    
                    end
                    1:begin
                       if(o_Tx_Active) begin
                       
                           i_Tx_start  <= 1'b0;
                       
                       end 
                       if(o_Tx_Done) begin
                       
                           i_Tx_start  <= 1'b0;
                           led         <= 0;
                           counter     <= 0;
                           state_1     <=0;
                           state       <= transmitter1; 
                       
                       end 
                    end
                
                  endcase
          end
          transmitter1: begin
               case(state_1) 
                     0:begin
                     i_Tx_Byte   <= transit_val1;
                     i_Tx_start  <= 1'b1;
                     state_1     <=1;
                    
                    end
                    1:begin
                       if(o_Tx_Active) begin
                       
                           i_Tx_start  <= 1'b0;
                       
                       end 
                       if(o_Tx_Done) begin
                       
                           i_Tx_start  <= 1'b0;
                           led         <= 0;
                           counter     <= 0;
                           state_1     <=0;
                           state       <= transmitter_nokta; 
                       
                       end 
                    end
                
               endcase
          end
          transmitter_nokta: begin
               case(state_1) 
                    0:begin
                    i_Tx_Byte   <= point_output;
                    i_Tx_start  <= 1'b1;
                    state_1     <=1;
                    
                    end
                    1:begin
                       if(o_Tx_Active) begin
                       
                           i_Tx_start  <= 1'b0;
                       
                       end 
                       if(o_Tx_Done) begin
                       
                           i_Tx_start  <= 1'b0;
                           led         <= 0;
                           counter     <= 0;
                           state       <= ram_write; 
                       
                       end 
                    end
                
               endcase
          end
            
        endcase
    
    end

end

ram
#(
        .data_witdh (4'b1000),
        .addr_witdh (4'b1011)
    )

RAM
    (
    
    .clk        (clk),
    .reset      (1'b0),
    .addr_in    (addr_in),
    .data_in    (data_in),
    .write_en   (write_en),
    .data_o     (data_o)
    
    );

uart_tx_t 
    #(
        .c_clkfreq  (c_clkfreq),
        .c_baudrate (c_baudrate)
    )
    uart_tx_ram
    (
        .i_clk         (clk),
        .i_Tx_start    (i_Tx_start),	
        .i_Tx_Byte     (i_Tx_Byte),
        .o_Tx_Active   (o_Tx_Active),		
        .o_Tx_Serial   (o_Tx_Serial),   
        .o_Tx_Done     (o_Tx_Done)
    );

uart_rx_t
    #(   
        .c_clkfreq   (c_clkfreq),
        .c_baudrate  (c_baudrate)     
    )
    uart_rx_ram
    (
        .i_clk          (clk),
        .i_Rx_Serial    (i_Rx_Serial),    	
        .o_Rx_done      (o_Rx_done),		
        .o_Rx_Byte 		(o_Rx_Byte)
    );
 combinee combinee_top (
  .clk                   (clk),
  .reset                 (reset),
  .address               (address),
  .data_input            (data_input),
  .write_enable          (write_enable),
  .left_first_data_out   (left_first_data_out),
  .left_second_data_out  (left_second_data_out),
  .right_first_data_out  (right_first_data_out),
  .right_second_data_out (right_second_data_out),
  .process_out           (process_out),
  .loop_done_out         (loop_done_out),
  .decimal_value1        (decimal_value1),
  .decimal_value2        (decimal_value2)    
);  
int_fp_don #(.n(32),.e(8),.m(23)) int_fp_don_top(
    .clk_i(clk),
    .rst_i(reset),
    .en_i (en_i_don),
    .g1_i (g1_i), // girilen sayi
    .c_o  (c_o) 
    );
  fp_bolme #(.n(32),.e(8),.m(23))fp_bolmex(
    .a(a_i_top) ,
    .b (b_i_top)  ,
    .clk(clk) ,
    .rst (reset) ,
    .en_i (en_i) ,
    .sonuc(sonuc_o)
    );   
fp_topla#(.b(32), .e(8), .m(23)) fp_toplama(
.clk_i(clk)   ,
.rst_i(reset)  ,
.en_i (en_i_toplama)    ,
.g1_i ( g1_i_toplama )    ,
.g2_i ( g2_i_toplama )   ,
.toplam_o (toplam_o) 
);
fp_carpma fp_carpmax(
     .clk_i   (clk) ,
     .rst_i   (reset),
     .en_i    (en_i_carpma),
     .x1_i    (x1_i_carpma),
     .x2_i    (x2_i_carpma),
     .sonuc_o (sonuc_o_carpma)
    ); 
     fp_cikarma#( .n(32), .m(23)) fp_cikarmax(
    . clk_i    (clk),
    . rst_i    (reset),
    . en_sub   (en_sub),
    . A_i      (A_i_cikarma),
    . B_i      (B_i_cikarma),
    . fark_out (fark_out_cikarma)
    );
  fp_int_don fp_int_donx(
 .clk_i(clk),
 .rst_i(reset),
 .g1_i(g1_int),
 .c_o(c_int),
 .en_int_fp(en_int_fp)
  );
    multiplier multiplierx(
  .binary_input     (binary_input)  ,
  .multiplied_output(multiplied_output),
  .point_output(point_output),
  .zero_output(zero_output),
  .clk(clk),
  .reset(reset)
);

endmodule

