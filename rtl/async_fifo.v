
`timescale 1ns/1ps

module async_fifo_8x8 (
    // Write domain
    input         wr_clk,
    input         wr_rst,
    input         wr_en,
    input  [7:0]  data_in,
    output        full,

    // Read domain
    input         rd_clk,
    input         rd_rst,
    input         rd_en,
    output reg [7:0] data_out,
    output        empty
);

    // FIFO memory: 8 locations, 8 bits each
    reg [7:0] mem [0:7];

    // Binary pointers: 3 address bits + 1 wrap bit
    reg [3:0] wr_ptr_bin;
    reg [3:0] rd_ptr_bin;

    // Gray-code pointers
    reg [3:0] wr_ptr_gray;
    reg [3:0] rd_ptr_gray;

    // Pointer synchronizers
    reg [3:0] rd_ptr_gray_sync1;
    reg [3:0] rd_ptr_gray_sync2;

    reg [3:0] wr_ptr_gray_sync1;
    reg [3:0] wr_ptr_gray_sync2;

    // Next pointer values
    reg  [3:0] wr_ptr_bin_next;
    reg  [3:0] rd_ptr_bin_next;

    wire [3:0] wr_ptr_gray_next;
    wire [3:0] rd_ptr_gray_next;

    // Registered status flags
    reg full_reg;
    reg empty_reg;

    wire full_next;
    wire empty_next;

    assign full  = full_reg;
    assign empty = empty_reg;

    // ------------------------------------------------
    // 1. Write pointer next-state logic
    // ------------------------------------------------

    always @(*) begin
        wr_ptr_bin_next = wr_ptr_bin;

        if (wr_en && !full_reg)
            wr_ptr_bin_next = wr_ptr_bin + 1'b1;
    end

    assign wr_ptr_gray_next =
        (wr_ptr_bin_next >> 1) ^ wr_ptr_bin_next;

    // ------------------------------------------------
    // 2. Read pointer next-state logic
    // ------------------------------------------------

    always @(*) begin
        rd_ptr_bin_next = rd_ptr_bin;

        if (rd_en && !empty_reg)
            rd_ptr_bin_next = rd_ptr_bin + 1'b1;
    end

    assign rd_ptr_gray_next =
        (rd_ptr_bin_next >> 1) ^ rd_ptr_bin_next;

    // ------------------------------------------------
    // 3. Synchronize read pointer into write domain
    // ------------------------------------------------

    always @(posedge wr_clk or posedge wr_rst) begin
        if (wr_rst) begin
            rd_ptr_gray_sync1 <= 4'b0000;
            rd_ptr_gray_sync2 <= 4'b0000;
        end
        else begin
            rd_ptr_gray_sync1 <= rd_ptr_gray;
            rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
        end
    end

    // ------------------------------------------------
    // 4. Synchronize write pointer into read domain
    // ------------------------------------------------

    always @(posedge rd_clk or posedge rd_rst) begin
        if (rd_rst) begin
            wr_ptr_gray_sync1 <= 4'b0000;
            wr_ptr_gray_sync2 <= 4'b0000;
        end
        else begin
            wr_ptr_gray_sync1 <= wr_ptr_gray;
            wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
        end
    end

    // ------------------------------------------------
    // 5. Full flag logic
    // ------------------------------------------------

    assign full_next =
        (wr_ptr_gray_next ==
        {~rd_ptr_gray_sync2[3:2],
           rd_ptr_gray_sync2[1:0]});

    always @(posedge wr_clk or posedge wr_rst) begin
        if (wr_rst) begin
            wr_ptr_bin  <= 4'b0000;
            wr_ptr_gray <= 4'b0000;
            full_reg    <= 1'b0;
        end
        else begin
            wr_ptr_bin  <= wr_ptr_bin_next;
            wr_ptr_gray <= wr_ptr_gray_next;
            full_reg    <= full_next;

            if (wr_en && !full_reg)
                mem[wr_ptr_bin[2:0]] <= data_in;
        end
    end

    // ------------------------------------------------
    // 6. Empty flag logic
    // ------------------------------------------------

    assign empty_next =
        (rd_ptr_gray_next == wr_ptr_gray_sync2);

    always @(posedge rd_clk or posedge rd_rst) begin
        if (rd_rst) begin
            rd_ptr_bin  <= 4'b0000;
            rd_ptr_gray <= 4'b0000;
            empty_reg   <= 1'b1;
            data_out    <= 8'b00000000;
        end
        else begin
            rd_ptr_bin  <= rd_ptr_bin_next;
            rd_ptr_gray <= rd_ptr_gray_next;
            empty_reg   <= empty_next;

            if (rd_en && !empty_reg)
                data_out <= mem[rd_ptr_bin[2:0]];
        end
    end

endmodule

