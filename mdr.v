module mdr (

    input  wire        clk,
    input  wire        reset,
    input  wire        MDRWrite,

    input  wire [31:0] mem_data_in,

    output reg  [31:0] mem_data_out

);

/////////////////////////////////////////////////////////////
// Memory Data Register
/////////////////////////////////////////////////////////////

always @(posedge clk) begin

    if (reset)
        mem_data_out <= 32'b0;

    else if (MDRWrite)
        mem_data_out <= mem_data_in;

end

endmodule