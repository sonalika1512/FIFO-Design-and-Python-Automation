
`timescale 1ns/1ps

module async_fifo_tb;

    // Clock and reset signals
    reg wr_clk;
    reg rd_clk;
    reg wr_rst;
    reg rd_rst;

    // Write interface
    reg wr_en;
    reg [7:0] data_in;
    wire full;

    // Read interface
    reg rd_en;
    wire [7:0] data_out;
    wire empty;

    // Expected data scoreboard
    reg [7:0] expected [0:23];

    integer write_index;
    integer read_index;
    integer i;
    integer round;

    // Instantiate FIFO
    async_fifo_8x8 DUT (
        .wr_clk(wr_clk),
        .wr_rst(wr_rst),
        .wr_en(wr_en),
        .data_in(data_in),
        .full(full),

        .rd_clk(rd_clk),
        .rd_rst(rd_rst),
        .rd_en(rd_en),
        .data_out(data_out),
        .empty(empty)
    );

    // Write clock: 10 ns period
    initial begin
        wr_clk = 0;
        forever #5 wr_clk = ~wr_clk;
    end

    // Read clock: 14 ns period
    initial begin
        rd_clk = 0;
        forever #7 rd_clk = ~rd_clk;
    end

    // Write task
    task write_fifo;
        input [7:0] value;
        begin
            @(negedge wr_clk);

            if (full === 1'b1) begin
                $display("ERROR: FIFO full before write");
                $finish;
            end

            wr_en = 1'b1;
            data_in = value;

            @(posedge wr_clk);
            #1;

            expected[write_index] = value;
            write_index = write_index + 1;

            @(negedge wr_clk);
            wr_en = 1'b0;
        end
    endtask

    // Read task
    task read_fifo;
        begin
            while (empty !== 1'b0)
                @(negedge rd_clk);

            rd_en = 1'b1;

            @(posedge rd_clk);
            #1;

            if (data_out !== expected[read_index]) begin
                $display(
                    "ERROR: Data mismatch at index %0d",
                    read_index
                );

                $display(
                    "Expected = %h, Actual = %h",
                    expected[read_index], data_out
                );

                $finish;
            end
            else begin
                $display(
                    "PASS: Read index=%0d Data=%h",
                    read_index, data_out
                );
            end

            read_index = read_index + 1;

            @(negedge rd_clk);
            rd_en = 1'b0;
        end
    endtask

    // Main test sequence
    initial begin

        // Open waveform database
        $shm_open("waves/async_fifo.shm");
        $shm_probe("AS");

        // Initialize signals
        wr_rst = 1'b1;
        rd_rst = 1'b1;

        wr_en = 1'b0;
        rd_en = 1'b0;

        data_in = 8'b0;

        write_index = 0;
        read_index = 0;

        $display("--------------------------------");
        $display("ASYNC FIFO TEST STARTED");
        $display("--------------------------------");

        // Hold reset
        repeat (4) @(posedge wr_clk);
        repeat (4) @(posedge rd_clk);

        // Release reset away from active clock edges
        @(negedge wr_clk);
        wr_rst = 1'b0;

        @(negedge rd_clk);
        rd_rst = 1'b0;

        // Allow synchronizers and flags to settle
        repeat (4) @(posedge wr_clk);
        repeat (4) @(posedge rd_clk);

        if (empty !== 1'b1) begin
            $display("ERROR: FIFO should be empty after reset");
            $finish;
        end

        // Three rounds exercise pointer wraparound
        for (round = 0; round < 3; round = round + 1) begin

            $display("--------------------------------");
            $display("ROUND %0d: WRITE PHASE", round + 1);

            while (full !== 1'b0)
                @(negedge wr_clk);

            // Write 8 items
            for (i = 0; i < 8; i = i + 1) begin
                write_fifo((round * 8) + i + 8'h10);
            end

            // Check full flag
            #1;

            if (full !== 1'b1) begin
                $display("ERROR: Full flag not asserted");
                $finish;
            end
            else begin
                $display("PASS: FIFO FULL detected");
            end

            $display("--------------------------------");
            $display("ROUND %0d: READ PHASE", round + 1);

            // Read 8 items
            for (i = 0; i < 8; i = i + 1) begin
                read_fifo;
            end

            // Check empty flag
            #1;

            if (empty !== 1'b1) begin
                $display("ERROR: Empty flag not asserted");
                $finish;
            end
            else begin
                $display("PASS: FIFO EMPTY detected");
            end

        end

        $display("--------------------------------");
        $display("ALL FIFO TESTS PASSED");
        $display("Total writes = %0d", write_index);
        $display("Total reads  = %0d", read_index);
        $display("--------------------------------");

        $finish;

    end

    // Simulation timeout
    initial begin
        #10000;
        $display("ERROR: Simulation timeout");
        $finish;
    end

endmodule

