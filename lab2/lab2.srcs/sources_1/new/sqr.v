module sqr(
    input clk_i,
    input rst_i,
    input start_i,
    
    input [7:0] a_i,
    
    output busy_o,
    output [15:0] y_o
    );
    
    mult mult_1(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .a_bi(a_i),
        .b_bi(a_i),
        .start_i(start_i),
        .busy_o(busy_o),
        .y_bo(y_o)
   );
endmodule
