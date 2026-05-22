module ir (

    input  wire        clk,
    input  wire        reset,
    input  wire        IRWrite,

    input  wire [31:0] instr_in,

    output reg  [31:0] instr_out

);

/////////////////////////////////////////////////////////////
// Instruction Register
/////////////////////////////////////////////////////////////

always @(posedge clk) begin

    if (reset)
        instr_out <= 32'b0;

    else if (IRWrite)
        instr_out <= instr_in;

end

endmodule