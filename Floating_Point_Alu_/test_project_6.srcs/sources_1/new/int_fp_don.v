`timescale 1ns / 1ps



module int_fp_don(clk_i,rst_i,g1_i,c_o,en_i);
    parameter n=32, e=8,m=23;
    input clk_i,rst_i;
    input en_i;
    input  [31:0] g1_i; // girilen sayi
    output [n-1:0] c_o;  // cikis
    reg [n-1:0] s1,cik1; // s1 => giris icin / cik1=> cikis icin
    reg [e-1:0] E1;  // exponent
    reg [n-1:0] M1;  // mantisa 
    reg [m-1:0] M2; // mantisa kaydirilmasi ile
    reg sign;
    reg [3:0] durum=3'b000;
    integer  x=0,us=0,say=0,i=1'b0,us2,r1=n,k1,bias=(2**(e-1))-1; 
    assign c_o = cik1; 
   
    always@(posedge(clk_i))begin
            if(rst_i)begin
                s1=32'h00000000;
                durum=3'b00;
                say=0;
                us2=0;
                us=0;
                k1=0;
                E1=0;
                i=1'b0;
            end else begin
                if(en_i == 1)begin // ise �al��
                    x = x +1; // durum 3te sifirla
                    case(durum)
                        0:begin 
                            if(x<=3) begin // 3 clock bekle
                                s1=g1_i;  
                                sign=s1[n-1];
                                if(s1[31]==1)begin // 2ye tumleyen alma 
                                    s1=~s1;
                                    s1=s1+1;
                                end 
                                if(s1==32'h00000000) begin // girilen sayinin 0 olmasi durumunda yanl�� �al���yordu
                                    cik1 = 32'h00000000;
                                    
                                end
                                
                            end else begin
                                durum=1; 
                            end
                        end
                        1:begin
                            // �s � hesaplama / burda optimize et soldan saymaya ba�la 1 e kadar
                            if(say<=n-1)begin
                                if(s1[i]==1'b1)begin
                                    i=i+1;
                                    us=i; // 1
                                    say=say+1;
                                end else begin
                                    i=i+1;
                                    say=say+1; // 31
                                end
                            end else begin
                                durum=2;      
                            end       
                        end  
                        2: begin
                            us2=us-1;
                            durum = 3;
                        end
                         // önceki kodda durum 2-3-4-5-6 ayn. durum icerisindeydi ayirdim
                       3:begin
                            k1=r1-us2;
                            E1=bias+us2;
                            durum = 4;
                       end
                       4:begin
                            M1[n-1:0]=s1<<k1; 
                            durum = 5;
                       end
                       5:begin
                            M2=M1[n-1:n-m];  
                            durum = 6;
                       end
                       // tekrar tekrar bu islemleri yapabilmesi icin
                       6:begin
                            cik1 = {sign,E1,M2};
                            durum = 7;
                       end
                       // geri donus icin durum yedide sifirlanmasi gereken degerler is�f�rlay�p durum 0 a gonderdim / s�f�rlanmazsa �zerien i�lemleri yap�yor gibiydi
                       7:begin
                            s1<=32'h00000000;
                            say<=0;
                            us2<=0;
                            us<=0;
                            k1<=0;
                            E1<=0;
                            i<=0;
                            E1 <= 0;
                            M2 <= 0;
                            x <= 0;
                            durum <= 0;
                       end
                    endcase
                end else begin
                    x = 0;
                    durum = 0;
                end
            end
        end
        
    
endmodule
