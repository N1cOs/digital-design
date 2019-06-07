`timescale 1ns / 1ps

module selftest_block_test;
    reg clk, rst, start, test;
    reg [7:0] a, b;
    
    wire busy;
    wire [7:0] result, counter;
    
    selftest_block fblock1(
        .clk_i(clk),
        .rst_i(rst),
        .start_i(start),
        .a_i(a),
        .b_i(b),
        .busy_o(busy),
        .counter_o(counter),
        .y_o(result)
    );
    
    always #10 clk = !clk;
    
    always @(negedge busy) begin
         if (start) begin
            $display("Crc is %d", result);
            $display("Counter is %d", counter);
            #10 $stop; 
         end
    end
    
    initial begin
        test <= 1;
        
        rst = 1'b1;
        clk = 1'b1;
        #10
        clk = 0;
        rst = 0;
        #10
        start = 1'b1;
        clk = 1'b1; 
    end
endmodule