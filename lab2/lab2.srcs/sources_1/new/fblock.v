module fblock(
    input clk_i,
    input rst_i,
    
    input [7:0] a_i,
    input [7:0] b_i,
    input start_i,
    
    output busy_o,
    output reg [15:0] y_o
    );
    
    localparam FIRST = 2'b0;
    localparam SECOND = 2'b1;
    localparam SQR_RESET = 2'b10;
    localparam BOTH = 2'b11;
    
    localparam INIT = 1'b0;
    localparam WORK = 1'b1;
    
    reg [7:0] a, b;
    reg [15:0] res;
    reg [16:0] sum;
    reg [1:0] operand;
    reg state;
    
    reg [7:0] x_sqr;
    wire [15:0] sqr_result;
    wire [15:0] sqrt_result;
    
    reg rst_sqr, rst_sqrt;
    reg start_sqr, start_sqrt;
    wire busy_sqr, busy_sqrt;
    
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
    
    assign busy_o = state || busy_sqr || busy_sqrt;
    
    
    always @(posedge clk_i)
        if(rst_i) begin
            rst_sqr <= 1'b1;
            rst_sqrt <= 1'b1;
            res <= 0;
            sum <= 0;
            state <= INIT;    
        end 
        else begin
            case(state)
                INIT:
                    if(start_i) begin
                        a <= a_i;
                        b <= b_i;
                        rst_sqrt = 0;
                        rst_sqr = 0;
                        start_sqr = 0;
                        start_sqrt = 0;
                        state <= WORK;
                        operand <= FIRST;
                    end
                WORK:
                    case(operand)
                        SQR_RESET:
                            begin
                                 if(!busy_sqr) begin
                                    rst_sqr <= 0;
                                    operand <= SECOND;
                                 end
                            end
                        FIRST:
                            begin
                                if(!start_sqr) begin
                                    x_sqr <= a;
                                    start_sqr <= 1'b1;
                                end 
                                else if(!busy_sqr) begin
                                    sum <= sum + sqr_result;
                                    start_sqr <= 0;
                                    operand <= SQR_RESET;
                                    rst_sqr <= 1'b1;
                                    $display("First operand is calculated %d", sum);
                                end 
                            end
                        SECOND:
                            begin
                                $display("Busy %b", busy_sqr);
                                    if(!start_sqr) begin
                                        x_sqr <= b;
                                        start_sqr <= 1'b1;
                                    end 
                                    else if(!busy_sqr) begin
                                        sum <= sum + sqr_result;
                                        start_sqr <= 0;
                                        operand <= BOTH;
                                        $display("Second operand is calculated %d", sum);
                                    end 
                                end
                        BOTH:
                            if(!start_sqrt) begin
                                start_sqrt <= 1'b1;
                            end
                            else if(!busy_sqrt) begin
                                y_o <= sqrt_result;
                                start_sqrt <= 0;
                                state <= INIT;
                                $display("Sum calculated %d", sqrt_result);
                            end      
                    endcase       
            endcase                         
        end
endmodule
