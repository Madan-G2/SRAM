module sram_tb;
    // Parameters matching the DUT
    parameter ADDR_WIDTH = 8;
    parameter DATA_WIDTH = 8;
    parameter MEM_SIZE = 1 << ADDR_WIDTH;
    parameter CLK_PERIOD = 10;

    // Testbench signals
    logic clk;
    logic reset_n;
    logic chip_enable_n;
    logic write_enable_n;
    logic read_enable_n;
    logic [ADDR_WIDTH-1:0] address;
    logic [DATA_WIDTH-1:0] data_in;
    logic [DATA_WIDTH-1:0] data_out;

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
        repeat(2) @(posedge clk);
        reset_n = 1;
        @(posedge clk);
        assert(dut.current_state == dut.IDLE) else $error("Reset failed: Not in IDLE state");
        $display("Reset successful, state is IDLE");

        // Test Case 2: Write to valid address
        $display("Test Case 2: Write to valid address");
        chip_enable_n = 0;
        write_enable_n = 0;
        read_enable_n = 1;
        address = 8'h00;
        data_in = 8'hAA;
        @(posedge clk);
        @(posedge clk);
        chip_enable_n = 1;
        write_enable_n = 1;
        @(posedge clk);
        assert(dut.mem[0] == 8'hAA) else $error("Write failed at address 0");
        $display("Write successful, mem[0] = 8'hAA");

        // Test Case 3: Read from valid address
        $display("Test Case 3: Read from valid address");
        chip_enable_n = 0;
        write_enable_n = 1;
        read_enable_n = 0;
        address = 8'h00;
        @(posedge clk);
        @(posedge clk);
        assert(data_out == 8'hAA) else $error("Read failed at address 0");
        $display("Read successful, data_out = 8'hAA");

        $display("All basic tests completed!");
        $finish;
    end

    // Monitor
    initial begin
        $monitor("Time=%0t rst_n=%b ce_n=%b we_n=%b re_n=%b addr=%h data_in=%h data_out=%h state=%s",
                 $time, reset_n, chip_enable_n, write_enable_n, read_enable_n,
                 address, data_in, data_out, dut.current_state.name());
    end
endmodule
