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
    
//    always #5 clk = !clk;
    
//    always @(posedge clk) begin
//        if(!start) begin
//            a <= 8'd19;
//            b <= 8'd23;
//            start <= 1'b1;
//        end
//        else if(!busy) begin
//            start <= 0;
//            $display("Result is %d", result);
//            #10 $stop;
//        end
//    end
    
    initial begin
        rst = 1'b1;
        clk = 1'b1;
        #1
        clk = 0;
        rst = 1'b0;
        
        a = 8'd19;
        b = 8'd23;
        start = 1'b1;
        clk = 1'b1;
        #1
        clk = 0;
        #1
        clk = 1'b1;
        #1
        clk = 0;
        while(busy) begin
            #5 clk = !clk;
        end   
        $display("Result is %d", result);
        #10 $stop;
    end
    
endmodule
