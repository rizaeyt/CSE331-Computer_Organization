module alu(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [3:0] alu_control, // [2:0] seçim için kullanılır
    output wire [31:0] result,
    output wire zero
);

    // --- 1. Aritmetik ve Mantıksal Sonuçları Tutan Kablolar ---
    wire [31:0] add_res, sub_res, and_res, or_res, xor_res, slt_res;
    wire cout_add, bout_sub; // Bu projede kullanılmıyor ama modül gereği bağlıyoruz

    // --- 2. Operasyon Modüllerinin Bağlanması ---

    // ADDER (Opcode: 0010)
    adder_32bit adder_inst (
        .a(a), .b(b), .sum(add_res), .carry_out(cout_add)
    );

    // SUBTRACTOR (Opcode: 0110)
    subtractor_32bit sub_inst (
        .a(a), .b(b), .difference(sub_res), .borrow_out(bout_sub)
    );

    // LOGIC OPERATIONS (AND, OR, XOR) - Kapı Dizileri
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : logic_loop
            and u_and (and_res[i], a[i], b[i]); // Opcode: 0000
            or  u_or  (or_res[i], a[i], b[i]);  // Opcode: 0001
            xor u_xor (xor_res[i], a[i], b[i]); // Opcode: 0011
        end
    endgenerate

    // SLT OPERATION (Set Less Than - Opcode: 0111)
    // Mantık: a < b ise (a - b) negatiftir.
    // Negatif sayılarda en sol bit (MSB - bit 31) 1 olur.
    // Structural olarak: Sonucun 0. bitine 'sub_res[31]'i bağla, diğerlerini 0 yap (toprakla).
    assign slt_res[0] = sub_res[31]; 
    // Geri kalan 31 biti 0'a çekmek için generate loop (assign slt_res[31:1] = 0 yasak olabilir)
    generate
        for (i = 1; i < 32; i = i + 1) begin : slt_zeros
            // Verilog'da 0 mantıksal değeri için özel primitive yoktur, 
            // ama 'supply0' veya 'buf' ile topraklama yapılabilir. 
            // Basitçe wire ataması structural sayılabilir ama biz garanti olsun diye buffer kullanalım.
            // Alternatif: assign slt_res[i] = 1'b0; (Basit wire atamalarına izin var [cite: 13])
            assign slt_res[i] = 1'b0; 
        end
    endgenerate

    // --- 3. Sonuç Seçimi (Multiplexer Tree) ---
    // alu_control sinyaline göre doğru sonucu seçmeliyiz.
    // Kodlar: AND(000), OR(001), ADD(010), XOR(011), SUB(110), SLT(111)
    
    wire [31:0] mux_out_0, mux_out_1, mux_out_2, mux_out_3;
    wire [31:0] final_res_0, final_res_1;

    // Kademe 1: 8 giriş -> 4 çıkış (Select bit 0)
    mux2to1_32bit m1 (and_res, or_res,  alu_control[0], mux_out_0); // 000 vs 001
    mux2to1_32bit m2 (add_res, xor_res, alu_control[0], mux_out_1); // 010 vs 011
    mux2to1_32bit m3 (32'b0,   32'b0,   alu_control[0], mux_out_2); // 100 vs 101 (Kullanılmıyor)
    mux2to1_32bit m4 (sub_res, slt_res, alu_control[0], mux_out_3); // 110 vs 111

    // Kademe 2: 4 giriş -> 2 çıkış (Select bit 1)
    mux2to1_32bit m5 (mux_out_0, mux_out_1, alu_control[1], final_res_0); // 00x vs 01x
    mux2to1_32bit m6 (mux_out_2, mux_out_3, alu_control[1], final_res_1); // 10x vs 11x

    // Kademe 3: 2 giriş -> 1 çıkış (Select bit 2)
    mux2to1_32bit m7 (final_res_0, final_res_1, alu_control[2], result);  // 0xx vs 1xx

    // --- 4. Zero Flag ---
    // Sonuç 0 ise zero = 1. Yani tüm bitlerin OR'lanmış halinin tersi (NOR).
    // Structural olarak 32 girişli NOR primitive'i kullanabiliriz.
    nor u_zero (zero, 
        result[0], result[1], result[2], result[3],
        result[4], result[5], result[6], result[7],
        result[8], result[9], result[10], result[11],
        result[12], result[13], result[14], result[15],
        result[16], result[17], result[18], result[19],
        result[20], result[21], result[22], result[23],
        result[24], result[25], result[26], result[27],
        result[28], result[29], result[30], result[31]
    );

endmodule