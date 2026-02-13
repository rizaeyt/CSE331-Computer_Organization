module reg_file (
    input wire clk,
    input wire rst,
    input wire we,            // Write Enable (from RegWrite signal)
    input wire [4:0] ra1,     // Read Address 1 (rs)
    input wire [4:0] ra2,     // Read Address 2 (rt)
    input wire [4:0] wa,      // Write Address (rd or rt)
    input wire [31:0] wd,     // Write Data (from Write Back MUX)
    output wire [31:0] rd1,   // Read Data 1 (goes to ALU A)
    output wire [31:0] rd2    // Read Data 2 (goes to ALU B or Memory)
);

    // 1. The Storage
    // We create an array of 32 registers, each 32 bits wide.
    reg [31:0] registers [0:31];

    // 2. Asynchronous Reads (The Combinational Part)
    // The outputs change IMMEDIATELY when ra1 or ra2 changes.
    // IMPORANT: Register 0 is always hardwired to 0.
    assign rd1 = (ra1 == 5'b0) ? 32'b0 : registers[ra1];
    assign rd2 = (ra2 == 5'b0) ? 32'b0 : registers[ra2];

    // 3. Synchronous Write (The Behavioral Part)
    // Writing only happens on the rising edge of the clock.
    integer i;
    always @(posedge clk) begin
        if (rst) begin
            // On Reset: Clear all registers to 0
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end else if (we && (wa != 5'b0)) begin
            // Normal Write:
            // Only write if Enable is ON AND we are not trying to write to Register 0.
            registers[wa] <= wd;
        end
    end

endmodule