// PC register (behavioral/sequential)
module pc_reg ( 
    input  wire        clk, 
    input  wire        rst, 
    input  wire [31:0] pc_next, //Adress of next instruction
    output reg  [31:0] pc //Adress of current insturction
); 
    always @(posedge clk) begin
        if(rst) begin
            pc <= 32'b0; //Reset to line 0
        end else begin
            pc <= pc_next; //Move to the next line
        end
    end
endmodule
