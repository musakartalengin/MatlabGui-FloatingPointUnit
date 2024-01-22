`timescale 1ns / 1ps

module ram
   #(
        parameter data_witdh = 4'b1000,
        parameter addr_witdh = 4'b1000
    )
    (
    
    input   wire                        clk,
    input   wire                        reset,
    input   wire    [data_witdh-1:0]    addr_in,
    input   wire    [data_witdh-1:0]    data_in,
    input   wire                        write_en,
    output  reg     [data_witdh-1:0]    data_o
    
    );
    
    reg [data_witdh - 1:0] ram [0:addr_witdh];
    initial begin
    ram[0]=8'hff;
    ram[1]=8'hff;
    ram[2]=8'hff;
    ram[3]=8'hff;
    ram[4]=8'hff;
    ram[5]=8'hff;
    ram[6]=8'hff;
    ram[7]=8'hff;
    ram[8]=8'hff;
    ram[9]=8'hff;
    ram[10]=8'hff;
    ram[11]=8'hff;
    
    
    end
    
    always@(posedge clk) begin
    
        if(reset) begin
        
            data_o <= 0;
        
        end else begin
        
            if(write_en) begin
            
                ram[addr_in]    <= data_in;
            
            end else begin
            
                data_o          <= ram[addr_in];
            
            end
        
        end
    
    end
    
endmodule