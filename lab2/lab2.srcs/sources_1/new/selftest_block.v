module selftest_block(
    input clk_i,
    input rst_i,
    input start_i,
    input test,
    
    input [7:0] a_i,
    input [7:0] b_i,
    
    output busy_o,
    output reg [7:0] counter_o,
    output reg [8:0] y_o
    );
    
    localparam INIT_A = 8'd19;
    localparam INIT_B = 8'd23;
    
    localparam IDLE = 3'd0;
    localparam MODE = 3'd1;
    localparam USER_INPUT = 3'd2;
    localparam TEST_INIT = 3'd3;
    localparam GENERATING = 3'd4;
    localparam FBLOCK = 3'd5;
    localparam CRC = 3'd6;
    
    reg [2:0] state;
    
    reg rst_fblock, rst_lfsr_a, rst_lfsr_b, rst_crc8;
    reg start_fblock, start_lfsr_a, start_lfsr_b, start_crc8;
    
    reg [8:0] result_fblock;
    reg [7:0] result_lfsr_a, result_lfsr_b, result_crc8, a, b, iter_c;
     
    wire busy_fblock, busy_lfsr_a, busy_lfsr_b, busy_crc8;
    
    
    fblock fblock_1(
        .clk_i(!clk_i),
        .rst_i(rst_fblock),
        .start_i(start_fblock),
        .a_i(a),
        .b_i(b),
        .busy_o(busy_fblock),
        .y_o(result_fblock)
    );
    
    lfsr lfsr_a(
        .clk_i(!clk_i),
        .rst_i(rst_lfsr_a),
        .start_i(start_lfsr_a),
        .init_value(INIT_A),
        .busy_o(busy_lfsr_a),
        .y_o(result_lfsr_a)
    );
    
    lfsr lfsr_b(
        .clk_i(!clk_i),
        .rst_i(rst_lfsr_b),
        .start_i(start_lfsr_b),
        .init_value(INIT_B),
        .busy_o(busy_lfsr_b),
        .y_o(result_lfsr_b)
    );
    
    crc8 crc8_1(
        .clk_i(!clk_i),
        .rst_i(rst_crc8),
        .start_i(start_crc8),
        .a_i(result_fblock),
        .busy_o(busy_crc8),
        .y_o(result_crc8)
    );
    
    assign busy_o = state != IDLE;
    
    always @(posedge clk_i)
        if(rst_i) begin
            y_o <= 0;
            counter_o <= 0;
            
            rst_fblock <= 1;
            rst_lfsr_a <= 1;
            rst_lfsr_b <= 1;
            rst_crc8 <= 1;
            state <= IDLE;
        end
        else
            case(state)
                IDLE:
                    if(start_i) begin
                        rst_fblock <= 0;
                        rst_lfsr_a <= 0;
                        rst_lfsr_b <= 0;
                        rst_crc8 <= 0;
                        
                        a <= a_i;
                        b <= b_i;
                        state <= MODE;  
                    end
                MODE:
                    if(test) begin
                         iter_c <= 0;
                         state <= TEST_INIT;
                    end
                    else begin
                         state <= USER_INPUT;
                    end
                TEST_INIT:
                    begin
                        start_lfsr_a <= 1;
                        start_lfsr_b <= 1;
                        state <= GENERATING; 
                    end
                GENERATING:
                    if (!busy_lfsr_a && !busy_lfsr_b) begin
                        start_lfsr_a <= 0; 
                        start_lfsr_b <= 0;
                        state <= FBLOCK; 
                    end
                FBLOCK:
                    if(!start_fblock)
                        start_fblock <= 1;
                    else if(!busy_fblock) begin
                        start_fblock <= 0;
                        state <= CRC; 
                    end
                CRC:
                    if(iter_c != 255) begin
                        if(!start_crc8)
                            start_crc8 <= 1;
                        else if(!busy_crc8) begin
                             iter_c <= iter_c + 1;
                             start_crc8 <= 0;
                             state <= TEST_INIT;
                        end
                    end
                    else begin 
                        y_o <= result_crc8;
                        counter_o <= counter_o + 1;
                        state <= IDLE;
                    end
                USER_INPUT:
                    if(!start_fblock) begin
                         start_fblock <= 1;
                    end else if(!busy_fblock) begin
                        y_o <= result_fblock;
                        state <= IDLE; 
                    end
            endcase
endmodule