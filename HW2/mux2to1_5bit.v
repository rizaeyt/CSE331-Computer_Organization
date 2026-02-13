module mux2to1_5bit(
    input wire [4:0] input0,
    input wire [4:0] input1,
    input wire select,
    output wire [4:0] out
);
    // 32-bit Mux mantığının aynısı, sadece 5 döngü
    genvar i;
    generate
        for (i = 0; i < 5; i = i + 1) begin : mux5_loop
            wire not_sel, a_ns, b_s;
            not (not_sel, select);
            and (a_ns, input0[i], not_sel);
            and (b_s, input1[i], select);
            or  (out[i], a_ns, b_s);
        end
    endgenerate
endmodule