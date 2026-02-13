module alu_control (
    input wire [3:0] alu_op, // From Main Control
    input wire [5:0] funct,  // From Instruction
    output reg [4:0] alu_sel // To ALU
);

    always @(*) begin
        if (alu_op == 4'b1111) begin
            // --- R-TYPE (Look at Funct) ---
            case (funct)
                6'b100000: alu_sel = 5'b00000; // ADD
                6'b100001: alu_sel = 5'b00000; // ADDU (same as add)
                6'b100010: alu_sel = 5'b00001; // SUB
                6'b100011: alu_sel = 5'b00001; // SUBU
                6'b100100: alu_sel = 5'b00010; // AND
                6'b100101: alu_sel = 5'b00011; // OR
                6'b100110: alu_sel = 5'b00100; // XOR
                6'b100111: alu_sel = 5'b00101; // NOR
                6'b101010: alu_sel = 5'b00110; // SLT
                6'b101011: alu_sel = 5'b00111; // SLTU
                
                // Shifts
                6'b000000: alu_sel = 5'b10000; // SLL
                6'b000010: alu_sel = 5'b10001; // SRL
                6'b000011: alu_sel = 5'b10010; // SRA
                
                default:   alu_sel = 5'b00000; // Default ADD
            endcase
        end else begin
            // --- I-TYPE (Use ALU_OP directly) ---
            case (alu_op)
                4'b0000: alu_sel = 5'b00000; // ADD (lw, sw, addi)
                4'b0001: alu_sel = 5'b00001; // SUB (beq, bne)
                4'b0010: alu_sel = 5'b00010; // AND (andi)
                4'b0011: alu_sel = 5'b00011; // OR (ori)
                4'b0100: alu_sel = 5'b00100; // XOR (xori)
                4'b0101: alu_sel = 5'b00110; // SLT (slti)
                default: alu_sel = 5'b00000;
            endcase
        end
    end

endmodule