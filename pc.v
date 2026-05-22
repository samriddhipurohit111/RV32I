module pc (

    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] pc_in,

    output reg  [31:0] pc_out

);

/////////////////////////////////////////////////////////////
// Sequential PC Register
/////////////////////////////////////////////////////////////

always @(posedge clk) begin

    if (reset)
        pc_out <= 32'b0;

    else
        pc_out <= pc_in;

end

endmodule