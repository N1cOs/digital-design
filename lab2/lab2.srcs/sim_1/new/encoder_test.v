`timescale 1ns / 1ps

module encoder_test;
    reg a0, a1, a2, a3,
        a4, a5, a6, a7;
    wire y0, y1, y2;
    
    encoder encoder_1(
        .a0(a0),
        .a1(a1),
        .a2(a2),
        .a3(a3),
        .a4(a4),
        .a5(a5),
        .a6(a6),
        .a7(a7),
        .y0(y0),
        .y1(y1),
        .y2(y2)
    );
    
    reg [0:7] test_val;
    reg [0:2] expected_val;
    reg res0, res1, res2;

    integer i;
    integer j = 0;
    initial begin
        for(i = 128; i > 0; i = i / 2) begin
            test_val = i;
            a0 = test_val[0];
            a1 = test_val[1];
            a2 = test_val[2];
            a3 = test_val[3];
            a4 = test_val[4];
            a5 = test_val[5];
            a6 = test_val[6];
            a7 = test_val[7];
            
            expected_val = j;
            res0 = expected_val[2];
            res1 = expected_val[1];
            res2 = expected_val[0];
            
            #10
            
            if(y0 == res0 && y1 == res1 && y2 == res2) begin
                $display("The encoder output is correct: a0=%b, a1=%b, a2=%b, a3=%b, a4=%b, a5=%b, a6=%b, a7=%b, y0=%b, y1=%b,y2=%b", 
                a0, a1, a2, a3, a4, a5, a6, a7, y0, y1, y2);
            end else begin
                $display("The encoder output is wrong: a0=%b, a1=%b, a2=%b, a3=%b, a4=%b, a5=%b, a6=%b, a7=%b, y0=%b, y1=%b,y2=%b", 
                a0, a1, a2, a3, a4, a5, a6, a7, y0, y1, y2);
            end
            j = j + 1;
        end
    #10 $stop;
    end                  
endmodule
