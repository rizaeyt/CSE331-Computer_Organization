module down_counter #(
    parameter W = 6
)(
    input  wire         clk,
    input  wire         rst,      // synchronous
    input  wire         load,
    input  wire         dec,
    input  wire [W-1:0] init_val,
    output wire         is_zero,
    output wire [W-1:0] value
);
    reg [W-1:0] cnt;

    always @(posedge clk) begin
        if (rst) begin
            cnt <= {W{1'b0}};
        end else if (load) begin
            cnt <= init_val;
        end else if (dec) begin
            cnt <= cnt - {{(W-1){1'b0}}, 1'b1};
        end
    end

    assign value  = cnt;
    assign is_zero = (cnt == {W{1'b0}});
endmodule
