module control_unit (

    input  wire [6:0] opcode,
    input  wire [2:0] funct3,

    output reg        RegWrite,
    output reg        ALUSrc,
    output reg        MemRead,
    output reg        MemWrite,
    output reg        Branch,
    output reg        Jump,
    output reg        Jalr,
    output reg        Lui,
    output reg        Auipc,
    output reg        MemtoReg,

    output reg [1:0]  ALUOp,
    output reg [2:0]  BranchType,
    output reg [1:0]  ResultSrc

);

/////////////////////////////////////////////////////////////
// Opcode Definitions
/////////////////////////////////////////////////////////////

localparam OPCODE_RTYPE   = 7'b0110011;
localparam OPCODE_ITYPE   = 7'b0010011;

localparam OPCODE_LOAD    = 7'b0000011;
localparam OPCODE_STORE   = 7'b0100011;

localparam OPCODE_BRANCH  = 7'b1100011;

localparam OPCODE_JAL     = 7'b1101111;
localparam OPCODE_JALR    = 7'b1100111;

localparam OPCODE_LUI     = 7'b0110111;
localparam OPCODE_AUIPC   = 7'b0010111;

/////////////////////////////////////////////////////////////
// Combinational Decode
/////////////////////////////////////////////////////////////

always @(*) begin

    //////////////////////////////////////////////////////////
    // Default Assignments
    //////////////////////////////////////////////////////////

    RegWrite  = 1'b0;
    ALUSrc    = 1'b0;
    MemRead   = 1'b0;
    MemWrite  = 1'b0;
    Branch    = 1'b0;
    Jump      = 1'b0;
    Jalr      = 1'b0;
    Lui       = 1'b0;
    Auipc     = 1'b0;
    MemtoReg  = 1'b0;

    ALUOp     = 2'b00;
    BranchType = 3'b000;
    ResultSrc  = 2'b00;

    //////////////////////////////////////////////////////////
    // Opcode Decode
    //////////////////////////////////////////////////////////

    case (opcode)

        //////////////////////////////////////////////////////
        // R-Type
        //////////////////////////////////////////////////////

        OPCODE_RTYPE:
        begin
            RegWrite = 1'b1;
            ALUSrc   = 1'b0;
            ALUOp    = 2'b10;
            ResultSrc = 2'b00;
        end

        //////////////////////////////////////////////////////
        // I-Type Arithmetic
        //////////////////////////////////////////////////////

        OPCODE_ITYPE:
        begin
            RegWrite = 1'b1;
            ALUSrc   = 1'b1;
            ALUOp    = 2'b10;
            ResultSrc = 2'b00;
        end

        //////////////////////////////////////////////////////
        // LOAD
        //////////////////////////////////////////////////////

        OPCODE_LOAD:
        begin
            RegWrite = 1'b1;
            ALUSrc   = 1'b1;
            MemRead  = 1'b1;
            ALUOp    = 2'b00;
            MemtoReg = 1'b1;
            ResultSrc = 2'b01;
        end

        //////////////////////////////////////////////////////
        // STORE
        //////////////////////////////////////////////////////

        OPCODE_STORE:
        begin
            ALUSrc   = 1'b1;
            MemWrite = 1'b1;
            ALUOp    = 2'b00;
        end

        //////////////////////////////////////////////////////
        // BRANCH
        //////////////////////////////////////////////////////

        OPCODE_BRANCH:
        begin
            Branch    = 1'b1;
            ALUOp     = 2'b01;
            BranchType = funct3;
        end

        //////////////////////////////////////////////////////
        // JAL
        //////////////////////////////////////////////////////

        OPCODE_JAL:
        begin
            RegWrite = 1'b1;
            Jump     = 1'b1;
            ResultSrc = 2'b10;
        end

        //////////////////////////////////////////////////////
        // JALR
        //////////////////////////////////////////////////////

        OPCODE_JALR:
        begin
            RegWrite = 1'b1;
            Jump     = 1'b1;
            Jalr     = 1'b1;
            ALUSrc   = 1'b1;
            ResultSrc = 2'b10;
        end

        //////////////////////////////////////////////////////
        // LUI
        //////////////////////////////////////////////////////

        OPCODE_LUI:
        begin
            RegWrite = 1'b1;
            Lui      = 1'b1;
            ResultSrc = 2'b11;
        end

        //////////////////////////////////////////////////////
        // AUIPC
        //////////////////////////////////////////////////////

        OPCODE_AUIPC:
        begin
            RegWrite = 1'b1;
            Auipc    = 1'b1;
            ALUSrc   = 1'b1;
            ResultSrc = 2'b00;
        end

        //////////////////////////////////////////////////////
        // Default
        //////////////////////////////////////////////////////

        default:
        begin
        end

    endcase

end

endmodule