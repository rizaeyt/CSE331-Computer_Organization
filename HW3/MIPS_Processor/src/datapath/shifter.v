module shifter (
    input wire [31:0] a,      // The value to shift (usually rt)
    input wire [4:0] shamt,   // How much to shift (from Instr or Rs)
    input wire [1:0] mode,    // 00=SLL, 01=SRL, 10=SRA
    output reg [31:0] y       // The result
);

    always @(*) begin
        case (mode)
            2'b00: y = a << shamt;        // SLL
            2'b01: y = a >> shamt;        // SRL
            2'b10: y = $signed(a) >>> shamt; // SRA (Arithmetic uses >>>)
            default: y = 32'b0;
        endcase
    end

endmodule