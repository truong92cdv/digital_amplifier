module clk_gen(
    input       clk,
    output      clk_1MHz                            
);
    localparam  clk_system          = 100_000_000;      // 100 MHz                              (10 ns)
    localparam  clk_1MHz_maxcount   = 49;               // = clk_system / 1_000_000 / 2 - 1     ( 1 us)

    reg         clk_1MHz_r = 0;
    integer     count_1MHz = 0;
    
    always @(posedge clk) begin
        if (count_1MHz == clk_1MHz_maxcount) begin
            clk_1MHz_r <= ~clk_1MHz_r;
            count_1MHz <= 0;
        end else
            count_1MHz <= count_1MHz + 1;
    end

    assign clk_1MHz = clk_1MHz_r;
    
endmodule
