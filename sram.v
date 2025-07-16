module sram #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8,
    parameter MEM_SIZE   = 1 << ADDR_WIDTH
)(
    input  wire                  clk,
    input  wire                  reset_n,
    input  wire                  chip_enable_n,
    input  wire                  write_enable_n,
    input  wire                  read_enable_n,
    input  wire [ADDR_WIDTH-1:0] address,
    input  wire [DATA_WIDTH-1:0] data_in,
    output reg  [DATA_WIDTH-1:0] data_out
);

    // Memory array
    reg [DATA_WIDTH-1:0] mem [0:MEM_SIZE-1];

    // Declare loop variable outside
    integer i;

    // State encoding
    reg [1:0] current_state;
    reg [1:0] next_state;

    localparam IDLE  = 2'b00;
    localparam WRITE = 2'b01;
    localparam READ  = 2'b10;

    // Next state logic
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (!chip_enable_n && !write_enable_n && read_enable_n)
                    next_state = WRITE;
                else if (!chip_enable_n && !read_enable_n && write_enable_n)
                    next_state = READ;
                else
                    next_state = IDLE;
            end
            WRITE: begin
                if (chip_enable_n || write_enable_n)
                    next_state = IDLE;
                else
                    next_state = WRITE;
            end
            READ: begin
                if (chip_enable_n || read_enable_n)
                    next_state = IDLE;
                else
                    next_state = READ;
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

    // Synchronous write and reset memory
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            for (i = 0; i < MEM_SIZE; i = i + 1)
                mem[i] <= {DATA_WIDTH{1'b0}};
        end else if (current_state == WRITE && !chip_enable_n && !write_enable_n) begin
            mem[address] <= data_in;
        end
    end

    // Combinational read
    always @(*) begin
        if (current_state == READ && !chip_enable_n && !read_enable_n)
            data_out = mem[address];
        else
            data_out = {DATA_WIDTH{1'b0}};
    end

endmodule
