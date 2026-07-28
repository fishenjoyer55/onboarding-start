`default_nettype none

module spi_peripheral (
    input wire unsynced_SCLK,
    input wire clk,
    input wire reset,
    input wire unsynced_COPI,
    input wire unsynced_nCS,

    output reg [7:0] en_reg_out_7_0,
    output reg [7:0] en_reg_out_15_8,
    output reg [7:0] en_reg_pwm_7_0,
    output reg [7:0] en_reg_pwm_15_8,
    output reg [7:0] pwm_duty_cycle
);

wire SCLK, COPI, nCS;

sync_ff SCLK_syncer (
    .in(unsynced_SCLK),
    .clk(clk),
    .reset_n(reset_n),
    .out(SCLK)
);

sync_ff COPI_syncer (
    .in(unsynced_COPI),
    .clk(clk),
    .reset_n(reset_n),
    .out(COPI)
);

sync_ff nCS_syncer (
    .in(unsynced_nCS),
    .clk(clk),
    .reset_n(reset_n),
    .out(nCS)
);

reg SCLK_prev, nCS_prev;
wire SCLK_posedge, nCS_negedge;
reg [15:0] COPI_holder;
reg [4:0] counter;

assign SCLK_posedge = (SCLK & ~SCLK_prev); //bit incoming signal
//assign nCS_posedge = nCS & ~nCS_prev; //end transaction signal. uh actually this is only true if each transaction is one message. not sure about this one
assign nCS_negedge = (~nCS & nCS_prev); //start transaction signal

always @(posedge clk, negedge reset_n) begin
    
    if (~reset_n) begin
        en_reg_out_15_8 <= 8'b0;
        en_reg_out_7_0 <= 8'b0;
        en_reg_pwm_15_8 <= 8'b0;
        en_reg_pwm_7_0 <= 8'b0;
        pwm_duty_cycle <= 8'b0;
        SCLK_prev <= 1'b0;
        nCS_prev <= 1'b0;
        COPI_holder <= 16'b0;
        counter <= 4'b0;
    end

    else begin

        if (nCS_negedge) begin
            COPI_holder <= 16'b0;
            counter <= 4'b0;
        end
        else if (~nCS && SCLK_posedge) begin


            if (counter < 4'b1111) begin
                COPI_holder <= {COPI_holder[14:0], COPI[0]};
                counter <= counter + 1;
            end

            //writing function only. indicated by COPI_holder[0] == 1
            else if (counter == 4'b1111 && COPI_holder[0] == 1) begin
                case (COPI_holder[14:8])
                    7'b000:
                    en_reg_out_7_0 <= COPI_holder[7:0];

                    7'b001:
                    en_reg_out_15_8 <= COPI_holder[7:0];

                    7'b010:
                    en_reg_pwm_7_0 <= COPI_holder[7:0];

                    7'b011:
                    en_reg_pwm_15_8 <= COPI_holder[7:0];

                    7'b100:
                    pwm_duty_cycle <= COPI_holder[7:0];
                endcase

                counter <= 4'b0;
             end
        end 

        SCLK_prev <= SCLK;
        nCS_prev <= nCS;
    end
end

endmodule