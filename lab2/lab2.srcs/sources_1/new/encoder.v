module encoder(
    input a0,
    input a1,
    input a2,
    input a3,
    input a4,
    input a5,
    input a6,
    input a7,
    output y0,
    output y1,
    output y2 
    );
    
    wire not_a1, not_a2, not_a3, not_a4,
         not_a5, not_a6, not_a7;

    nand(not_a1, a1, a1);
    nand(not_a2, a2, a2);
    nand(not_a3, a3, a3);
    nand(not_a4, a4, a4);
    nand(not_a5, a5, a5);
    nand(not_a6, a6, a6);
    nand(not_a7, a7, a7);
    
    nand(y0, not_a1, not_a3, not_a5, not_a7);
    nand(y1, not_a2, not_a3, not_a6, not_a7);
    nand(y2, not_a4, not_a5, not_a6, not_a7);
     
endmodule
