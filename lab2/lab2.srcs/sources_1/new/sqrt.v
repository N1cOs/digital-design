module sqrt(
    input clk_i,
    input rst_i,
    input start_i,
    input [16:0] a_i,
    
    output busy_o,
    output reg[15:0] y_o
    );
    
    localparam INIT = 1'b0;
    localparam WORK = 1'b1;
   
    reg[16:0] m;
    reg[16:0] a;
    reg[16:0] temp;
    reg[16:0] part_res;
    reg state;
    
    assign busy_o = state;
    
    always @(posedge clk_i)
        if(rst_i) begin
            m <= 17'h10000;
            part_res <= 0;
            temp <= 0;
            state <= INIT;
        end 
        else begin
            case(state)
                INIT:
                    if(start_i) begin
                        a <= a_i;
                        state <= WORK;
                    end
                WORK:
                    begin
                        if(m != 0) begin
                            temp = part_res | m;
                            part_res = part_res >> 1;
                            
                            if(a >= temp) begin
                                a <= a - temp;
                                part_res <= part_res | m;
                            end
                            m <= m >> 2;
                        end
                        else begin
                            y_o = part_res;
                            state <= INIT;
                        end
                    end    
            endcase            
        end        
endmodule
