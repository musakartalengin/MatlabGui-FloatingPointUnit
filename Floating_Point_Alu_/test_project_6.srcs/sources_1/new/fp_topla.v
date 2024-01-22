`timescale 1ns / 1ps

module fp_topla#(parameter b=32, e=8, m=23)(
    
    input clk_i,rst_i,en_i,
    input [b-1:0] g1_i,g2_i,
    output [b-1:0] toplam_o);
    
    
    reg [m+1:0] B; 
    reg [m:0] C;               
    reg t_sign;                      
    reg [m:0] Nxm;
    reg [m:0] Nym;
    reg [b-1:0] x,y;
    integer ex_x,ex_y;
    reg [b-2:m] sonus;
    reg[m-1:0] sonmantis;
    reg [b-1:0] Ntoplam;
    integer Nus;
    integer tpsus;
    reg [2:0] durum = 3'b000;
    integer uscikarmax=0;
    integer uscikarmay=0;
    wire [m:0] x_mantissa = {1'b1,g1_i[m-1:0]};
    wire [m:0] y_mantissa = {1'b1,g2_i[m-1:0]};
    integer sayac= 0;
    reg [b-1:0]sonuc;
    
    assign toplam_o = sonuc;
    
    
    always @(posedge(clk_i))begin
        if(rst_i)begin
            durum = 2'b00;
            x=32'd0;
            y=32'd0;
        end
        else begin
            if(en_i == 1) begin
                sayac = sayac + 1;
                case(durum)
                    0:begin //sayýlar karþýlaþtýrýlarak sign bitine karar verilir
                       if(sayac<=3)begin    
                           x=g1_i;
                           y=g2_i;
                           ex_x=x[b-2:m];
                           ex_y=y[b-2:m];
                            if(x[b-1]== y[b-1])begin
                                t_sign = x[b-1];
                            end
                            else if(x[b-1]!=y[b-1]) begin
                                if(x[b-2:m] > y[b-2:m])begin
                                    t_sign = x[b-1];
                                end 
                                if(y[b-2:m] > x[b-2:m])begin
                                    t_sign = y[b-1];
                                end
                                else if(x[b-2:m] == y[b-2:m])begin
                                    if(x[m-1:0]>y[m-1:0])begin
                                        t_sign = x[b-1];
                                    end
                                    if(y[m-1:0]>x[m-1:0])begin
                                        t_sign = y[b-1];
                                    end
                                end
                            end
                        end else begin
                            durum=1;
                        end
                    end
                    1:begin  //üsler karþýlaþtýrýlarak mantissalar ayarlanýr
                       x=g1_i;
                       y=g2_i;
                        if(ex_x==ex_y)begin
                            Nus=ex_x; 
                            Nym[m:0] = y_mantissa;
                            Nxm[m:0] = x_mantissa;    
                        end
                        else if(ex_x>ex_y)begin
                                uscikarmax=ex_x-ex_y;
                                Nus = ex_y+ uscikarmax;
                                Nym[m:0] = y_mantissa >> uscikarmax; 
                                Nxm[m:0] = x_mantissa;
                                
                        end
                        else begin
                                uscikarmay=ex_y-ex_x;
                                Nus = ex_x+ uscikarmay;
                                Nxm[m:0] = x_mantissa >> uscikarmay;
                                Nym[m:0] = y_mantissa;
                              
                                
                        end
                        durum = 2;
                        
                    end 
                    2:begin // mantissalar toplanýp toplam mantis bulunur ve üs kaydýrýlýr
                       x=g1_i;
                       y=g2_i;       
                        if(x[b-1]==y[b-1])begin
                                B=Nxm[m:0]+Nym[m:0];
                                if(B==B[m+1:0])begin
                                    sonmantis = B[m:1];
                                    tpsus = Nus + 1;  
                                end
                                if(B==B[m:0])begin
                                    sonmantis = B[m:0];
                                    tpsus =Nus; 
                                end
                        end         
                            durum=3;
                        if(x[b-1]!=y[b-1])begin   // çýkartma algoritmasý olduðu için çalýþmýyor
                                C=Nxm[m:0]-Nym[m:0];
                                if(C==C[m:0])begin
                                    sonmantis = C[m-1:0];
                                    tpsus =Nus-1; 
                                end
                        end
                        durum=3;          
                    end
                    3:begin  //sonuc aktarýlýr.
                       x=g1_i;
                       y=g2_i;
                       sonuc = {t_sign,tpsus[e-1:0],sonmantis[m-1:0]};  
                       durum = 4;
                    end   
                    4:begin 
                        x = 0;
                        y = 0;
                        ex_x = 0;
                        ex_y = 0;
                        uscikarmax = 0;
                        uscikarmay = 0;
                        Nus = 0;
                        Ntoplam = 0;
                        sonmantis = 0;
                        B = 0;
                        C = 0;
                        Nxm = 0;
                        Nym = 0;
                        sonus = 0;
                        t_sign = 0;
                        tpsus = 0;
                        durum = 0;
                        sayac = 0;
                    end
                   
                endcase
            end else begin
                x = 0;
                y = 0;
                ex_x = 0;
                ex_y = 0;
                uscikarmax = 0;
                uscikarmay = 0;
                Nus = 0;
                Ntoplam = 0;
                sonmantis = 0;
                B = 0;
                C = 0;
                Nxm = 0;
                Nym = 0;
                sonus = 0;
                t_sign = 0;
                tpsus = 0;
                durum = 0;
                sayac = 0;
            end
        end
    end
endmodule
