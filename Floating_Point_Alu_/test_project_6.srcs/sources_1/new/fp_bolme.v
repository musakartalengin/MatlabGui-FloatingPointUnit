`timescale 1ns / 1ps

module fp_bolme(a,b,clk,rst,sonuc,en_i);
    parameter n=32;
    parameter e=8;
    parameter m=23;
    input [n-1:0]a,b;
    input clk,rst,en_i;
    output [n-1:0]sonuc;
    
    integer syca,sycb,min,say_ic1=0,say_ic2=0,say_dis=0,say_bol=m,say_ica=0,say_icb=0,durum1,durum2; //integer 32 bit yer tutar
    reg [2:0] durum=0;
    reg [e-1:0]bias;
    reg s3;
    reg sa,sb;
    reg [n-1:0] ax,sx,bx;
    reg [e-1:0] us2;
    reg [m:0] kalan,bolum;
    reg [m-1:0] bolumson;
    reg [m:0] rma,rmb; //rma,rmb bilimsel formattaki mantissa
    
    reg  [e-1:0] ea,eb;
    reg [m-1:0] ma,mb;
    
    assign sonuc=sx;
    always@(posedge(clk))begin
        if (rst) begin
                ax=0;bx=0;sx=0;
                say_ic1=0;say_dis=0;
            end
        else begin
          if(en_i==1) begin
            say_dis=say_dis+1;
            case(durum)
                0:begin
                    bx=b;
                    ax=a;
                    sa= ax[n-1]; //sign bitleri alýnýr
                    sb= bx[n-1];
                    ea=ax[n-2:m];  //exponent alýnýr
                    eb=bx[n-2:m];
                    ma=ax[m-1:0]; //mantissalar alýnýr
                    mb=bx[m-1:0];
                    s3=sa^sb;  
                    us2=ea-eb;
                    rma={1'b1,ma}; //mantissanýn sol tarafýna bit eklenir. bitin deðeri 1dir. bilimsel formatta olur
                    rmb={1'b1,mb};
                    durum=1;
                end
                1:begin  //max saða kaydýrma iþlemi yapýlabilsin diye her iki sayýda da saðdan bakýlýnca ilk 1 bakýlýr
                    if(rma[say_ica]==0 && durum2==0)begin
                        say_ica=say_ica+1;
                    end
                    else begin
                        syca=say_ica; //0 sayýsýný tutar  
                        durum1=1;
                    end
                    
                    if(rmb[say_icb]==0 && durum1==0)begin 
                        say_icb=say_icb+1;
                    end
                    else begin
                        sycb=say_icb;
                        durum2=1;
                    end
                    
                    if(durum1==1 || durum2==1)begin /////////////
                        min=syca; 
                        durum=2;
                    end
                    else begin
                        durum=1;
                    end
                end
                2:begin
                     if(say_ic1==min)begin 
                            durum=3;
                        end
                        else begin 
                            say_ic1=say_ic1+1;
                            rma=rma>>1;   //shift left
                            rmb=rmb>>1;
                        end
                end
                3:begin
                    if(say_bol>=0)begin //bolum deðiþkeninin bitlerini dolaþýp deðer vermesi için say_bol kullanýldý.
                        kalan=rma-rmb;               //23ten baþlatýldý
                        if(kalan==0)begin  //kalan 0 olduðunda durumu
                            bolum[say_bol]=1;
                            rma=kalan;
                        end
                        else if(kalan[m]==0) begin //1, olma durumu
                            bolum[say_bol]=1; 
                            rma=kalan;
                            rma=rma<<1;
                        end
                        else begin 
                            bolum[say_bol]=0;
                            rma=rma<<1;          
                        end
                    end
                    else begin
                        durum=4;
                    end
                    say_bol=say_bol-1;
                end
                    
                4:begin
                    if(bolum[m]==0)begin  //0, ise bilimsele çevrilir us azalýr
                        bolum=bolum<<1;
                        bolumson=bolum[m-1:0];  
                        us2=us2-1;     
                        durum=5;         
                    end
                    else begin
                        bolumson=bolum[m-1:0];
                        durum=5;
                    end
                end
                5:begin
                     bias=(2**(e-1))-1;
                     us2=us2+bias;
                    durum=6;
                end
                                                              
                6:begin
                    sx={s3,us2,bolumson};
                end
                7:begin
                        bx=0;ax=32'h00000000;sa=0;sb=0;ea=0;eb=0;ma=0;mb=0;s3=0;us2=0;rma=0;rmb=0;
                        say_ic1=0;say_ic2=0;say_bol=m;say_ica=0;say_icb=0;
                        durum = 0;
                        say_dis=0;
                end
            endcase
            end else begin
                    durum = 0;
                    say_dis=0;
            end
        end 
      end
endmodule
