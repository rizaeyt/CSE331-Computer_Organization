module mux2to1_32bit(
    input wire [31:0] input0, // Select 0 iken seçilir
    input wire [31:0] input1, // Select 1 iken seçilir
    input wire select,
    output wire [31:0] out
);
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : mux_loop
            wire not_sel;
            wire a_and_notsel;
            wire b_and_sel;

            // Yapısal Mux Mantığı: Y = (A & ~S) | (B & S)
            not inv1 (not_sel, select);
            and and1 (a_and_notsel, input0[i], not_sel);
            and and2 (b_and_sel, input1[i], select);
            or  or1  (out[i], a_and_notsel, b_and_sel);
        end
    endgenerate
endmodule