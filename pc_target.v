module pc_target (

    input  wire [31:0] pc,
    input  wire [31:0] imm,

    output wire [31:0] target

);

assign target = pc + imm;

endmodule