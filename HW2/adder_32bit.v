module adder_32bit(
 input wire [31:0] a,
 input wire [31:0] b,
 output wire [31:0] sum,
 output wire carry_out
); 

wire [32:0] c;
assign c[0] = 1'b0;
genvar i;
generate
        for (i = 0; i < 32; i = i + 1) begin : adder_loop
            // FA modülünü çağırıyoruz (Instantiation)
            // Her döngüde i. bitleri birbirine bağlıyoruz.
            FA fa_inst (
                .a(a[i]),        // A'nın i. biti
                .b(b[i]),        // B'nin i. biti
                .cin(c[i]),      // Bir önceki basamaktan gelen elde
                .cout(c[i+1]),   // Bir sonraki basamağa giden elde
                .s(sum[i])       // Sonuç toplamın i. biti
            );
        end
    endgenerate

    // En son basamaktan çıkan elde (32. bit), modülün carry_out çıkışıdır.
    assign carry_out = c[32];

endmodule