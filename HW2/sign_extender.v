module sign_extender(
    input wire [15:0] immediate_in,
    output wire [31:0] immediate_out
);

    genvar i;
    generate
        // Alt 16 bit: Doğrudan kopyalanır (immediate_in[0] -> immediate_out[0])
        for (i = 0; i < 16; i = i + 1) begin : copy_lower
            assign immediate_out[i] = immediate_in[i];
        end

        // Üst 16 bit: İşaret biti (15. bit) kopyalanır (immediate_in[15] -> immediate_out[16...31])
        for (i = 16; i < 32; i = i + 1) begin : extend_sign
            assign immediate_out[i] = immediate_in[15];
        end
    endgenerate

endmodule