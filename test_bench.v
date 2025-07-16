`timescale 1ns / 1ps

module sram_tb;

    // Parameters
    parameter ADDR_WIDTH = 8;
    parameter DATA_WIDTH = 8;
    parameter MEM_SIZE = 1 << ADDR_WIDTH;
    parameter CLK_PERIOD = 10;

    // Testbench signals
    reg clk;
    reg reset_n;
    reg chip_enable_n;
    reg write_enable_n;
    reg read_enable_n;
    reg [ADDR_WIDTH-1:0] address;
    reg [DATA_WIDTH-1:0] data_in;
    wire [DATA_WIDTH-1:0] data_out;

    // Instantiate the DUT
    sram #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_SIZE(MEM_SIZE)
    ) dut (
        .clk(clk),
        .reset_n(reset_n),
        .chip_enable_n(chip_enable_n),
        .write_enable_n(write_enable_n),
        .read_enable_n(read_enable_n),
        .address(address),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // VCD generation
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, sram_tb);
    end

    // Test stimulus
    initial begin
        // Initialize signals
        reset_n = 1;
        chip_enable_n = 1;
        write_enable_n = 1;
        read_enable_n = 1;
        address = 0;
        data_in = 0;

        // Test Case 1: Reset Test
        $display("Test Case 1: Reset Test");
        reset_n = 0;
        #(CLK_PERIOD);
        #(CLK_PERIOD);
        reset_n = 1;
        #(CLK_PERIOD);
        if (dut.current_state !== 2'b00) $display("Reset failed: Not in IDLE state");
        else $display("Reset successful, state is IDLE");

        // Test Case 2: Write to valid address
        $display("Test Case 2: Write to valid address");
        chip_enable_n = 0;
        write_enable_n = 0;
        read_enable_n = 1;
        address = 8'h00;
        data_in = 8'hAA;
        #(CLK_PERIOD);
        #(CLK_PERIOD);
        chip_enable_n = 1;
        write_enable_n = 1;
        #(CLK_PERIOD);
        if (dut.mem[0] !== 8'hAA) $display("Write failed at address 0");
        else $display("Write successful, mem[0] = 8'hAA");

        // Test Case 3: Read from valid address
        $display("Test Case 3: Read from valid address");
        chip_enable_n = 0;
        write_enable_n = 1;
        read_enable_n = 0;
        address = 8'h00;
        #(CLK_PERIOD);
        #(CLK_PERIOD);
        if (data_out !== 8'hAA) $display("Read failed at address 0");
        else $display("Read successful, data_out = 8'hAA");

        $display("All basic tests completed!");
        $finish;
    end

    // Monitor
    always @(posedge clk) begin
        $display("Time=%0t rst_n=%b ce_n=%b we_n=%b re_n=%b addr=0x%02h data_in=0x%02h data_out=0x%02h state=0x%02b",
                 $time, reset_n, chip_enable_n, write_enable_n, read_enable_n,
                 address, data_in, data_out, dut.current_state);
    end

endmodule
