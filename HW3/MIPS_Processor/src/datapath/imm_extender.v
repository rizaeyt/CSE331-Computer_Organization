module imm_extender (
    input wire [15:0] imm,
    input wire sign,
    output reg [31:0] imm_ext // Must be 'reg' to use inside always block
);

    always @(*) begin
        if (sign == 1'b1) begin
            // SIGN EXTENSION:
            // Take the 15th bit (positive or negative) and copy it 16 times
            imm_ext = { {16{imm[15]}}, imm };
        end else begin
            // ZERO EXTENSION:
            // Just fill the top with zeros
            imm_ext = { 16'b0, imm };
        end
    end

endmodule