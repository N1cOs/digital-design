`timescale 1ns / 1ps

module selftest_block_test;
    reg clk, rst, start, test;
    reg [7:0] a, b;
    
    wire busy;
    wire [8:0] result;
    wire [6:0] counter;
    
    integer i;
    
    selftest_block fblock1(
        .clk_i(clk),
        .rst_i(rst),
        .start_i(start),
        .test(test),
        .a_i(a),
        .b_i(b),
        .busy_o(busy),
        .counter_o(counter),
        .y_o(result)
    );
    
    always #10 clk = !clk;
    
    always @(negedge busy) begin
         if (test) begin
            if (i < 1) begin
                $display("Crc is %d", result);
                $display("Counter is %d", counter);
                i = i + 1;
            end
            else
                #100 $stop;
         end
    end
    
    initial begin
        i = 0;
        
        rst = 1'b1;
        clk = 1'b1;
        #10
        clk = 0;
        rst = 0;
        #10
        test = 1;
        clk = 1'b1; 
    end
endmodule
