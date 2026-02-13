`timescale 1ns / 1ps

module testbench;

    // Sinyal Tanımları
    reg clk;
    reg reset;
    reg [31:0] instruction;
    wire [31:0] alu_result;
    wire [31:0] write_data;

    // Instantiate datapath (MIPS Modülünü Çağır)
    mips_single_cycle_datapath uut(
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .alu_result(alu_result),
        .write_data(write_data)
    );

    // Clock generation (Saat Sinyali)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns periyot
    end

    // Test sequence (Test Senaryosu)
    initial begin
        // --- Dalga Formu Çıktısı İçin Gerekli Satırlar ---
        $dumpfile("mips_test.vcd"); // Çıktı dosyasının adı
        $dumpvars(0, testbench);    // Tüm sinyalleri kaydet

        // Reset
        reset = 1;
        instruction = 32'h00000000;
        #10 reset = 0;

        // Test 1: addi $1, $0, 10 (R1 = 10)
        // opcode=001000, rs=00000, rt=00001, imm=10
        instruction = 32'b001000_00000_00001_0000000000001010;
        #10;
        $display("Time: %0t | ADDI: R1 should be 10, Result = %d", $time, write_data);

        // Test 2: addi $2, $0, 20 (R2 = 20)
        instruction = 32'b001000_00000_00010_0000000000010100;
        #10;
        // (Buradaki "12 / 15" yazısı silindi, hataya sebep oluyordu)
        $display("Time: %0t | ADDI: R2 should be 20, Result = %d", $time, write_data);

        // Test 3: add $3, $1, $2 (R3 = R1 + R2 = 30)
        // opcode=000000, rs=00001, rt=00010, rd=00011, shamt=00000, funct=100000
        instruction = 32'b000000_00001_00010_00011_00000_100000;
        #10;
        $display("Time: %0t | ADD:  R3 should be 30, Result = %d", $time, write_data);

        // Test 4: sub $4, $2, $1 (R4 = R2 - R1 = 10)
        instruction = 32'b000000_00010_00001_00100_00000_100010;
        #10;
        $display("Time: %0t | SUB:  R4 should be 10, Result = %d", $time, write_data);

        // Test 5: and $5, $1, $2 (R5 = R1 & R2)
        instruction = 32'b000000_00001_00010_00101_00000_100100;
        #10;
        $display("Time: %0t | AND:  R5 should be 0,  Result = %d", $time, write_data);

        // Test 6: ori $6, $5, 5 (R6 = R5 | 5)
        instruction = 32'b001101_00101_00110_0000000000000101;
        #10;
        $display("Time: %0t | ORI:  R6 should be 5,  Result = %d", $time, write_data);

        #10;
        $finish;
    end
endmodule