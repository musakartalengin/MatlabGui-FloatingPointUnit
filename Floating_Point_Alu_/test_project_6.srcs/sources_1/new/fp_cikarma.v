`timescale 1ns / 1ps

module fp_cikarma#(parameter n=32, m = 23)(
    
    input clk_i,
    input rst_i,
    input en_sub,
    input [n-1:0] A_i, B_i,
    output[n-1:0] fark_out
    );
    
    reg [3:0] durum=4'b0000;
    reg s_A, s_B, sign;
    reg [n-2:m] e_A, e_B, exp_fark, exp;
    reg [m:0] m_A, m_B; // 24 bit 1 bit ile birleştirildiğinde 
    reg [m:0] man;
    reg [n-1:0] fark_o;
    reg [m+1:0] man_s; // 25 bit 
    reg elde;
    integer x = 0; // sayaç
    
    always @(posedge (clk_i))begin
        if(rst_i) begin
            man = 0;
            man_s= 0;
        end 
        else begin
           if(en_sub == 1) begin      
               x = x+1;          
               case(durum)
                   0:  begin     
                       if(x<=3)begin
                            if(A_i == B_i) begin
                                fark_o = 0; // iki sayı birbirine eşitse sonuç 0 dır
                            end else begin
                                 s_A = A_i [n-1];
                                 s_B = B_i [n-1];
                                 e_A = A_i [n-2:m];
                                 e_B = B_i [n-2:m];
                                 m_A = {1'b1, A_i [m-1:0]};
                                 m_B = {1'b1, B_i [m-1:0]};
                                
                            end
                       end else begin
                             durum = 4'b0001;
                       end
                   end
                   1:  begin
                        if (e_A > e_B) begin
                            sign = s_A;
                            exp_fark = e_A - e_B; 
                            e_B = e_B + exp_fark;
                            m_B = m_B >> exp_fark;
                            exp = e_A+1;
                            durum = 4'b0100;
                       end
                       else begin
                           durum = 4'b0010;
                      end
                     end 
                   2:  begin 
                       if(e_A < e_B) begin
                           sign = ~s_B;
                           exp_fark = e_B - e_A;
                           e_A = e_A + exp_fark;
                           m_A = m_A >> exp_fark;
                           exp = e_B+1; 
                           durum = 4'b0101;
                          end 
                        else begin
                            durum = 4'b0011;
                          end 
                       end
                       
                   3:   begin
                        if(m_A>=m_B) begin // büyük eşit olması gerekli
                              sign = s_A;
                              exp = e_A+1;
                              durum = 4'b0100;
                        end
                        else begin
                           sign = ~s_B;
                           exp = e_B+1;
                           durum = 4'b0101;
                        end                    
                         
                     end
                         
                   4:  begin
                       {elde,man} = m_A - m_B;
                        man_s = {elde,man};
                        
                        durum = 4'b0110;
                       end    
                       
                   
                   5: begin 
                        {elde,man} = m_B - m_A;
                         man_s = {elde,man};
                                         
                         durum = 4'b0110;
                        
                      end     
                   6: begin 
                    
                         if (man_s[m+1] == 0) begin
                              man_s = man_s << 1;
                              exp = exp - 1'b1;
                              durum = 4'b0110;
                              end      
                              else 
                                            
                        durum = 4'b0111;
                        
                       end
                    7: begin
                        fark_o = {sign, exp, man_s[m:1]}; 
                        durum = 8;
                    end
                    8:begin
                        man = 0;
                        man_s = 0;
                        e_A = 0;
                        e_B = 0;
                        exp_fark = 0;
                        exp = 0;
                        m_A = 0;
                        m_B = 0;
                        elde = 0;
                        x = 0;
                        durum = 0; //  başa dönecek 
                    end
               endcase
           end else begin 
                x = 0;
                durum = 0;
           end 
        end
    end
     assign fark_out=fark_o;
endmodule
