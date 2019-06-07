`timescale 1ns / 1ps

module lfsr_test;
    reg clk, rst, start;
    reg[7:0] val;
    wire busy;
    wire[7:0] result;

    integer test_number;
    reg[7:0] test_data[3:0];
    reg[7:0] test_results[3:0];
    
    lfsr lfsr_t(
        .clk_i(clk),
        .rst_i(rst),
        .start_i(start),
        .init_value(val),
        .busy_o(busy),
        .y_o(result)
    );
    
    always #10 clk = !clk;
    
    always @(negedge busy) begin
        if(start) begin
            if (test_number < 4) begin
                if (result == test_results[test_number])
                    $display("Success. Value %d", result);
                else
                    $display("Wrong. Expected: %d. Value %d", test_results[test_number], result);
                test_number = test_number + 1;
            end
            else begin
                #100 $stop;
            end 
        end
    end
    
    initial begin
        test_data[0] = 13;
                
        test_results[0] = 6;
        test_results[1] = 3;
        test_results[2] = 129;
        test_results[3] = 192;
                 
        rst = 1'b1;
        clk = 1'b1;
        #10
        clk = 0;
        rst = 0;
        #10
           
        test_number = 0;
        val = test_data[0];
        start = 1'b1;
        clk = 1'b1;
    end
                     
endmodule