module TX#(parameter t_rate=5208)(
    input clk,
    input Rst_tx,
    input Start,
    input [7:0] data,
    output reg done,
    output Rs232_tx
);

parameter state0 = 0, state1 = 1;

reg state_reg = state0;
reg [7:0] r_data;
reg [12:0] baud_cnt = 0;
reg [3:0] bit_cnt = 0;
reg Start_d;
reg tx_reg = 1'b1;

assign Rs232_tx = tx_reg;

wire Start_edge = Start & ~Start_d;

always @(posedge clk or negedge Rst_tx) begin
    if (!Rst_tx) begin
        state_reg <= state0;
        baud_cnt <= 0;
        bit_cnt <= 0;
        done <= 0;
        tx_reg <= 1;
        Start_d <= 0;
    end else begin
        Start_d <= Start;

        case (state_reg)
            state0: begin
                baud_cnt <= 0;
                bit_cnt <= 0;
                done <= 0;
                tx_reg <= 1;
                if (Start_edge) begin
                    r_data <= data;
                    tx_reg <= 0; 
                    bit_cnt <= 1;
                    state_reg <= state1;
                end
            end

            state1: begin
                if (baud_cnt < t_rate - 1) begin
                    baud_cnt <= baud_cnt + 1;
                end else begin
                    baud_cnt <= 0;

                    case (bit_cnt)
                        1: tx_reg <= r_data[0];
                        2: tx_reg <= r_data[1];
                        3: tx_reg <= r_data[2];
                        4: tx_reg <= r_data[3];
                        5: tx_reg <= r_data[4];
                        6: tx_reg <= r_data[5];
                        7: tx_reg <= r_data[6];
                        8: tx_reg <= r_data[7];
                        9: tx_reg <= 1;
                        default: tx_reg=1;
                    endcase

                    if (bit_cnt == 9) begin
                        done <= 1;
                        state_reg <= state0;
                        bit_cnt <= 0;
                    end else begin
                        bit_cnt <= bit_cnt + 1;
                        done <= 0;
                    end
                end
            end

            default: state_reg <= state0;
        endcase
    end
end

endmodule
