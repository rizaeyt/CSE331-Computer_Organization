module mux2to1_32bit (
    input wire [31:0] input0,
    input wire [31:0] input1,
    input wire select,
    output wire [31:0] out
);

    assign out = select ? input1 : input0;

endmodule