`timescale 1ns/1ps
module mips_cpu_tb; 
    reg  clk = 0; 
    reg  rst = 1; 
    wire [31:0] dbg_pc; 
    wire [31:0] dbg_instr; 
 
    // Clock gen 
    always #5 clk = ~clk; 
 
    // DUT 
    mips_cpu dut ( 
        .clk(clk), 
        .rst(rst), 
        .dbg_pc(dbg_pc), 
        .dbg_instr(dbg_instr) 
    ); 
 
    // Reset and run 
    initial begin 
        rst = 1; 
        repeat (2) @(posedge clk); 
        rst = 0; 
 
        // Run for fixed cycles or until a sentinel condition 
        repeat (2000) @(posedge clk); 
        $display("TIMEOUT: Test did not complete"); 
        $finish; 
    end 

    initial begin
        $monitor("Time=%0t PC=%h Instr=%h", $time, dbg_pc, dbg_instr);
    end
endmodule
