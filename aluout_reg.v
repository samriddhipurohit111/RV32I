module aluout_reg (

    input  wire        clk,
    input  wire        reset,
    input  wire        ALUOutWrite,

    input  wire [31:0] alu_result_in,

    output reg  [31:0] alu_result_out

);

/////////////////////////////////////////////////////////////
// ALU Output Register
/////////////////////////////////////////////////////////////

always @(posedge clk) begin

    if (reset)
        alu_result_out <= 32'b0;

    else if (ALUOutWrite)
        alu_result_out <= alu_result_in;

end

endmodule