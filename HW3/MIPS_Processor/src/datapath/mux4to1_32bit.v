module mux4to1_32bit (
    input wire [31:0] input0,
    input wire [31:0] input1,
    input wire [31:0] input2,
    input wire [31:0] input3,
    input wire [1:0] select,
    output reg [31:0] out
);

    always @(*) begin
        case (select)
            2'b00: out = input0;
            2'b01: out = input1;
            2'b10: out = input2;
            2'b11: out = input3;
            default: out = 32'b0;
        endcase
    end

endmodule