`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/12 20:47:42
// Design Name: 
// Module Name: sign_extender
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SignExtender (

    // Immediate input from instruction
    input  [7:0] Imm_In,

    // Sign-extended output
    output [15:0] Imm_Out

);

assign Imm_Out = {{8{Imm_In[7]}}, Imm_In};

endmodule