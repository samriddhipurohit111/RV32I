module operand_reg_b (

    input  wire        clk,
    input  wire        reset,
    input  wire        BWrite,

    input  wire [31:0] B_in,

    output reg  [31:0] B_out

);

/////////////////////////////////////////////////////////////
// Operand Register B
/////////////////////////////////////////////////////////////

always @(posedge clk) begin

    if (reset)
        B_out <= 32'b0;

    else if (BWrite)
        B_out <= B_in;

end

endmodule