module mul_control (
    input  wire clk,
    input  wire rst,       // synchronous
    input  wire start,
    input  wire cnt_zero,
    input  wire lsb_is_one,

    output reg  ld_operands,
    output reg  clr_product,
    output reg  add_enable,
    output reg  shift_enable,
    output reg  cnt_load,
    output reg  cnt_dec,
    output reg  sel_add_src,
    output reg  busy,
    output reg  done
);

    // State encoding
    localparam S_IDLE      = 3'd0;
    localparam S_LOAD      = 3'd1;
    localparam S_RUN_ADD   = 3'd2;
    localparam S_RUN_SHIFT = 3'd3;
    localparam S_DONE      = 3'd4;

    reg [2:0] state, next_state;

    // (1) State register (sequential)  ✅ always #1
    always @(posedge clk) begin
        if (rst) state <= S_IDLE;
        else     state <= next_state;
    end

    // (2) Next-state logic (combinational) ✅ always #2
    always @* begin
        next_state = state;

        case (state)
            S_IDLE: begin
                if (start) next_state = S_LOAD;
            end

            S_LOAD: begin
                next_state = S_RUN_ADD;
            end

            S_RUN_ADD: begin
                // Bu state sadece "gerekirse add" için 1 cycle
                next_state = S_RUN_SHIFT;
            end

            S_RUN_SHIFT: begin
                // Shift + counter decrement yapıldıktan sonra bitiş kontrolü
                if (cnt_zero) next_state = S_DONE;
                else          next_state = S_RUN_ADD;
            end

            S_DONE: begin
                next_state = S_IDLE;
            end

            default: next_state = S_IDLE;
        endcase
    end

    // (3) Output/control logic (combinational) ✅ always #3
    always @* begin
        // defaults
        ld_operands  = 1'b0;
        clr_product  = 1'b0;
        add_enable   = 1'b0;
        shift_enable = 1'b0;
        cnt_load     = 1'b0;
        cnt_dec      = 1'b0;
        sel_add_src  = 1'b0;

        busy = 1'b0;
        done = 1'b0;

        case (state)
            S_IDLE: begin
                busy = 1'b0;
                done = 1'b0;
            end

            S_LOAD: begin
                busy        = 1'b1;
                ld_operands = 1'b1;
                clr_product = 1'b1;
                cnt_load    = 1'b1;
            end

            S_RUN_ADD: begin
                busy = 1'b1;
                // lsb 1 ise add yap
                if (lsb_is_one) add_enable = 1'b1;
            end

            S_RUN_SHIFT: begin
                busy        = 1'b1;
                shift_enable= 1'b1;
                cnt_dec     = 1'b1;
            end

            S_DONE: begin
                busy = 1'b0;
                done = 1'b1; // 1-cycle pulse
            end
        endcase
    end

endmodule
