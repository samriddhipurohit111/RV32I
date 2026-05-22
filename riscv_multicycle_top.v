module riscv_multicycle_top (

    input wire clk,
    input wire reset

);

/////////////////////////////////////////////////////////////
// STATE DEFINITIONS
/////////////////////////////////////////////////////////////

localparam STATE_FETCH      = 3'b000;
localparam STATE_DECODE     = 3'b001;
localparam STATE_EXECUTE    = 3'b010;
localparam STATE_MEMORY     = 3'b011;
localparam STATE_WRITEBACK  = 3'b100;

/////////////////////////////////////////////////////////////
// OPCODE DEFINITIONS
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
// CONTROLLER SIGNALS
/////////////////////////////////////////////////////////////

wire        IRWrite;
wire        PCWrite;

wire        AWrite;
wire        BWrite;

wire        ALUOutWrite;
wire        MDRWrite;

wire        RegWrite;

wire        MemRead;
wire        MemWrite;

wire [2:0]  state;

/////////////////////////////////////////////////////////////
// PROGRAM COUNTER
/////////////////////////////////////////////////////////////

wire [31:0] pc_current;
wire [31:0] pc_next;

pc PC (

    .clk    (clk),
    .reset  (reset),

    .pc_in  (pc_next),

    .pc_out (pc_current)

);

/////////////////////////////////////////////////////////////
// PC + 4
/////////////////////////////////////////////////////////////

wire [31:0] pc_plus4;

pc_plus4 PCPLUS4 (

    .pc       (pc_current),
    .pc_plus4 (pc_plus4)

);

/////////////////////////////////////////////////////////////
// INSTRUCTION MEMORY
/////////////////////////////////////////////////////////////

wire [31:0] instr_mem_out;

instr_mem_wrapper IMEM (

    .clk       (clk),

    .MemRead   (MemRead),

    .addr      (pc_current),

    .instr_out (instr_mem_out)

);

/////////////////////////////////////////////////////////////
// INSTRUCTION REGISTER
/////////////////////////////////////////////////////////////

wire [31:0] instruction;

ir IR (

    .clk       (clk),
    .reset     (reset),

    .IRWrite   (IRWrite),

    .instr_in  (instr_mem_out),

    .instr_out (instruction)

);

/////////////////////////////////////////////////////////////
// INSTRUCTION FIELDS
/////////////////////////////////////////////////////////////

wire [6:0] opcode;
wire [2:0] funct3;

wire [4:0] rs1;
wire [4:0] rs2;
wire [4:0] rd;

wire       funct7_5;

assign opcode   = instruction[6:0];
assign funct3   = instruction[14:12];

assign rs1      = instruction[19:15];
assign rs2      = instruction[24:20];
assign rd       = instruction[11:7];

assign funct7_5 = instruction[30];

/////////////////////////////////////////////////////////////
// CONTROLLER FSM
/////////////////////////////////////////////////////////////

controller_fsm FSM (

    .clk          (clk),
    .reset        (reset),

    .opcode       (opcode),

    .IRWrite      (IRWrite),
    .PCWrite      (PCWrite),

    .AWrite       (AWrite),
    .BWrite       (BWrite),

    .ALUOutWrite  (ALUOutWrite),
    .MDRWrite     (MDRWrite),

    .RegWrite     (RegWrite),

    .MemRead      (MemRead),
    .MemWrite     (MemWrite),

    .state        (state)

);

/////////////////////////////////////////////////////////////
// REGISTER FILE
/////////////////////////////////////////////////////////////

wire [31:0] reg_read_data1;
wire [31:0] reg_read_data2;

wire [31:0] writeback_data;

reg_file REGFILE (

    .clk        (clk),
    .reset      (reset),

    .RegWrite   (RegWrite),

    .Rs1        (rs1),
    .Rs2        (rs2),
    .Rd         (rd),

    .WriteData  (writeback_data),

    .ReadData1  (reg_read_data1),
    .ReadData2  (reg_read_data2)

);

/////////////////////////////////////////////////////////////
// OPERAND REGISTERS
/////////////////////////////////////////////////////////////

wire [31:0] A_data;
wire [31:0] B_data;

operand_reg_a AREG (

    .clk    (clk),
    .reset  (reset),

    .AWrite (AWrite),

    .A_in   (reg_read_data1),

    .A_out  (A_data)

);

operand_reg_b BREG (

    .clk    (clk),
    .reset  (reset),

    .BWrite (BWrite),

    .B_in   (reg_read_data2),

    .B_out  (B_data)

);

/////////////////////////////////////////////////////////////
// IMMEDIATE GENERATOR
/////////////////////////////////////////////////////////////

wire [31:0] imm_out;

immgen IMMGEN (

    .instr   (instruction),

    .imm_out (imm_out)

);

/////////////////////////////////////////////////////////////
// ALU CONTROL
/////////////////////////////////////////////////////////////

wire [1:0] ALUOp;
wire [3:0] ALUControl;

assign ALUOp =

    (opcode == OPCODE_RTYPE ||
     opcode == OPCODE_ITYPE) ? 2'b10 :

    (opcode == OPCODE_BRANCH) ? 2'b01 :

                                 2'b00;

alu_control ALUCTRL (

    .ALUOp      (ALUOp),
    .funct3     (funct3),
    .funct7_5   (funct7_5),

    .ALUControl (ALUControl)

);

/////////////////////////////////////////////////////////////
// ALU INPUT MUX
/////////////////////////////////////////////////////////////

wire [31:0] alu_input_a;
wire [31:0] alu_input_b;

assign alu_input_a = A_data;

assign alu_input_b =

    (opcode == OPCODE_RTYPE) ? B_data :

                               imm_out;

/////////////////////////////////////////////////////////////
// ALU
/////////////////////////////////////////////////////////////

wire [31:0] alu_result;
wire        Zero;

alu ALU (

    .A          (alu_input_a),
    .B          (alu_input_b),

    .ALUControl (ALUControl),

    .Result     (alu_result),

    .Zero       (Zero)

);

/////////////////////////////////////////////////////////////
// ALU OUTPUT REGISTER
/////////////////////////////////////////////////////////////

wire [31:0] aluout_data;

aluout_reg ALUOUT (

    .clk            (clk),
    .reset          (reset),

    .ALUOutWrite    (ALUOutWrite),

    .alu_result_in  (alu_result),

    .alu_result_out (aluout_data)

);

/////////////////////////////////////////////////////////////
// BRANCH UNIT
/////////////////////////////////////////////////////////////

wire take_branch;

branch_unit BRANCH (

    .rs1         (A_data),
    .rs2         (B_data),

    .BranchType  (funct3),

    .take_branch (take_branch)

);

/////////////////////////////////////////////////////////////
// DATA MEMORY
/////////////////////////////////////////////////////////////

wire [31:0] data_mem_out;

data_mem_wrapper DMEM (

    .clk        (clk),

    .MemRead    (MemRead),
    .MemWrite   (MemWrite),

    .addr       (aluout_data),

    .write_data (B_data),

    .read_data  (data_mem_out)

);

/////////////////////////////////////////////////////////////
// MEMORY DATA REGISTER
/////////////////////////////////////////////////////////////

wire [31:0] mdr_data;

mdr MDR (

    .clk          (clk),
    .reset        (reset),

    .MDRWrite     (MDRWrite),

    .mem_data_in  (data_mem_out),

    .mem_data_out (mdr_data)

);

/////////////////////////////////////////////////////////////
// WRITEBACK MUX
/////////////////////////////////////////////////////////////

assign writeback_data =

    (opcode == OPCODE_LOAD) ? mdr_data :

    ((opcode == OPCODE_JAL) ||
     (opcode == OPCODE_JALR)) ? pc_plus4 :

    (opcode == OPCODE_LUI) ? imm_out :

                              aluout_data;

/////////////////////////////////////////////////////////////
// NEXT PC LOGIC
/////////////////////////////////////////////////////////////

assign pc_next =

    ((opcode == OPCODE_BRANCH) && take_branch &&
     (state == STATE_EXECUTE)) ?

        (pc_current + imm_out) :

    ((opcode == OPCODE_JAL) &&
     (state == STATE_EXECUTE)) ?

        (pc_current + imm_out) :

    ((opcode == OPCODE_JALR) &&
     (state == STATE_EXECUTE)) ?

        ((A_data + imm_out) & 32'hFFFFFFFE) :

        pc_plus4;

endmodule