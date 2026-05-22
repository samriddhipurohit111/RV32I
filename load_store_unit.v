module load_store_unit (

    input  wire [31:0] mem_read_data,
    input  wire [31:0] store_data,
    input  wire [1:0]  addr_offset,
    input  wire [2:0]  funct3,

    output reg  [31:0] load_data,
    output reg  [31:0] store_word,
    output reg  [3:0]  byte_en

);

/////////////////////////////////////////////////////////////
// Load Logic
/////////////////////////////////////////////////////////////

always @(*) begin

    //////////////////////////////////////////////////////////
    // Defaults
    //////////////////////////////////////////////////////////

    load_data  = 32'b0;
    store_word = 32'b0;
    byte_en    = 4'b0000;

    //////////////////////////////////////////////////////////
    // LOAD Decode
    //////////////////////////////////////////////////////////

    case (funct3)

        //////////////////////////////////////////////////////
        // LB
        //////////////////////////////////////////////////////

        3'b000:
        begin

            case (addr_offset)

                2'b00:
                    load_data =
                        {{24{mem_read_data[7]}},
                          mem_read_data[7:0]};

                2'b01:
                    load_data =
                        {{24{mem_read_data[15]}},
                          mem_read_data[15:8]};

                2'b10:
                    load_data =
                        {{24{mem_read_data[23]}},
                          mem_read_data[23:16]};

                2'b11:
                    load_data =
                        {{24{mem_read_data[31]}},
                          mem_read_data[31:24]};

            endcase

        end

        //////////////////////////////////////////////////////
        // LH
        //////////////////////////////////////////////////////

        3'b001:
        begin

            case (addr_offset)

                2'b00:
                    load_data =
                        {{16{mem_read_data[15]}},
                          mem_read_data[15:0]};

                2'b10:
                    load_data =
                        {{16{mem_read_data[31]}},
                          mem_read_data[31:16]};

                default:
                    load_data = 32'b0;

            endcase

        end

        //////////////////////////////////////////////////////
        // LW
        //////////////////////////////////////////////////////

        3'b010:
        begin
            load_data = mem_read_data;
        end

        //////////////////////////////////////////////////////
        // LBU
        //////////////////////////////////////////////////////

        3'b100:
        begin

            case (addr_offset)

                2'b00:
                    load_data = {24'b0, mem_read_data[7:0]};

                2'b01:
                    load_data = {24'b0, mem_read_data[15:8]};

                2'b10:
                    load_data = {24'b0, mem_read_data[23:16]};

                2'b11:
                    load_data = {24'b0, mem_read_data[31:24]};

            endcase

        end

        //////////////////////////////////////////////////////
        // LHU
        //////////////////////////////////////////////////////

        3'b101:
        begin

            case (addr_offset)

                2'b00:
                    load_data = {16'b0, mem_read_data[15:0]};

                2'b10:
                    load_data = {16'b0, mem_read_data[31:16]};

                default:
                    load_data = 32'b0;

            endcase

        end

        default:
        begin
            load_data = 32'b0;
        end

    endcase

end

/////////////////////////////////////////////////////////////
// Store Logic
/////////////////////////////////////////////////////////////

always @(*) begin

    //////////////////////////////////////////////////////////
    // Defaults
    //////////////////////////////////////////////////////////

    store_word = 32'b0;
    byte_en    = 4'b0000;

    //////////////////////////////////////////////////////////
    // STORE Decode
    //////////////////////////////////////////////////////////

    case (funct3)

        //////////////////////////////////////////////////////
        // SB
        //////////////////////////////////////////////////////

        3'b000:
        begin

            case (addr_offset)

                2'b00:
                begin
                    store_word = {24'b0, store_data[7:0]};
                    byte_en    = 4'b0001;
                end

                2'b01:
                begin
                    store_word = {16'b0, store_data[7:0], 8'b0};
                    byte_en    = 4'b0010;
                end

                2'b10:
                begin
                    store_word = {8'b0, store_data[7:0], 16'b0};
                    byte_en    = 4'b0100;
                end

                2'b11:
                begin
                    store_word = {store_data[7:0], 24'b0};
                    byte_en    = 4'b1000;
                end

            endcase

        end

        //////////////////////////////////////////////////////
        // SH
        //////////////////////////////////////////////////////

        3'b001:
        begin

            case (addr_offset)

                2'b00:
                begin
                    store_word = {16'b0, store_data[15:0]};
                    byte_en    = 4'b0011;
                end

                2'b10:
                begin
                    store_word = {store_data[15:0], 16'b0};
                    byte_en    = 4'b1100;
                end

            endcase

        end

        //////////////////////////////////////////////////////
        // SW
        //////////////////////////////////////////////////////

        3'b010:
        begin
            store_word = store_data;
            byte_en    = 4'b1111;
        end

        default:
        begin
            store_word = 32'b0;
            byte_en    = 4'b0000;
        end

    endcase

end

endmodule