`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/22 17:29:49
// Design Name: 
// Module Name: RAM
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


module RAM(
    input [15:0] ram_addr_out,  
    input [15:0] ram_wdata_out, 
    input MemWrite,             
    input MemRead,              
    input clk,                  // only clk can drive storage
    output reg [15:0] ram_rdata_in // data output to CPU
    );


    reg [15:0] data_mem [0:255]; 

    // --- sync write ---
    // At the rising edge of the clock, if memwrite is 1, the data is stored
    always @(posedge clk) begin
        if (MemWrite == 1'b1) begin
            data_mem[ram_addr_out[7:0]] <= ram_wdata_out;
        end
    end

    // --- sync read ---
    // At the rising edge of the clock, if memread is 1, the data corresponding to the address is output
    always @(posedge clk) begin
        if (MemRead == 1'b1) begin
            ram_rdata_in <= data_mem[ram_addr_out[7:0]];
        end
        else begin
            // when not read, keep it 0 to prevent the chaos in bus
            ram_rdata_in <= 16'h0000;
        end
    end

endmodule