module immgen (
    input  wire [31:0] instr,
    output reg  [31:0] imm_out
);

/////////////////////////////////////////////////////////////
// Opcode Definitions
/////////////////////////////////////////////////////////////

localparam OPCODE_LOAD    = 7'b0000011;
localparam OPCODE_OPIMM   = 7'b0010011;
localparam OPCODE_JALR    = 7'b1100111;

localparam OPCODE_STORE   = 7'b0100011;

localparam OPCODE_BRANCH  = 7'b1100011;

localparam OPCODE_LUI     = 7'b0110111;
localparam OPCODE_AUIPC   = 7'b0010111;

localparam OPCODE_JAL     = 7'b1101111;

/////////////////////////////////////////////////////////////
// Immediate Generation
/////////////////////////////////////////////////////////////

always @(*) begin

    // Default assignment
    imm_out = 32'b0;

    case (instr[6:0])

        //////////////////////////////////////////////////////
        // I-Type
        // LOAD / OP-IMM / JALR
        //////////////////////////////////////////////////////

        OPCODE_LOAD,
        OPCODE_OPIMM,
        OPCODE_JALR:
        begin
            imm_out = {{20{instr[31]}}, instr[31:20]};
        end

        //////////////////////////////////////////////////////
        // S-Type
        // STORE
        //////////////////////////////////////////////////////

        OPCODE_STORE:
        begin
            imm_out = {
                        {20{instr[31]}},
                        instr[31:25],
                        instr[11:7]
                      };
        end

        //////////////////////////////////////////////////////
        // B-Type
        // BRANCH
        //////////////////////////////////////////////////////

        OPCODE_BRANCH:
        begin
            imm_out = {
                        {19{instr[31]}},
                        instr[31],
                        instr[7],
                        instr[30:25],
                        instr[11:8],
                        1'b0
                      };
        end

        //////////////////////////////////////////////////////
        // U-Type
        // LUI / AUIPC
        //////////////////////////////////////////////////////

        OPCODE_LUI,
        OPCODE_AUIPC:
        begin
            imm_out = {
                        instr[31:12],
                        12'b0
                      };
        end

        //////////////////////////////////////////////////////
        // J-Type
        // JAL
        //////////////////////////////////////////////////////

        OPCODE_JAL:
        begin
            imm_out = {
                        {11{instr[31]}},
                        instr[31],
                        instr[19:12],
                        instr[20],
                        instr[30:21],
                        1'b0
                      };
        end

        //////////////////////////////////////////////////////
        // Default
        //////////////////////////////////////////////////////

        default:
        begin
            imm_out = 32'b0;
        end

    endcase

end

endmodule