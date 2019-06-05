`timescale 1ns / 1ps

module crc8_test;
    reg clk, rst, start;
    reg [8:0] a;
    
    wire busy;
    wire [7:0] result;
    
    integer test_number;
    reg [8:0]test_data[9:0];
    
    crc8 crc8_1(
        .clk_i(clk),
        .rst_i(rst),
        .start_i(start),
        .a_i(a),
        .busy_o(busy),
        .y_o(result)
    );
    
    always #10 clk = !clk;
    
    always @(negedge busy) begin
        if (test_number < 10) begin 
            test_number = test_number + 1;
            a = test_data[test_number];
        end
        else if(test_number) begin
            if (result == 85)
                $display("Result is correct %d", result);
            else
                $display("Result is incorrect. Expected: $d. Value: %d", 85, result);
            #10
            $stop; 
        end
    end
    
    initial begin
        test_data[0] = 137;   
        test_data[1] = 68;   
        test_data[2] = 207;   
        test_data[3] = 283;   
        test_data[4] = 246;   
        test_data[5] = 212;   
        test_data[6] = 225;   
        test_data[7] = 112;   
        test_data[8] = 151;   
        test_data[9] = 252;
        
        rst = 1'b1;
        clk = 1'b1;
        #10
        clk = 0;
        rst = 0;
        #10
        a = test_data[0];
        test_number = 0;
        
        start = 1'b1;
        clk = 1'b1;
    end
endmodule
