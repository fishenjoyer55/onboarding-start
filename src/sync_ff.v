`default_nettype none

module sync_ff (
    input wire in,
    input wire clk,
    input reset_n,
    
    output wire out
);

reg ff1, ff2;

always @(posedge clk) begin
    if (reset_n == 1'b0) begin
        ff1 <= 1'b0;
        ff2 <= 1'b0;
    end
    else begin
        ff1 <= in;
        ff2 <= ff1;
    end
end

assign out = ff2;

endmodule