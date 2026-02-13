module control_unit (
    input wire [5:0] op,
    input wire [5:0] funct, // Needed for 'jr' (R-type but acts like a jump)
    input wire [4:0] rt,    // Needed for 'bltz' vs 'bgez' (both use op 1)
    
    output wire reg_dst,
    output wire alu_src,
    output wire mem_to_reg,
    output wire reg_write,
    output wire mem_read,
    output wire mem_write,
    output wire branch,       // Master branch enable
    output wire [2:0] branch_type, // 000=BEQ, 001=BNE, 010=BLTZ, 011=BGEZ...
    output wire jump,
    output wire link,         // For JAL/JALR (writes PC+4 to register)
    output wire jr,           // For JR/JALR (jumps to register value)
    output wire [3:0] alu_op  // 0000=ADD, 0001=SUB, 0010=AND... 1111=R-Type
);

    // --- 1. DECODE OPCODES ---
    // R-Type: 000000
    wire is_r_type = (op == 6'b000000);
    
    // I-Type Arithmetic/Logic
    wire is_addi   = (op == 6'b001000); // 8
    wire is_addiu  = (op == 6'b001001); // 9
    wire is_andi   = (op == 6'b001100); // 12
    wire is_ori    = (op == 6'b001101); // 13
    wire is_xori   = (op == 6'b001110); // 14
    wire is_slti   = (op == 6'b001010); // 10
    
    // Memory
    wire is_lw     = (op == 6'b100011); // 35
    wire is_sw     = (op == 6'b101011); // 43
    
    // Branches
    wire is_beq    = (op == 6'b000100); // 4
    wire is_bne    = (op == 6'b000101); // 5
    // REGIMM (op=1) handles bltz, bgez
    wire is_regimm = (op == 6'b000001); 
    
    // Jumps
    wire is_j      = (op == 6'b000010); // 2
    wire is_jal    = (op == 6'b000011); // 3
    
    // JR/JALR are R-Types (op=0) but need specific funct codes
    // jr func: 001000 (8), jalr func: 001001 (9)
    wire is_jr_inst   = is_r_type && (funct == 6'b001000);
    wire is_jalr_inst = is_r_type && (funct == 6'b001001);


    // --- 2. ASSIGN SIGNALS ---

    // Write to Register? (True for R-Type, Load, Addi, Andi..., Jal)
    // EXCEPTION: JR does NOT write to register (unless it's JALR)
    assign reg_write = (is_r_type && !is_jr_inst) || is_addi || is_addiu || 
                       is_andi || is_ori || is_xori || is_slti || is_lw || 
                       is_jal || is_jalr_inst;

    // Destination Register? 
    // 1 = rd (R-Type), 0 = rt (I-Type, LW)
    // Note: JAL writes to $31, which is handled separately in top-level usually, 
    // or via a mux 2. For simplicity here: R-Type uses RD.
    assign reg_dst = is_r_type; 

    // ALU Source? 
    // 0 = Register (R-Type, BEQ), 1 = Immediate (Addi, LW, SW)
    assign alu_src = is_addi || is_addiu || is_andi || is_ori || is_xori || 
                     is_slti || is_lw || is_sw;

    // Memory Signals
    assign mem_read  = is_lw;
    assign mem_write = is_sw;
    assign mem_to_reg = is_lw; // 1 means data comes from RAM, not ALU

    // Branching & Jumping
    assign branch = is_beq || is_bne || is_regimm;
    assign jump   = is_j || is_jal;
    assign link   = is_jal || is_jalr_inst; // Save PC+4
    assign jr     = is_jr_inst || is_jalr_inst;

    // Branch Type Encoding
    // 000: BEQ, 001: BNE, 010: BLTZ (rt=0), 011: BGEZ (rt=1)
    assign branch_type[0] = is_bne || (is_regimm && rt[0]); // bne or bgez
    assign branch_type[1] = is_regimm; // bltz or bgez
    assign branch_type[2] = 1'b0;      // (Expand for blez/bgtz if needed)

    // --- 3. ALU OP ENCODING ---
    // We create a specific code for the ALU Control to interpret.
    // 1111 = R-Type (Look at funct)
    // 0000 = Add (lw, sw, addi)
    // 0001 = Sub (beq, bne)
    // 0010 = And (andi)
    // 0011 = Or (ori)
    // 0100 = Xor (xori)
    // 0101 = Slt (slti)
    
    assign alu_op[0] = is_beq || is_bne || is_ori || is_slti || is_r_type;
    assign alu_op[1] = is_andi || is_ori || is_xori || is_r_type;
    assign alu_op[2] = is_xori || is_slti || is_r_type;
    assign alu_op[3] = is_r_type; 
    // Note: The logic above is a bit messy to create structurally. 
    // It is often cleaner to just use continuous assignment with logic:
    // ALU_OP = (is_r_type) ? 4'b1111 :
    //          (is_andi)   ? 4'b0010 : ...
    // Let's rewrite strictly using the ternary operator for clarity:

    assign alu_op = (is_r_type) ? 4'b1111 : 
                    (is_andi)   ? 4'b0010 :
                    (is_ori)    ? 4'b0011 :
                    (is_xori)   ? 4'b0100 :
                    (is_slti)   ? 4'b0101 :
                    (is_beq || is_bne) ? 4'b0001 : // Sub for compare
                    4'b0000; // Default ADD (lw, sw, addi)

endmodule