`timescale 1ns / 1ps

module fblock_test;
    
    reg [7:0] a;
    reg [7:0] b;
    wire [15:0] result;
    
    reg clk, rst, start;
    wire busy;
    
    integer test_number, i;
    reg [7:0]test_data_a[9:0];
    reg [7:0]test_data_b[9:0];
    reg [15:0]test_results[9:0];
    
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
        if (test_number < 10) begin
            if (result == test_results[test_number])
                $display("The block output is correct: a=%d, b=%d, result=%d", test_data_a[test_number], 
                    test_data_b[test_number], test_results[test_number]);
            else
                $display("The block output is wrong: a=%d, b=%d, result=%d", test_data_a[test_number], 
                    test_data_b[test_number], result);
            
            test_number = test_number + 1;
            if (test_number == 10) begin
                a = 0;
                b = 0;
                #10 $stop;
            end else begin
                a = test_data_a[test_number];
                b = test_data_b[test_number];
            end
        end
    end
    
    initial begin
        test_data_a[0] = 0;
        test_data_b[0] = 0;
        test_results[0] = 0;
        
        test_data_a[9] = 255;
        test_data_b[9] = 255;
        test_results[9] = 360;
        
        for(i = 1; i < 9; i = i + 1) begin
            test_data_a[i] = 3 * i * i + 7;
            test_data_b[i] = 13 * i + 11;
            test_results[i] = func(test_data_a[i], test_data_b[i]);
        end 
        
        
        rst = 1'b1;
        clk = 1'b1;
        #2
        clk = 0;
        rst = 0;
        #2
        
        a = test_data_a[0];
        b = test_data_b[0];
        test_number = 0;
        
        start = 1'b1;
        clk = 1'b1;
    end
    
    function [15:0] sqrt;
        input [16:0] a;
        reg [15:0] res;
        reg [16:0] m;
        reg [16:0] b;
        begin
            m = 17'h10000;
            res = 0;
            
            while(m != 0) begin
                b = res | m;
                res = res >> 1;
                
                if (a >= b) begin
                    a = a - b;
                    res = res | m;
                end
                m = m >> 2;
            end
            sqrt = res;
        end
    endfunction
    
    function [15:0] func;
        input [7:0] a;    
        input [7:0] b;
        begin
            func = sqrt(a * a + b * b);
        end    
     endfunction    
endmodule
