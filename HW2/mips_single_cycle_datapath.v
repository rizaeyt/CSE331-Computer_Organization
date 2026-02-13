module mips_single_cycle_datapath(
    input wire clk,
    input wire reset,
    input wire [31:0] instruction,
    output wire [31:0] alu_result,
    output wire [31:0] write_data
);

    // --- Sinyal Tanımları (Wire Declarations) ---
    // Instruction Parçaları [cite: 292-311]
    wire [5:0] opcode = instruction[31:26];
    wire [4:0] rs     = instruction[25:21];
    wire [4:0] rt     = instruction[20:16];
    wire [4:0] rd     = instruction[15:11];
    wire [5:0] funct  = instruction[5:0];
    wire [15:0] imm   = instruction[15:0];

    // Kontrol Sinyalleri
    wire reg_dst, alu_src, reg_write;
    wire [1:0] alu_op;
    wire [3:0] alu_control_sig;
    wire zero_flag; // Kullanılmıyor ama ALU çıkışı için gerekli

    // Datapath Kabloları
    wire [31:0] read_data1;
    wire [31:0] read_data2;
    wire [31:0] imm_extended;
    wire [31:0] alu_input_b;
    wire [4:0]  write_reg_addr;

    // --- Modül Bağlantıları (Instantiation) ---

    // 1. Control Unit
    control_unit ctrl_unit (
        .opcode(opcode),
        .reg_dst(reg_dst),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .alu_op(alu_op)
    );

    // 2. Write Register MUX (5-bit) -> rt veya rd seçimi
    // Dokümanda mux2to1_5bit istenmişti. Basitlik için burada wire assign yerine onu çağırmalıydık 
    // ama daha önce yazmadık. 
    // *Buraya dikkat*: Eğer mux2to1_5bit yazmadıysanız yazmalısınız. 
    // Hızlıca structural 5-bit mux örneği (ya da proje dosyasında varsa onu kullanın):
    mux2to1_5bit reg_dst_mux (
        .input0(rt),    // I-type (0)
        .input1(rd),    // R-type (1)
        .select(reg_dst),
        .out(write_reg_addr)
    );

    // 3. Register File
    register_file rf (
        .clk(clk),
        .reset(reset),
        .reg_write(reg_write),
        .read_reg1(rs),
        .read_reg2(rt),
        .write_reg(write_reg_addr),
        .write_data(write_data), // ALU sonucu geri yazılır
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // 4. Sign Extender
    sign_extender se (
        .immediate_in(imm),
        .immediate_out(imm_extended)
    );

    // 5. ALU Source MUX (32-bit) -> Register B veya Immediate
    mux2to1_32bit alu_src_mux (
        .input0(read_data2),   // Register'dan gelen
        .input1(imm_extended), // Immediate'den gelen
        .select(alu_src),
        .out(alu_input_b)
    );

    // 6. ALU Control
    alu_control alu_ctrl (
        .alu_op(alu_op),
        .funct(funct),
        .alu_control(alu_control_sig)
    );

    // 7. ALU
    alu main_alu (
        .a(read_data1),
        .b(alu_input_b), // Mux çıkışı
        .alu_control(alu_control_sig),
        .result(alu_result),
        .zero(zero_flag)
    );

    // Çıkış Ataması: Yazılacak veri ALU sonucudur.
    // (Load instruction olmadığı için data memory yok)
    assign write_data = alu_result;

endmodule