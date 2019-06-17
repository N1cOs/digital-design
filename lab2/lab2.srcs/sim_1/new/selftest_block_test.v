`timescale 1ns / 1ps

module selftest_block_test;
    reg clk, rst, start, test, is_test, was_start;
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
         if (is_test) begin
            if (i < 1) begin
                $display("----------------------------------Test results----------------------------------");
                $display("Crc is %d", result);
                $display("Counter is %d", counter);
                i = i + 1;
                if (result == 65)
                    $display("Result is correct"); 
                else
                    $display("Result is incorrect. Expected %d. Computed %d", 65, result);
                
                a = 255;
                b = 255;
                start = 1;
                if (was_start) begin
                    $display("----------------------------------End----------------------------------");
                    #100 $stop;
                end
            end
            else if (start) begin
                $display("----------------------------------User input results----------------------------------");
                $display("Result is %d", result);
                $display("Counter is %d", counter);
                if (result == 360)
                    $display("Result is correct"); 
                else
                    $display("Result is incorrect. Expected %d. Computed %d", 360, result);
                
                start = 0;
                was_start = 1;
                 
                i = 0;
                test = 1;
                #100
                test = 0;
            end
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
        is_test = 1;
        clk = 1'b1;
        #100
        test = 0;
    end
endmodule
