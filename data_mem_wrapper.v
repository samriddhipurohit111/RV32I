module data_mem_wrapper (

    input  wire        clk,

    input  wire        MemRead,
    input  wire        MemWrite,

    input  wire [31:0] addr,
    input  wire [31:0] write_data,

    output wire [31:0] read_data

);

/////////////////////////////////////////////////////////////
// Internal Signals
/////////////////////////////////////////////////////////////

wire [6:0] mem_addr;

wire [15:0] q_low;
wire [15:0] q_high;

/////////////////////////////////////////////////////////////
// Word-Aligned Address
/////////////////////////////////////////////////////////////

assign mem_addr = addr[8:2];

/////////////////////////////////////////////////////////////
// LOWER 16-BIT SRAM
/////////////////////////////////////////////////////////////

ram_128x16A RAM_LOW (

    .CLK (clk),

    .CEN (~(MemRead | MemWrite)),
    .WEN (~MemWrite),

    .OEN (1'b0),

    .A   (mem_addr),

    .D   (write_data[15:0]),

    .Q   (q_low)

);

/////////////////////////////////////////////////////////////
// UPPER 16-BIT SRAM
/////////////////////////////////////////////////////////////

ram_128x16A RAM_HIGH (

    .CLK (clk),

    .CEN (~(MemRead | MemWrite)),
    .WEN (~MemWrite),

    .OEN (1'b0),

    .A   (mem_addr),

    .D   (write_data[31:16]),

    .Q   (q_high)

);

/////////////////////////////////////////////////////////////
// Read Data Combine
/////////////////////////////////////////////////////////////

assign read_data = {q_high, q_low};

endmodule