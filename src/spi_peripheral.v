`default_nettype none

module spi_peripheral (
    input wire unsynced_SCLK
    input wire clk
    input wire reset
    input wire unsynced_COPI
    input wire unsynced_nCS

    output reg [7:0] en_reg_out_7_0,
    output reg [7:0] en_reg_out_15_8,
    output reg [7:0] en_reg_pwm_7_0,
    output reg [7:0] en_reg_pwm_15_8,
    output reg [7:0] pwm_duty_cycle,
);

wire SCLK;
wire COPI;
wire nCS;

sync_ff SCLK_syncer (
    .in(unsynced_SCLK),
    .clk(clk),
    .reset_n(reset_n),
    .out(SCLK)
)

sync_ff COPI_syncer (
    .in(unsynced_COPI),
    .clk(clk),
    .reset_n(reset_n),
    .out(COPI)
)

sync_ff nCS_syncer (
    .in(unsynced_nCS),
    .clk(clk),
    .reset_n(reset_n),
    .out(nCS)
)


endmodule