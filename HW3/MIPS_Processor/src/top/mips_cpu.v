module mips_cpu (
    input wire clk,
    input wire rst,
    // Debug Outputs (Requested by PDF)
    output wire [31:0] dbg_pc,    // Current PC
    output wire [31:0] dbg_instr  // Current Instruction
);

    // ============================================
    // 1. WIRES & INTERCONNECTIONS
    // ============================================
    
    // Program Counter Wires
    wire [31:0] pc_current;
    wire [31:0] pc_next;
    wire [31:0] pc_plus_4;
    wire [31:0] pc_branch_target;
    wire [31:0] pc_jump_target;
    
    // Instruction Decode Wires
    wire [31:0] instr;
    wire [5:0]  opcode = instr[31:26];
    wire [4:0]  rs     = instr[25:21];
    wire [4:0]  rt     = instr[20:16];
    wire [4:0]  rd     = instr[15:11];
    wire [4:0]  shamt  = instr[10:6];
    wire [5:0]  funct  = instr[5:0];
    wire [15:0] imm    = instr[15:0];
    wire [25:0] jump_addr = instr[25:0];

    // Control Signals
    wire reg_dst, alu_src, mem_to_reg, reg_write;
    wire mem_read, mem_write, branch, jump, link, jr;
    wire [2:0] branch_type;
    wire [3:0] alu_op;
    
    // Data Wires
    wire [31:0] reg_read_data_1;
    wire [31:0] reg_read_data_2;
    wire [31:0] imm_ext;
    wire [31:0] alu_operand_b;
    wire [31:0] alu_result;
    wire [31:0] mem_read_data;
    wire [31:0] write_back_data;
    wire [4:0]  write_reg_addr;

    // ALU Status
    wire zero_flag, lt_signed, lt_unsigned;
    wire [4:0] alu_ctrl_sel;

    // Debug Assignments
    assign dbg_pc = pc_current;
    assign dbg_instr = instr;


    // ============================================
    // 2. FETCH STAGE
    // ============================================

    // Program Counter Register
    pc_reg u_pc_reg (
        .clk(clk), 
        .rst(rst), 
        .pc_next(pc_next), 
        .pc(pc_current)
    );

    // Instruction Memory
    imem u_imem (
        .addr(pc_current), 
        .instr(instr)
    );

    // PC + 4 Adder
    add32 u_pc_plus_4 (
        .a(pc_current), 
        .b(32'd4), 
        .y(pc_plus_4)
    );


    // ============================================
    // 3. DECODE & CONTROL STAGE
    // ============================================

    // Main Control Unit
    control_unit u_control (
        .op(opcode),
        .funct(funct),
        .rt(rt),
        .reg_dst(reg_dst),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg), // (Not used directly, handled by MUX4)
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .branch_type(branch_type),
        .jump(jump),
        .link(link),
        .jr(jr),
        .alu_op(alu_op)
    );

    // Write Register Address Logic
    // If 'link' is 1 (JAL), write to $31.
    // Else if 'reg_dst' is 1, write to 'rd'.
    // Else write to 'rt'.
    assign write_reg_addr = link ? 5'd31 : (reg_dst ? rd : rt);

    // Register File
    reg_file u_reg_file (
        .clk(clk),
        .rst(rst),
        .we(reg_write),
        .ra1(rs),
        .ra2(rt),
        .wa(write_reg_addr),
        .wd(write_back_data),
        .rd1(reg_read_data_1),
        .rd2(reg_read_data_2)
    );

    // Immediate Extender (Sign or Zero extension)
    // We infer the 'sign' bit logic here:
    // Logic: ANDI, ORI, XORI (Bitwise I-Type) use Zero Extension. 
    // All others (ADDI, LW, SW, BEQ) use Sign Extension.
    // Based on our Control Unit, ALU_OP for ANDI is 0010, ORI 0011, XORI 0100.
    wire use_zero_ext = (alu_op == 4'b0010) || (alu_op == 4'b0011) || (alu_op == 4'b0100);
    
    imm_extender u_extender (
        .imm(imm),
        .sign(~use_zero_ext), // If not zero-ext, then sign-ext
        .imm_ext(imm_ext)
    );


    // ============================================
    // 4. EXECUTE STAGE
    // ============================================

    // ALU Source MUX (Register vs Immediate)
    mux2to1_32bit u_mux_alu_src (
        .input0(reg_read_data_2), 
        .input1(imm_ext), 
        .select(alu_src), 
        .out(alu_operand_b)
    );

    // ALU Control Unit
    alu_control u_alu_ctrl (
        .alu_op(alu_op), 
        .funct(funct), 
        .alu_sel(alu_ctrl_sel)
    );

    // ALU
    alu u_alu (
        .a(reg_read_data_1), 
        .b(alu_operand_b), 
        .shamt(shamt), 
        .sel(alu_ctrl_sel), 
        .y(alu_result), 
        .zero(zero_flag),
        .lt_signed(lt_signed),
        .lt_unsigned(lt_unsigned)
    );


    // ============================================
    // 5. MEMORY STAGE
    // ============================================
    dmem u_dmem (
        .clk(clk),
        .mem_write(mem_write),
        .addr(alu_result),
        .wd(reg_read_data_2), // Store value comes from rt
        .rd(mem_read_data)
    );

    // ============================================
    // 6. WRITE BACK STAGE
    // ============================================

    // We need to choose what data goes back to the register.
    // Option 0: ALU Result
    // Option 1: Memory Data (LW)
    // Option 2: PC + 4 (JAL Link)
    
    // Logic:
    // If 'link' is true -> Select 2 (PC+4)
    // Else if 'mem_to_reg' (Load) is true -> Select 1 (Mem)
    // Else -> Select 0 (ALU)
    
    wire [1:0] wb_select;
    assign wb_select = link ? 2'b10 : (mem_to_reg ? 2'b01 : 2'b00);

    mux4to1_32bit u_mux_write_back (
        .input0(alu_result),
        .input1(mem_read_data),
        .input2(pc_plus_4),
        .input3(32'b0),
        .select(wb_select),
        .out(write_back_data)
    );


    // ============================================
    // 7. NEXT PC LOGIC
    // ============================================

    // A. Branch Target Calculation
    // Target = PC + 4 + (SignExtImm * 4)
    wire [31:0] imm_shifted = {imm_ext[29:0], 2'b00}; // Shift Left 2
    add32 u_branch_adder (
        .a(pc_plus_4),
        .b(imm_shifted),
        .y(pc_branch_target)
    );

    // B. Branch Decision Logic
    // We look at 'branch_type' from Control and Flags from ALU
    reg take_branch;
    always @(*) begin
        if (branch) begin
            case (branch_type)
                3'b000: take_branch = zero_flag;         // BEQ
                3'b001: take_branch = ~zero_flag;        // BNE
                3'b010: take_branch = ~lt_signed && ~zero_flag; // BGTZ (example logic, adjust as needed)
                // Note: Implement BLTZ, BGEZ based on lt_signed as needed
                default: take_branch = 1'b0;
            endcase
        end else begin
            take_branch = 1'b0;
        end
    end

    // C. Jump Target Calculation
    // Target = {PC+4[31:28], Instr[25:0], 00}
    assign pc_jump_target = {pc_plus_4[31:28], jump_addr, 2'b00};

    // D. Final PC MUX Chain
    // Priority: 
    // 1. JR (Jump Register) - Highest Priority
    // 2. Jump (J/JAL)
    // 3. Branch (if taken)
    // 4. PC + 4
    
    wire [31:0] next_pc_from_branch;
    assign next_pc_from_branch = take_branch ? pc_branch_target : pc_plus_4;
    
    wire [31:0] next_pc_from_jump;
    assign next_pc_from_jump = jump ? pc_jump_target : next_pc_from_branch;

    assign pc_next = jr ? reg_read_data_1 : next_pc_from_jump;

endmodule