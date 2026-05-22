module jalr_target (

    input  wire [31:0] rs1,
    input  wire [31:0] imm,

    output wire [31:0] target

);

assign target = (rs1 + imm) & 32'hFFFFFFFE;

endmodule