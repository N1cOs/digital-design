module fblock(
    input clk_i,
    input rst_i,
    
    input [7:0] a_i,
    input [7:0] b_i,
    input start_i,
    
    output busy_o,
    output reg [15:0] y_o
    );
    
    localparam POST_RESET = 3'b0;
    localparam INIT = 3'd1;
    localparam SQR_1 = 3'd2;
    localparam SQR_2 = 3'd3;
    localparam SQRT = 3'd4;
    
    reg [7:0] a, b;
    reg [16:0] sum;
    reg [2:0] state;
    
    reg [7:0] x_sqr;
    wire [15:0] sqr_result;
    wire [15:0] sqrt_result;
    
    reg rst_sqr, rst_sqrt;
    reg start_sqr, start_sqrt;
    wire busy_sqr, busy_sqrt;
    wire end_sqr, end_sqrt;
    
    sqr sqr_1(
        .clk_i(clk_i),
        .rst_i(rst_sqr),
        .start_i(start_sqr),
        .a_i(x_sqr),
        .busy_o(busy_sqr),
        .y_o(sqr_result)
    );
    
    sqrt sqrt_1(
        .clk_i(clk_i),
        .rst_i(rst_sqrt),
        .start_i(start_sqrt),
        .a_i(sum),
        .busy_o(busy_sqrt),
        .y_o(sqrt_result)
    );
    
    assign busy_o = (state == POST_RESET || state != INIT);
    assign end_sqr = !busy_sqr;
    assign end_sqrt = !busy_sqrt;
    
    
    always @(posedge clk_i)
        if(rst_i) begin
            y_o <= 0;
            rst_sqr <= 1'b1;
            rst_sqrt <= 1'b1;
            start_sqr <= 0;
            start_sqrt <= 0;
            state <= POST_RESET;    
        end 
        else begin
            case(state)
                POST_RESET:
                    begin
                        rst_sqr <= 0;
                        rst_sqrt <= 0;
                        state <= INIT; 
                    end
                INIT:
                    if(start_i) begin
                        sum <= 0;
                        a <= a_i;
                        b <= b_i;
                        state <= SQR_1;
                    end    
                SQR_1:
                    if(!start_sqr) begin
                        x_sqr <= a;
                        start_sqr <= 1'b1;
                    end
                SQR_2:
                    if(!start_sqr) begin
                        x_sqr <= b;
                        start_sqr <= 1'b1;
                    end
                SQRT:
                    if(!start_sqrt) begin
                        start_sqrt <= 1'b1;
                    end                
            endcase                         
        end
        
    always @(negedge busy_sqr, negedge busy_sqrt)
        begin
            case(state)
                SQR_1:
                    begin
                        sum <= sum + sqr_result;
                        start_sqr <= 0;
                        state <= SQR_2;
                    end
                 SQR_2:
                    begin
                        sum <= sum + sqr_result;
                        start_sqr <= 0;
                        state <= SQRT; 
                    end
                 SQRT:
                    begin
                        y_o = sqrt_result;
                        start_sqrt <= 0;
                        state <= INIT; 
                    end      
            endcase 
        end    
endmodule
