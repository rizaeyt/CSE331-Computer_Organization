// Simple adder module (combinational)
module add32 ( 
    input  wire [31:0] a, 
    input  wire [31:0] b, 
    output wire [31:0] y 
); 
    // TODO: assign y = a + b;
    assign y = a + b;
endmodule
