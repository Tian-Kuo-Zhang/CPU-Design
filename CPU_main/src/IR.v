module IR (
    input clk,
    input reset,
    input [15:0] instruction_in,

    output reg [15:0] instr,
    output [3:0] opcode,
    output [1:0] rd,
    output [1:0] rs,
    output [1:0] rt,
    output [7:0] imm,
    output [5:0] funct
);

always @(posedge clk or posedge reset) begin
    if (reset)
        instr <= 16'b0;              // reset
    else
        instr <= instruction_in;     // latch instruction
end

assign opcode = instr[15:12]; 
assign rd     = instr[11:10]; 
assign rs     = instr[9:8]; 
assign rt     = instr[7:6]; 
assign imm    = instr[7:0]; 
assign funct  = instr[5:0];

endmodule
