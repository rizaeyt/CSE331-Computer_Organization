module alu_control(
    input wire [1:0] alu_op,
    input wire [5:0] funct,
    output wire [3:0] alu_control
);

    // --- 1. Funct Kodunu Çözümleme (Decoding) ---
    // Funct kodları: ADD(100000), SUB(100010), AND(100100), OR(100101), XOR(100110), SLT(101010)
    // Sadece son 4 bite bakmak yeterli ayırt ediciliği sağlar (funct[3:0]).
    
    wire f_add, f_sub, f_and, f_or, f_xor, f_slt;
    wire [5:0] not_funct;
    
    // Funct bitlerinin terslerini al
    genvar i;
    generate
        for (i=0; i<6; i=i+1) begin : inv_f
            not (not_funct[i], funct[i]);
        end
    endgenerate

    // 100000 -> ADD (bit 5=1, diğerleri 0)
    and (f_add, funct[5], not_funct[3], not_funct[2], not_funct[1], not_funct[0]);
    
    // 100010 -> SUB
    and (f_sub, funct[5], not_funct[3], not_funct[2], funct[1], not_funct[0]);
    
    // 100100 -> AND
    and (f_and, funct[5], funct[2], not_funct[1], not_funct[0]);
    
    // 100101 -> OR
    and (f_or,  funct[5], funct[2], not_funct[1], funct[0]);
    
    // 100110 -> XOR
    and (f_xor, funct[5], funct[2], funct[1], not_funct[0]);
    
    // 101010 -> SLT
    and (f_slt, funct[5], funct[3], funct[1], not_funct[0]);

    // --- 2. ALUOp Sinyallerini Çözme ---
    wire alu_op_00, alu_op_01, alu_op_10, alu_op_11;
    wire not_alu_op0, not_alu_op1;

    not (not_alu_op0, alu_op[0]);
    not (not_alu_op1, alu_op[1]);

    and (alu_op_00, not_alu_op1, not_alu_op0); // ADDI (Toplama yap)
    and (alu_op_01, not_alu_op1, alu_op[0]);   // SLTI (SLT yap)
    and (alu_op_10, alu_op[1], not_alu_op0);   // R-Type (Funct'a bak)
    and (alu_op_11, alu_op[1], alu_op[0]);     // Logic I-Type (Funct'a bak - Dokümana göre)

    // --- 3. ALU Control Çıkışlarını Üretme ---
    // Hedef: alu_control[3:0]
    
    // Hangi işlem seçildi?
    wire do_add, do_sub, do_and, do_or, do_xor, do_slt;
    wire r_type_or_logic;
    
    or (r_type_or_logic, alu_op_10, alu_op_11);

    // ADD: (ALUOp=00) OR (ALUOp=1X AND funct=ADD)
    wire r_add;
    and (r_add, r_type_or_logic, f_add);
    or  (do_add, alu_op_00, r_add);

    // SUB: (ALUOp=1X AND funct=SUB)
    and (do_sub, r_type_or_logic, f_sub);

    // AND: (ALUOp=1X AND funct=AND)
    and (do_and, r_type_or_logic, f_and);
    
    // OR: (ALUOp=1X AND funct=OR)
    and (do_or, r_type_or_logic, f_or);
    
    // XOR: (ALUOp=1X AND funct=XOR)
    and (do_xor, r_type_or_logic, f_xor);
    
    // SLT: (ALUOp=01) OR (ALUOp=1X AND funct=SLT)
    wire r_slt;
    and (r_slt, r_type_or_logic, f_slt);
    or  (do_slt, alu_op_01, r_slt);

    // --- Çıkış Kodlaması (Mapping) ---
    // 0000(AND), 0001(OR), 0010(ADD), 0011(XOR), 0110(SUB), 0111(SLT)
    
    // Bit 0: OR(1) | XOR(1) | SLT(1)
    or (alu_control[0], do_or, do_xor, do_slt);
    
    // Bit 1: ADD(1) | XOR(1) | SUB(1) | SLT(1)
    or (alu_control[1], do_add, do_xor, do_sub, do_slt);
    
    // Bit 2: SUB(1) | SLT(1)
    or (alu_control[2], do_sub, do_slt);
    
    // Bit 3: Kullanılmıyor (Hepsi 0)
    assign alu_control[3] = 1'b0;

endmodule