// Instruction memory (behavioral for simulation; ROM-like)
module imem ( 
    input  wire [31:0] addr,      // word-aligned 
    output wire [31:0] instr 
); 
    // TODO: behavioral read; $readmemh for initialization
    reg [31:0] memory [0:255]; // Create a memory of 256 lines (increase if your program is huge)

    // Initialize memory from a file
    initial begin
        $readmemh("prog.hex", memory);
        if (memory[0] === 32'bx) begin
            $display("Warning: prog.hex not loaded or empty, initializing with NOPs");
            memory[0] = 32'h00000000; // NOP
        end
    end


    // Read logic (Word Aligned: ignore the last 2 bits)
    assign instr = memory[addr[31:2]];
    /*MIPS instructions are 4 bytes long.
    addr increments by 4 (0, 4, 8...).
    However, our array index increments by 1.
    So we divide the address by 4 (which is addr[31:2]).*/
endmodule
