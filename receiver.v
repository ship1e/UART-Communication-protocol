module RX #(parameter t_rate=5208)(
    input clk,
    input Rst_rx,
    input Rs232,
    output reg [7:0] rx_data,
    output reg done
);

parameter state0=0, state1=1;
reg state_reg = state0, state_next;
reg [12:0] baud_cnt = 0, baud_cnt_next;
reg [3:0] bit_cnt = 0, bit_cnt_next;
reg [7:0] rx_data_next;
reg done_next;

always @(posedge clk or negedge Rst_rx) begin
    if(!Rst_rx) begin
        state_reg <= state0;
        baud_cnt <= 0;
        bit_cnt <= 0;
        done <= 0;
        rx_data <= 8'hxx;  
    end else begin
        state_reg <= state_next;
        baud_cnt <= baud_cnt_next;
        bit_cnt <= bit_cnt_next;
        done <= done_next;
        rx_data <= rx_data_next;
    end
end

always @(*) begin
    state_next = state_reg;
    baud_cnt_next = baud_cnt;
    bit_cnt_next = bit_cnt;
    done_next = done;
    rx_data_next = rx_data;
    
    case(state_reg)
        state0: begin
            done_next = 0;  
            rx_data <= 8'hxx;
            if(baud_cnt < (t_rate/2) - 1) begin
                baud_cnt_next = baud_cnt + 1; 
                state_next = state0;
            end else begin
                if(Rs232 == 0) begin 
                    state_next = state1;
                    bit_cnt_next = 1;
                    baud_cnt_next = 0;
                end else begin
                    if(baud_cnt < t_rate - 1) begin
                        baud_cnt_next = baud_cnt + 1; 
                        state_next = state0;  
                    end else begin
                        baud_cnt_next = 0;
                    end
                end
            end
        end  
        
        state1: begin
            if(bit_cnt < 10) begin
                if(baud_cnt < t_rate - 1) begin
                    baud_cnt_next = baud_cnt + 1; 
                    state_next = state1;
                end else begin
                    baud_cnt_next = 0;  
                    if(bit_cnt == 9 && Rs232 == 1) begin 
                        done_next = 1;
                        state_next = state0;
                        bit_cnt_next = 0;
                    end else if(bit_cnt == 9 && Rs232 == 0) begin  
                        done_next = 0;  
                        state_next = state0;
                        bit_cnt_next = 0;
                    end else begin  
                        if(bit_cnt >= 1 && bit_cnt <= 8) begin
                            rx_data_next[bit_cnt-1] = Rs232;
                        end
                        done_next = 0;
                        state_next = state1;
                        bit_cnt_next = bit_cnt + 1;
                    end
                end
            end else begin
                state_next = state0;
                bit_cnt_next = 0; 
            end     
        end
        
        default: begin
            state_next = state0;
        end
    endcase
end

endmodule
