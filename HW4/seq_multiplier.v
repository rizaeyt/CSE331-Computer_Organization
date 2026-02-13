module seq_multiplier #(
    parameter N = 32
)(
    input  wire         clk,
    input  wire         rst,        // synchronous
    input  wire         start,      // 1-cycle pulse
    input  wire [N-1:0] multiplicand,
    input  wire [N-1:0] multiplier,
    output wire [2*N-1:0] product,
    output wire         busy,
    output wire         done
);

    // Control signals
    wire ld_operands, clr_product, add_enable, shift_enable;
    wire cnt_load, cnt_dec, sel_add_src;

    // Status
    wire cnt_zero, lsb_is_one;

    // Datapath
    mul_datapath #(.N(N)) u_dp (
        .clk(clk),
        .rst(rst),
        .ld_operands(ld_operands),
        .clr_product(clr_product),
        .add_enable(add_enable),
        .shift_enable(shift_enable),
        .cnt_load(cnt_load),
        .cnt_dec(cnt_dec),
        .sel_add_src(sel_add_src),
        .cnt_zero(cnt_zero),
        .lsb_is_one(lsb_is_one),
        .multiplicand_in(multiplicand),
        .multiplier_in(multiplier),
        .product_out(product)
    );

    // Control Unit
    mul_control u_cu (
        .clk(clk),
        .rst(rst),
        .start(start),
        .cnt_zero(cnt_zero),
        .lsb_is_one(lsb_is_one),
        .ld_operands(ld_operands),
        .clr_product(clr_product),
        .add_enable(add_enable),
        .shift_enable(shift_enable),
        .cnt_load(cnt_load),
        .cnt_dec(cnt_dec),
        .sel_add_src(sel_add_src),
        .busy(busy),
        .done(done)
    );

endmodule
