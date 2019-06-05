module lfsr(
    input clk_i,
    input rst_i,
    input start_i,
    input [7:0] init_value,
    
    output busy_o, 
    output reg [7:0] y_o
    );
endmodule
