module sram #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8,
    parameter MEM_SIZE = 1 << ADDR_WIDTH
) (
    input  wire                  clk,
    input  wire                  reset_n,
    input  wire                  chip_enable_n,
    input  wire                  write_enable_n,
    input  wire                  read_enable_n,
    input  wire [ADDR_WIDTH-1:0] address,
    input  wire [DATA_WIDTH-1:0] data_in,
    output reg  [DATA_WIDTH-1:0] data_out
);

    // State encoding
    typedef enum reg [2:0] {
        IDLE  = 3'b001,
        WRITE = 3'b010,
        READ  = 3'b100
    } state_t;

    state_t current_state, next_state;
    reg [DATA_WIDTH-1:0] mem [0:MEM_SIZE-1];
    reg [MEM_SIZE-1:0] addr_one_hot;

    // Address one-hot decoding
    always @(*) begin
        addr_one_hot = '0;
        if (!chip_enable_n && address < MEM_SIZE) begin
            addr_one_hot[address] = 1'b1;
        end
    end

    // Next state logic
    always @(*) begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (!chip_enable_n && !write_enable_n && read_enable_n)
                    next_state = WRITE;
                else if (!chip_enable_n && !read_enable_n && write_enable_n)
                    next_state = READ;
            end
            WRITE: begin
                if (chip_enable_n || write_enable_n)
                    next_state = IDLE;
            end
            READ: begin
                if (chip_enable_n || read_enable_n)
                    next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // State register
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Synchronous write
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            for (int i = 0; i < MEM_SIZE; i++)
                mem[i] <= '0;
        end
        else if (current_state == WRITE && !chip_enable_n && !write_enable_n && addr_one_hot[address])
            mem[address] <= data_in;
    end

    // Asynchronous read
    always @(*) begin
        if (current_state == READ && !chip_enable_n && !read_enable_n && addr_one_hot[address])
            data_out = mem[address];
        else
            data_out = '0;
    end

endmodule
