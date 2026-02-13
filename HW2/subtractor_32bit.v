module subtractor_32bit(
    input wire [31:0] a,
    input wire [31:0] b,
    output wire [31:0] difference,
    output wire borrow_out
);

    // Ara kablolar
    wire [32:0] c;          // Carry zinciri
    wire [31:0] b_inverted; // B'nin terslenmiş hali (NOT B)
    wire final_carry;       // Son toplama işleminden çıkan elde

    // Çıkarma işlemi için Two's Complement kuralı gereği:
    // İlk elde girişini (Cin) 1 yapıyoruz. Bu, sonuca +1 ekler.
    assign c[0] = 1'b1;

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : sub_loop
            // 1. Adım: B'nin her bitini tersle (Structural NOT)
            // Behavioral yasak olduğu için (~b yerine) not kapısı kullanıyoruz.
            not inv_gate (b_inverted[i], b[i]);

            // 2. Adım: Full Adder ile topla: A + (~B) + Cin
            FA fa_inst (
                .a(a[i]),            // A'nın i. biti
                .b(b_inverted[i]),   // B'nin TERSLENMİŞ i. biti
                .cin(c[i]),          // Önceki basamaktan gelen elde
                .cout(c[i+1]),       // Sonraki basamağa giden elde
                .s(difference[i])    // Sonuç (Fark)
            );
        end
    endgenerate

    // Carry Out'u alıyoruz
    assign final_carry = c[32];

    // ÖNEMLİ: Çıkarmada Borrow (Borç), Carry Out'un tersidir.
    // Eğer işlem sonunda elde (Carry) çıkarsa, sonuç pozitiftir (Borç yok).
    // Eğer elde çıkmazsa (0), borç alınmış demektir.
    // borrow_out = ~final_carry
    not inv_borrow (borrow_out, final_carry);

endmodule