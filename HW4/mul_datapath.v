module mul_datapath #(
    parameter N = 32
)(
    input  wire           clk,
    input  wire           rst,

    // Control signals (from CU)
    input  wire           ld_operands,   // load multiplicand/multiplier
    input  wire           clr_product,    // clear accumulator/product
    input  wire           add_enable,     // conditionally add multiplicand
    input  wire           shift_enable,   // shift registers
    input  wire           cnt_load,       // initialize iteration counter
    input  wire           cnt_dec,        // decrement counter
    input  wire           sel_add_src,    // unused in this base version

    // Status back to CU
    output wire           cnt_zero,       // loop termination
    output wire           lsb_is_one,     // from multiplier for add decision

    // External interface
    input  wire [N-1:0]   multiplicand_in,
    input  wire [N-1:0]   multiplier_in,
    output wire [2*N-1:0] product_out
);

    // ------------------------------------------------------------
    // Registers
    // ------------------------------------------------------------
    // IMPORTANT FIX:
    // Keep shifted multiplicand in 2N bits to avoid overflow loss.
    reg [2*N-1:0] a_reg;         // shifted multiplicand (2N)
    reg [N-1:0]   b_reg;         // shifting multiplier (N)
    reg [2*N-1:0] p_reg;         // product accumulator (2N)

    // ------------------------------------------------------------
    // Counter width: ceil(log2(N+1)) (simple piecewise)
    // ------------------------------------------------------------
    localparam CW = (N <= 2)   ? 2 :
                    (N <= 4)   ? 3 :
                    (N <= 8)   ? 4 :
                    (N <= 16)  ? 5 :
                    (N <= 32)  ? 6 :
                    (N <= 64)  ? 7 :
                    (N <= 128) ? 8 :
                    (N <= 256) ? 9 :
                    (N <= 512) ? 10 : 11;

    wire [CW-1:0] cnt_val;

    // ------------------------------------------------------------
    // Combinational add (2N-bit)
    // ------------------------------------------------------------
    wire [2*N-1:0] p_plus_a;
    add2N #(.N(N)) u_add (
        .a(p_reg),
        .b(a_reg),
        .y(p_plus_a)
    );

    // ------------------------------------------------------------
    // Counter (behavioral state)
    // ------------------------------------------------------------
    down_counter #(.W(CW)) u_cnt (
        .clk(clk),
        .rst(rst),
        .load(cnt_load),
        .dec(cnt_dec),
        .init_val(N[CW-1:0]),
        .is_zero(cnt_zero),
        .value(cnt_val)
    );

    // ------------------------------------------------------------
    // Status + output
    // ------------------------------------------------------------
    assign lsb_is_one  = b_reg[0];
    assign product_out = p_reg;

    // sel_add_src unused in this base version
    wire _unused = sel_add_src;

    // ------------------------------------------------------------
    // Sequential updates
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            a_reg <= {(2*N){1'b0}};
            b_reg <= {N{1'b0}};
            p_reg <= {(2*N){1'b0}};
        end else begin
            // load operands
            if (ld_operands) begin
                a_reg <= {{N{1'b0}}, multiplicand_in}; // zero-extend to 2N
                b_reg <= multiplier_in;
            end

            // clear product
            if (clr_product) begin
                p_reg <= {(2*N){1'b0}};
            end

            // add step (only when enabled)
            if (add_enable) begin
                p_reg <= p_plus_a;
            end

            // shift step
            if (shift_enable) begin
                a_reg <= a_reg << 1;   // shift left in 2N bits (no truncation)
                b_reg <= b_reg >> 1;   // shift right in N bits
            end
        end
    end

endmodule
