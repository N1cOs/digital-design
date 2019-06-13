module selftest_block(
    input clk_i,
    input rst_i,
    input start_i,
    input test,
    
    input [7:0] a_i,
    input [7:0] b_i,
    
    output busy_o,
    output reg [6:0] counter_o,
    output reg [8:0] y_o
    );
    
    localparam INIT_A = 8'd11;
    localparam INIT_B = 8'd31;
    localparam ITER_AMOUNT = 8'd255;
    
    localparam IDLE = 3'd0;
    localparam MODE = 3'd1;
    localparam USER_INPUT = 3'd2;
    localparam TEST_INIT = 3'd3;
    localparam GENERATING = 3'd4;
    localparam FUNC = 3'd5;
    localparam CRC = 3'd6;
    
    reg [2:0] state;
    
    reg rst_fblock, rst_lfsr_a, rst_lfsr_b, rst_crc8;
    reg start_fblock, start_lfsr_a, start_lfsr_b, start_crc8;
    
    reg [8:0] input_crc8;
    reg [7:0] a, b, iter_c;
    reg [6:0] counter;
    reg isTest;
    
    wire [8:0] result_fblock;
    wire [7:0] result_lfsr_a, result_lfsr_b, result_crc8;
     
    wire busy_fblock, busy_lfsr_a, busy_lfsr_b, busy_crc8;
    reg [7:0] clk_counter;
    
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
        .a_i(input_crc8),
        .busy_o(busy_crc8),
        .y_o(result_crc8)
    );
    
    assign busy_o = state != IDLE;
    
    always @(posedge clk_i)
        if(rst_i) begin
            y_o <= 0;
            counter_o <= 0;
            counter <= 0;
            
            rst_fblock <= 1;
            rst_lfsr_a <= 1;
            rst_lfsr_b <= 1;
            rst_crc8 <= 1;
            start_fblock <= 0;
            start_crc8 <= 0;
            state <= IDLE;
            clk_counter <= 0;
        end
        else
            case(state)
                IDLE:
                    begin
                        if (start_i || test) begin
                            rst_fblock <= 0;
                            rst_lfsr_a <= 0;
                            rst_lfsr_b <= 0;
                            rst_crc8 <= 0; 
                        end
                        if(start_i) begin
                            a <= a_i;
                            counter <= counter_o;
                            counter_o <= 0;
                            b <= b_i;
                            state <= USER_INPUT;  
                        end
                        else if(test && clk_counter < 64) begin
                             isTest <= 1;
                             state <= IDLE;
                             clk_counter <= clk_counter + 1;
                        end
                        else if(!test && isTest && clk_counter >= 64) begin
                             iter_c <= 0;
                             isTest <= 0;
                             clk_counter <= 0;
                             state <= TEST_INIT;
                        end
                    end
                TEST_INIT:
                    if (iter_c != ITER_AMOUNT) begin
                        start_lfsr_a <= 1;
                        start_lfsr_b <= 1;
                        state <= GENERATING; 
                    end
                    else begin
                        y_o = result_crc8;
                        counter = counter + 1;
                        counter_o = counter;
                        state <= IDLE;
                    end
                GENERATING:
                    if (!busy_lfsr_a && !busy_lfsr_b) begin
                        start_lfsr_a <= 0; 
                        start_lfsr_b <= 0;
                        
                        a <= result_lfsr_a;
                        b <= result_lfsr_b;
                        state <= FUNC; 
                    end
                FUNC:
                    if(!start_fblock)
                        start_fblock <= 1;
                    else if(!busy_fblock) begin
                        start_fblock <= 0;
                        input_crc8 <= result_fblock;
                        state <= CRC; 
                    end
                CRC:
                    if(!start_crc8)
                        start_crc8 <= 1;
                    else if(!busy_crc8) begin
                        iter_c <= iter_c + 1;
                        start_crc8 <= 0;
                        state <= TEST_INIT;
                    end
                USER_INPUT:
                    if(!start_fblock) begin
                         start_fblock <= 1;
                    end else if(!busy_fblock) begin
                        y_o = result_fblock;
                        state <= IDLE; 
                    end
            endcase
endmodule
