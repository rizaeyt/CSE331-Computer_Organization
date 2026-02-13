module control_unit(
    input wire [5:0] opcode,
    output wire reg_dst,
    output wire alu_src,
    output wire reg_write,
    output wire [1:0] alu_op
);

    // --- 1. Opcode Decoding (Komutun ne olduğunu anlama) ---
    // Opcode bitlerinin terslerini (NOT) alalım, böylece AND kapılarıyla seçim yapabiliriz.
    wire [5:0] not_opcode;
    genvar i;
    generate
        for (i = 0; i < 6; i = i + 1) begin : inv_op
            not u_not (not_opcode[i], opcode[i]);
        end
    endgenerate

    wire is_r_type, is_addi, is_andi, is_ori, is_xori, is_slti;

    // R-Type (Opcode: 000000) -> Hepsi 0 olmalı
    and u_r (is_r_type, not_opcode[5], not_opcode[4], not_opcode[3], not_opcode[2], not_opcode[1], not_opcode[0]);

    // ADDI (Opcode: 001000) -> Sadece bit[3] 1
    and u_addi (is_addi, not_opcode[5], not_opcode[4], opcode[3], not_opcode[2], not_opcode[1], not_opcode[0]);

    // ANDI (Opcode: 001100) -> bit[3] ve bit[2] 1
    and u_andi (is_andi, not_opcode[5], not_opcode[4], opcode[3], opcode[2], not_opcode[1], not_opcode[0]);

    // ORI (Opcode: 001101) -> bit[3], bit[2], bit[0] 1
    and u_ori (is_ori, not_opcode[5], not_opcode[4], opcode[3], opcode[2], not_opcode[1], opcode[0]);

    // XORI (Opcode: 001110) -> bit[3], bit[2], bit[1] 1
    and u_xori (is_xori, not_opcode[5], not_opcode[4], opcode[3], opcode[2], opcode[1], not_opcode[0]);

    // SLTI (Opcode: 001010) -> bit[3] ve bit[1] 1
    and u_slti (is_slti, not_opcode[5], not_opcode[4], opcode[3], not_opcode[2], opcode[1], not_opcode[0]);


    // --- 2. Control Signals Generation (Sinyalleri Üretme) ---

    // RegDst: Sadece R-type instruction'da 1 olur.
    // Tablo: R-type(1), diğerleri(0)
    assign reg_dst = is_r_type;

    // ALUSrc: R-type hariç diğerlerinde (I-type) 1 olur.
    // Logic: (ADDI | ANDI | ORI | XORI | SLTI) -> Aslında (~is_r_type) da olur ama structural OR kuralım.
    or u_alusrc (alu_src, is_addi, is_andi, is_ori, is_xori, is_slti);

    // RegWrite: Bu projede desteklenen TÜM komutlar register'a yazar. (Branch/Jump yok)
    // Tablo: Hepsi 1.
    assign reg_write = 1'b1; 

    // ALUOp[1]: R-type, ANDI, ORI, XORI
    // Tabloya bakarsak: R-type(10), ANDI/ORI/XORI(11). Yani bu komutlarda Op[1] biti 1.
    or u_aluop1 (alu_op[1], is_r_type, is_andi, is_ori, is_xori);

    // ALUOp[0]: SLTI, ANDI, ORI, XORI
    // Tabloya bakarsak: SLTI(01), ANDI/ORI/XORI(11).
    or u_aluop0 (alu_op[0], is_slti, is_andi, is_ori, is_xori);

endmodule
