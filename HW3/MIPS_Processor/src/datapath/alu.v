module alu (
    input wire [31:0] a,       // Operand A (rs)
    input wire [31:0] b,       // Operand B (rt or imm)
    input wire [4:0] shamt,    // Shift Amount
    input wire [4:0] sel,      // Operation Select Code
    output reg [31:0] y,       // Result
    output wire zero,          // 1 if result is 0 (for BEQ)
    output wire lt_signed,     // 1 if A < B (signed)
    output wire lt_unsigned    // 1 if A < B (unsigned)
);

    // --- Internal Logic ---
    wire [31:0] sub_res = a - b; // Calculate A-B for comparisons

    // --- Status Flags ---
    assign zero = (y == 32'b0);
    assign lt_signed = ($signed(a) < $signed(b));
    assign lt_unsigned = (a < b);

    // --- Shifter Instance (Parallel Calculation) ---
    wire [31:0] shift_res;
    // We assume the bottom 2 bits of 'sel' determine shift mode if top bits indicate shift
    shifter u_shifter (
        .a(b),           // Shifting is usually done on B (rt)
        .shamt(shamt),
        .mode(sel[1:0]), // Map 00=SLL, 01=SRL, 10=SRA
        .y(shift_res)
    );

    // --- ALU Operations Mapped to 'sel' ---
    // You must match these codes in your ALU Control!
    always @(*) begin
        case (sel)
            // Arithmetic
            5'b00000: y = a + b;       // ADD
            5'b00001: y = a - b;       // SUB

            // Logical
            5'b00010: y = a & b;       // AND
            5'b00011: y = a | b;       // OR
            5'b00100: y = a ^ b;       // XOR
            5'b00101: y = ~(a | b);    // NOR

            // Comparison (SLT)
            5'b00110: y = {31'b0, lt_signed};   // SLT
            5'b00111: y = {31'b0, lt_unsigned}; // SLTU

            // Shifts (Pass through the shifter result)
            // We use the code 10xxx to indicate Shift operations
            5'b10000: y = shift_res; // SLL
            5'b10001: y = shift_res; // SRL
            5'b10010: y = shift_res; // SRA
            
            // Default
            default: y = 32'b0;
        endcase
    end

endmodule