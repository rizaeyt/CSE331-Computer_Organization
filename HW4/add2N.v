module add2N #(
    parameter N = 32
)(
    input  wire [2*N-1:0] a,
    input  wire [2*N-1:0] b,
    output wire [2*N-1:0] y
);
    assign y = a + b;
endmodule