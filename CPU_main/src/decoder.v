module Decoder (
    input  [3:0] Opcode,
    output reg [15:0] Decode_Out
);

always @(*) begin
    Decode_Out = 16'b0;
    Decode_Out[Opcode] = 1'b1;  // one-hot
end

endmodule
