module lfsr(
    input clk_i,
    input rst_i,
    input start_i,
    input [7:0] init_value,
    
    output busy_o, 
    output reg [7:0] y_o
    );
    
    localparam INIT = 1'b0;
    localparam WORK = 1'b1;
    localparam FIRST_TIME = 1'b0;
    
    reg state;
    reg first_time;
    
    reg[7:0] bit, prev, lfsr;
    
    assign busy_o = state;
    
    always @(posedge clk_i)
    if(rst_i) begin
        y_o <= 0;
        state <= INIT;
        first_time = 1'd1;
    end 
    else begin
        case(state)
        INIT:
            begin
                if (start_i) begin
                    if (first_time) begin
                        lfsr <= init_value;
                        first_time <= FIRST_TIME;
                        state <= WORK;
                    end
                    else begin
                        lfsr <= prev;
                        state <= WORK;
                    end
                end
            end
        WORK:
            begin
                bit = ((lfsr >> 0) ^ (lfsr >> 3) ^ (lfsr >> 5) ^ (lfsr >> 6));
                prev = ((lfsr >> 1) | (bit << 7));
                y_o = prev;
                state <= INIT;
            end
        endcase
    end
endmodule