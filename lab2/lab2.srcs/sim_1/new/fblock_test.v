`timescale 1ns / 1ps

module fblock_test;
    
    reg [7:0] a;
    reg [7:0] b;
    wire [15:0] result;
    
    reg clk, rst, start;
    wire busy;
    
    fblock fblock_1(
        .clk_i(clk),
        .rst_i(rst),
        .start_i(start),
        .a_i(a),
        .b_i(b),
        .busy_o(busy),
        .y_o(result)
    );
    
    always #2 clk = !clk;
    
    always @(negedge busy) begin
        if(result) begin
            start <= 0;
            $display("Result is %d", result);
            #10 $stop;
        end
    end
    
    initial begin
        rst = 1'b1;
        clk = 1'b1;
        #2
        clk = 0;
        rst = 0;
        #2
        a = 8'd255;
        b = 8'd255;
        start = 1'b1;
        clk = 1'b1;
    end
    
endmodule
