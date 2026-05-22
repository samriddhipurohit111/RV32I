module controller_fsm (

    input  wire        clk,
    input  wire        reset,

    input  wire [6:0]  opcode,

    output reg         IRWrite,
    output reg         PCWrite,

    output reg         AWrite,
    output reg         BWrite,

    output reg         ALUOutWrite,
    output reg         MDRWrite,

    output reg         RegWrite,

    output reg         MemRead,
    output reg         MemWrite,

    output reg [2:0]   state

);

/////////////////////////////////////////////////////////////
// State Encoding
/////////////////////////////////////////////////////////////

localparam STATE_FETCH      = 3'b000;
localparam STATE_DECODE     = 3'b001;
localparam STATE_EXECUTE    = 3'b010;
localparam STATE_MEMORY     = 3'b011;
localparam STATE_WRITEBACK  = 3'b100;

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
// State Register
/////////////////////////////////////////////////////////////

reg [2:0] next_state;

always @(posedge clk) begin

    if (reset)
        state <= STATE_FETCH;

    else
        state <= next_state;

end

/////////////////////////////////////////////////////////////
// Next State Logic
/////////////////////////////////////////////////////////////

always @(*) begin

    //////////////////////////////////////////////////////////
    // Default
    //////////////////////////////////////////////////////////

    next_state = STATE_FETCH;

    case (state)

        //////////////////////////////////////////////////////
        // FETCH
        //////////////////////////////////////////////////////

        STATE_FETCH:
        begin
            next_state = STATE_DECODE;
        end

        //////////////////////////////////////////////////////
        // DECODE
        //////////////////////////////////////////////////////

        STATE_DECODE:
        begin
            next_state = STATE_EXECUTE;
        end

        //////////////////////////////////////////////////////
        // EXECUTE
        //////////////////////////////////////////////////////

        STATE_EXECUTE:
        begin

            case (opcode)

                //////////////////////////////////////////////////
                // LOAD / STORE
                //////////////////////////////////////////////////

                OPCODE_LOAD,
                OPCODE_STORE:
                begin
                    next_state = STATE_MEMORY;
                end

                //////////////////////////////////////////////////
                // BRANCH
                //////////////////////////////////////////////////

                OPCODE_BRANCH:
                begin
                    next_state = STATE_FETCH;
                end

                //////////////////////////////////////////////////
                // JAL / JALR
                //////////////////////////////////////////////////

                OPCODE_JAL,
                OPCODE_JALR:
                begin
                    next_state = STATE_WRITEBACK;
                end

                //////////////////////////////////////////////////
                // LUI / AUIPC
                //////////////////////////////////////////////////

                OPCODE_LUI,
                OPCODE_AUIPC:
                begin
                    next_state = STATE_WRITEBACK;
                end

                //////////////////////////////////////////////////
                // R-Type / I-Type
                //////////////////////////////////////////////////

                default:
                begin
                    next_state = STATE_WRITEBACK;
                end

            endcase

        end

        //////////////////////////////////////////////////////
        // MEMORY
        //////////////////////////////////////////////////////

        STATE_MEMORY:
        begin

            if (opcode == OPCODE_LOAD)
                next_state = STATE_WRITEBACK;

            else
                next_state = STATE_FETCH;

        end

        //////////////////////////////////////////////////////
        // WRITEBACK
        //////////////////////////////////////////////////////

        STATE_WRITEBACK:
        begin
            next_state = STATE_FETCH;
        end

        //////////////////////////////////////////////////////
        // Default
        //////////////////////////////////////////////////////

        default:
        begin
            next_state = STATE_FETCH;
        end

    endcase

end

/////////////////////////////////////////////////////////////
// Output Control Logic
/////////////////////////////////////////////////////////////

always @(*) begin

    //////////////////////////////////////////////////////////
    // Default Outputs
    //////////////////////////////////////////////////////////

    IRWrite     = 1'b0;
    PCWrite     = 1'b0;

    AWrite      = 1'b0;
    BWrite      = 1'b0;

    ALUOutWrite = 1'b0;
    MDRWrite    = 1'b0;

    RegWrite    = 1'b0;

    MemRead     = 1'b0;
    MemWrite    = 1'b0;

    //////////////////////////////////////////////////////////
    // State-Based Control
    //////////////////////////////////////////////////////////

    case (state)

        //////////////////////////////////////////////////////
        // FETCH
        //////////////////////////////////////////////////////

        STATE_FETCH:
        begin

            MemRead = 1'b1;
            IRWrite = 1'b1;
            PCWrite = 1'b1;

        end

        //////////////////////////////////////////////////////
        // DECODE
        //////////////////////////////////////////////////////

        STATE_DECODE:
        begin

            AWrite = 1'b1;
            BWrite = 1'b1;

        end

        //////////////////////////////////////////////////////
        // EXECUTE
        //////////////////////////////////////////////////////

        STATE_EXECUTE:
        begin

            ALUOutWrite = 1'b1;

        end

        //////////////////////////////////////////////////////
        // MEMORY
        //////////////////////////////////////////////////////

        STATE_MEMORY:
        begin

            if (opcode == OPCODE_LOAD) begin

                MemRead = 1'b1;
                MDRWrite = 1'b1;

            end

            else if (opcode == OPCODE_STORE) begin

                MemWrite = 1'b1;

            end

        end

        //////////////////////////////////////////////////////
        // WRITEBACK
        //////////////////////////////////////////////////////

        STATE_WRITEBACK:
        begin

            case (opcode)

                //////////////////////////////////////////////////
                // Instructions that write register file
                //////////////////////////////////////////////////

                OPCODE_RTYPE,
                OPCODE_ITYPE,
                OPCODE_LOAD,
                OPCODE_JAL,
                OPCODE_JALR,
                OPCODE_LUI,
                OPCODE_AUIPC:
                begin
                    RegWrite = 1'b1;
                end

            endcase

        end

    endcase

end

endmodule