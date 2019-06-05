module crc8(
    input clk_i,
    input rst_i,
    input start_i,
    input [8:0] a_i,
    
    output busy_o, 
    output reg [7:0] y_o
    );
    
    localparam IDLE = 2'd0;
    localparam COMPUTE = 2'd1;
    localparam WAIT_NUMBER = 2'd2;
    
    localparam POLY = 8'hd1;
    localparam ITER_AMOUNT = 9'd10;
    
    reg [7:0] value, temp, counter;
    reg [8:0] a;
    reg [3:0] bit_counter;
    reg [1:0] state;
    
    assign busy_o = state == COMPUTE;
    
    always @(posedge clk_i)
        if(rst_i) begin
            y_o <= 0;
            state <= IDLE;
        end 
        else begin
            case(state)
                IDLE:
                    if(start_i) begin
                        value <= 8'hff;
                        counter <= 0;
                        state <= WAIT_NUMBER;
                    end
                WAIT_NUMBER:
                    if(start_i) begin
                        if (counter != ITER_AMOUNT) begin
                            bit_counter <= 4'hf;
                            a <= a_i;
                            counter <= counter + 1;
                            state <= COMPUTE; 
                        end
                        else begin
                            y_o <= value;
                            state <= IDLE; 
                        end
                    end
                COMPUTE:
                    if (bit_counter != 15) begin
                        if (bit_counter < 8) begin
                            temp = value & 8'h80;
                            value <= temp ? (value << 1) ^ POLY : (value << 1);
                            bit_counter <= bit_counter + 1;
                        end
                        else begin
                            state <= WAIT_NUMBER;
                        end
                    end
                    else begin
                        value <= value ^ a;
                        bit_counter <= 0;
                    end
            endcase
        end
endmodule
