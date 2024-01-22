`timescale 1ns / 1ps

module fp_carpma(
    input clk_i,rst_i,en_i,
    input [31:0] x1_i,x2_i,
    output [31:0] sonuc_o
    );
    
    reg [31:0] say_x1,say_x2;
    reg sign_1, sign_2;
    reg sign;
    reg [7:0] exp_1,exp_2;
    reg [7:0] exp;
    reg [23:0] man_1,man_2;
    reg [22:0] man;
    reg [47:0] man_ara=0;
    reg [3:0] durum=0;
    integer sayac=0, say_ic=24;
    reg [31:0] snc;
    assign sonuc_o = snc;
    
    always @(posedge clk_i) begin
        if (rst_i) begin
            sign=0;
            man=0;
            exp=0;
            durum=0;
            say_ic=24;
        end
        else begin 
            if(en_i==1)begin
                sayac=sayac+1;
                case (durum)
                    0:begin
                        if(sayac <=3)begin
                            if(x1_i == 0 || x2_i == 0)begin
                                durum = 5;
                            end else begin 
                                say_x1=x1_i;
                                say_x2=x2_i;
                                sign_1=say_x1[31];
                                sign_2=say_x2[31];
                                exp_1=say_x1[30:23];
                                exp_2=say_x2[30:23];
                                man_1[22:0]=say_x1[22:0];
                                man_2[22:0]=say_x2[22:0];
                                
                                sign = sign_1  ^  sign_2;
                                
                                exp = exp_1 + exp_2  - 8'b0111_1111;
                                
                                man_1[23]={1'b1};
                                man_2[23]={1'b1};
                            end
                            
                            
                        end else begin
                            durum=1;
                        end
                    end
                    
                    1:begin              
                        man_ara=man_ara << 1;
                        say_ic = say_ic - 1;
                        durum=2;
                    end
                    
                    2:begin
                        if (man_2[say_ic]==1) begin
                            man_ara = man_ara +  man_1;
                            durum=3;
                        end
                        else begin
                            durum=3; 
                        end     
                    end 
                    
                    3:begin
                        if (say_ic != 0) begin
                            durum=1;
                        end
                        else begin
                            durum=4; 
                        end
                    end  
        
                    4:begin
                        if(man_ara[47] == 0)begin
                            man_ara = man_ara << 2 ;
                            man = man_ara[47:25]; 
                            durum = 5;
                        end
                        else begin
                            man_ara = man_ara << 1 ;
                            man = man_ara[47:25];
                            exp = exp + 1'b1;
                            durum = 5;
                        end  
                    end
                    5:begin
                        if(x1_i == 0 || x2_i == 0)begin 
                            snc = 0;
                            durum = 6;
                        end else begin
                            snc = {sign,exp,man};
                            durum = 6;
                        end
                    end
                    6:begin
                        sign_1 = 0;
                        sign_2 = 0;
                        sign = 0 ;
                        say_x1 = 0;
                        say_x2 = 0;
                        man_1 = 0;
                        man_2 = 0;
                        man = 0;
                        man_ara = 0;
                        exp_1 = 0;
                        exp_2 = 0;
                        exp = 0;
                        say_ic=24;
                        sayac = 0;
                        durum = 0;
                    end
                endcase    
            end else begin
                sign_1 = 0;
                sign_2 = 0;
                sign = 0 ;
                say_x1 = 0;
                say_x2 = 0;
                man_1 = 0;
                man_2 = 0;
                man = 0;
                man_ara = 0;
                exp_1 = 0;
                exp_2 = 0;
                exp = 0;
                say_ic=24;
                sayac = 0;
                durum = 0;
            end
            
        end     
    end


endmodule
