module mux2to1_5bit (
    input wire [4:0] input0,
    input wire [4:0] input1,
    input wire select,
    output wire [4:0] out
);
    // Ternary operator: (Condition) ? True_Value : False_Value
    assign out = select ? input1 : input0;

endmodule