`timescale 1ns / 1ps

module sqrt_test;
    reg[16:0] a;
    reg clk, rst, start;
    
    wire busy;
    wire [15:0] res;
    
    sqrt sqrt_1(
        .clk_i(clk),
        .rst_i(rst),
        .start_i(start),
        .a_i(a),
        .busy_o(busy),
        .y_o(res)
    );
    
    initial begin
        rst = 1'b1;
        clk = 1'b1;
        #1
        clk = 0;
        rst = 1'b0;
        
        a = 17'd1024;
        start = 1'b1;
        #1
        clk = 1'b1;
        #1
        clk = 0;
        #1
        clk = 1'b1;
        #1
        clk = 0;
        while(busy) begin
            #2 clk = !clk;
        end   
        $display("Result is %d", res);
        #10 $stop;       
    end
   
endmodule
