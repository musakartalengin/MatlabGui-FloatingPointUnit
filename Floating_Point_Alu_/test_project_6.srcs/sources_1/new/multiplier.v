`timescale 1ns / 1ps

module multiplier (
    input wire [15:0] binary_input,
    input wire clk, reset,
    output wire [31:0] multiplied_output,
    output wire [3:0] point_output,
    output wire zero_output
);

    reg [3:0] counter;
    reg [15:0] temp;
    reg [31:0] multiplier_reg;
    reg [3:0] point_reg;
    reg zero_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
    
            multiplier_reg = 32'd0;
            point_reg = 4'd0;
            zero_reg = 1'b0;
        end else begin
                // Find the number of digits
                if(binary_input==16'd0) begin
                zero_reg=1;
                 end else begin
                zero_reg=0;
                end
                
                if (binary_input < 16'd10) begin
                    multiplier_reg = 32'd1000;
                    point_reg = 4'd1;  // if it is 1 digit
                end else if (binary_input > 16'd10&&binary_input < 16'd100) begin
                    multiplier_reg = 32'd100;
                    point_reg = 4'd2; // if it is 2 digits
                end else begin
                    multiplier_reg = 32'd10;
                    point_reg = 4'd3; // if it is 3 or more digits
                end

                 // Reset the temp for the next operation
            end
        end
 

    assign multiplied_output = multiplier_reg;
    assign point_output = point_reg;
    assign zero_output = zero_reg;

endmodule


