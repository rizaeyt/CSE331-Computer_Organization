module register_file(
    input wire clk,
    input wire reset,
    input wire reg_write,
    input wire [4:0] read_reg1,  // rs
    input wire [4:0] read_reg2,  // rt
    input wire [4:0] write_reg,  // rd veya rt
    input wire [31:0] write_data,
    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);

    // 32 adet 32-bitlik register (Bellek Dizisi)
    reg [31:0] regs [0:31];
    
    integer i;

    // --- Okuma İşlemi (Asenkron/Combinational) [cite: 116] ---
    // Not: $0 her zaman 0 olmalı. Eğer okunan adres 0 ise 0 döndür, değilse diziden oku.
    // Bunu structural yapmak yerine assign operatörüyle yapmak RF içinde serbesttir 
    // veya basitçe regs[0]'ı her zaman 0 tutarız.
    assign read_data1 = (read_reg1 == 0) ? 32'b0 : regs[read_reg1];
    assign read_data2 = (read_reg2 == 0) ? 32'b0 : regs[read_reg2];

    // --- Yazma İşlemi (Senkron) [cite: 94, 114] ---
    always @(posedge clk) begin
        if (reset) begin
            // Reset gelince tüm kayıtları temizle
            for (i = 0; i < 32; i = i + 1) begin
                regs[i] <= 32'b0;
            end
        end
        else if (reg_write) begin
            // $0 register'ına yazmayı engelle (write_reg != 0)
            if (write_reg != 5'b00000) begin
                regs[write_reg] <= write_data;
            end
        end
    end

endmodule