module operand_reg_a (

    input  wire        clk,
    input  wire        reset,
    input  wire        AWrite,

    input  wire [31:0] A_in,

    output reg  [31:0] A_out

);

/////////////////////////////////////////////////////////////
// Operand Register A
/////////////////////////////////////////////////////////////

always @(posedge clk) begin

    if (reset)
        A_out <= 32'b0;

    else if (AWrite)
        A_out <= A_in;

end

endmodule