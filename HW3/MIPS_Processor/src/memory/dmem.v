// Data memory (behavioral)
module dmem ( 
    input  wire        clk, 
    input  wire        mem_read, 
    input  wire        mem_write, 
    input  wire [31:0] addr,      // word-aligned for lw/sw 
    input  wire [31:0] wd, 
    output wire [31:0] rd 
); 
    // TODO: behavioral array; define read/write timing model
    reg [31:0] ram [0:255];

    // Combinational Read (Word Aligned)
    assign rd = ram[addr[31:2]];

    // Sequential Write
    always @(posedge clk) begin
        if (mem_write) begin
            ram[addr[31:2]] <= wd;
        end
    end
endmodule