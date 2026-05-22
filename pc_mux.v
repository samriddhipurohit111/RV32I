module pc_mux (

    input  wire [1:0]  PCSel,

    input  wire [31:0] pc_plus4,
    input  wire [31:0] branch_target,
    input  wire [31:0] jalr_target,

    output reg  [31:0] pc_next

);

always @(*) begin

    case (PCSel)

        //////////////////////////////////////////////////////
        // PC + 4
        //////////////////////////////////////////////////////

        2'b00:
        begin
            pc_next = pc_plus4;
        end

        //////////////////////////////////////////////////////
        // Branch / JAL Target
        //////////////////////////////////////////////////////

        2'b01:
        begin
            pc_next = branch_target;
        end

        //////////////////////////////////////////////////////
        // JALR Target
        //////////////////////////////////////////////////////

        2'b10:
        begin
            pc_next = jalr_target;
        end

        //////////////////////////////////////////////////////
        // Default
        //////////////////////////////////////////////////////

        default:
        begin
            pc_next = pc_plus4;
        end

    endcase

end

endmodule