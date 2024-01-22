`timescale 1ns / 1ps

module combinee(
    input clk,
    input reset,
    input  wire [7:0] address,
    input  wire [7:0] data_input,
    input  wire write_enable,
    output reg [31:0] left_first_data_out,  
    output reg [31:0] left_second_data_out, 
    output reg [31:0] right_first_data_out, 
    output reg [31:0]  right_second_data_out,
    output wire [31:0] process_out,   
    output wire        loop_done_out,
    output wire [31:0] decimal_value1,  
    output wire [31:0] decimal_value2             
);  
reg [7:0] memory [0:11]; // 256 byte'lýk bir bellek tanýmlýyoruz.
//reg aktif;
//reg start_combining;
integer gec=0;
integer dot_position = -1;       
integer plus_position = -1;      
integer second_dot_position = -1;
integer FF_position = -1;        
reg [31:0] left_first_side   = 32'b0; 
reg [31:0] left_second_side  = 32'b0; 
reg [31:0] right_first_side  = 32'b0; 
reg [31:0] right_second_side = 32'b0; 
reg loop_done=1'b0;
reg [4:0] state= 5'b00000;
localparam IDLE = 5'b00000, 
           SEARCH_DOT_PLUS = 5'b00001, 
           SEARCH_SECOND_DOT = 5'b00010, 
           SEARCH_FF = 5'b00011,
           COMPUTE_LEFT_FIRST = 5'b00100,
           COMPUTE_LEFT_SECOND = 5'b00101, 
           COMPUTE_RIGHT_FIRST = 5'b00110,
           COMPUTE_RIGHT_SECOND = 5'b00111,
           PROCESS_DONE = 5'b01000;

integer counter = 0;
initial 
begin
  memory[0] = 8'hFF; // 0. adres: 1
  memory[1] = 8'hFF; // 1. adres: 2
  memory[2] = 8'hFF; // 2. adres: 10
  memory[3] = 8'hFF;// 3. adres: 1
  memory[4] = 8'hFF; /// 4. adres: 3
  memory[5] = 8'hFF; /// 5. adres: 11 +
  memory[6] = 8'hFF; /// 6. adres: 3
  memory[7] = 8'hFF; //// 7. adres: 1
  memory[8] = 8'hFF; //
  memory[9] = 8'hFF; //
  memory[10] =8'hFF; //
  memory[11] =8'hFF; //
end
assign loop_done_out=loop_done;
    always @(posedge (clk) ) begin
        if (write_enable&& data_input!=8'h0D) begin
            memory[address] <= data_input;
        end
    end
    
  always @(posedge clk or posedge reset) begin
   if (reset) begin
        state <= IDLE;
        counter <= 0;
        dot_position <= -1;
        plus_position <= -1;
        second_dot_position <= -1;
        FF_position <= -1;
        left_first_side <= 32'b0;
        left_second_side <= 32'b0;
        right_first_side <= 32'b0;
        right_second_side <= 32'b0;
        loop_done <= 1'b0;
    end else begin
        case(state)
            IDLE: begin
                if (data_input==8'h0d) begin
                    state <= SEARCH_DOT_PLUS;
                end
            end
            SEARCH_DOT_PLUS: begin
                if (counter <= 11) begin
                    if (memory[counter] == 8'd46 && dot_position == -1) begin
                        dot_position <= counter;
                    end else if (memory[counter] == 8'd84||memory[counter] == 8'd99||memory[counter] == 8'd98||memory[counter] == 8'd115) begin
                        plus_position <= counter;
                    end
                    counter <= counter + 1;
                end else begin
                    counter <= 0;
                    state <= SEARCH_SECOND_DOT;
                end
            end
            SEARCH_SECOND_DOT: begin
                if (counter <= 11) begin
                    if (memory[counter] == 8'd46&& counter != dot_position) begin
                        second_dot_position <= counter;
                    end
                    counter <= counter + 1;
                end else begin
                    counter <= 0;
                    state <= SEARCH_FF;
                end
            end
            SEARCH_FF: begin
                if (counter <= 11) begin
                    if (memory[counter] == 8'hFF && FF_position==-1) begin
                        FF_position <= counter;
                        counter <= 12;
                    end
                    counter <= counter + 1;
                end else begin
                    counter <= 0;
                    state <= COMPUTE_LEFT_FIRST;
                end
            end
            COMPUTE_LEFT_FIRST: begin
                if (counter < dot_position) begin
                    left_first_side <= left_first_side * 10 + memory[counter];
                    counter = counter + 1;
                end else begin
                    counter <= dot_position + 1;
                    state <= COMPUTE_LEFT_SECOND;
                end
            end
            COMPUTE_LEFT_SECOND: begin
                if (counter < plus_position) begin
                    left_second_side <= left_second_side * 10 + memory[counter];
                    counter <= counter + 1;
                end else begin
                    counter <= plus_position + 1;
                    state <= COMPUTE_RIGHT_FIRST;
                end
            end
            COMPUTE_RIGHT_FIRST: begin
                if (counter < second_dot_position) begin
                    right_first_side <= right_first_side * 10 + memory[counter];
                    counter <= counter + 1;
                end else begin
                    counter <= second_dot_position + 1;
                    state <= COMPUTE_RIGHT_SECOND;
                end
            end
            COMPUTE_RIGHT_SECOND: begin
                if (counter != FF_position && counter <= 11) begin
                    right_second_side <= right_second_side * 10 + memory[counter];
                    counter <= counter + 1;
                end else begin
                    counter <= FF_position + 1;
                    state <= PROCESS_DONE;
                end
            end
            PROCESS_DONE: begin
                    counter <= 0;
                    loop_done <= 1'b1;
                    left_first_data_out <= left_first_side;
                    left_second_data_out <= left_second_side;
                    right_first_data_out <= right_first_side;
                    right_second_data_out <= right_second_side;
            end
        endcase
    end
 
end

 assign process_out=memory[plus_position];
 assign decimal_value1=(plus_position-dot_position)-1;
 assign decimal_value2=(FF_position-second_dot_position)-1;
endmodule
