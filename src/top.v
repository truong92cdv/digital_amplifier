module top (
    input           clk,            // 100MHz
    input           rst_n,      
    input           rotary_a,      // encoder A
    input           rotary_b,      // encoder B
    input           rotary_press,  // nút nhấn encoder
    inout           sda,            // I2C for LCD
    output          scl             
);
    wire            clk_1MHz;
    wire    [1:0]   action;     // 2-bit action: 0=none, 1=left, 2=right, 3=press
    wire            start;      // 1-bit pulse to control lcd_driver
    wire            lcd_ena;
    wire    [127:0] row1;                           // LCD row 1
    wire    [127:0] row2;  
    wire            busy;

    clk_gen clk_gen_inst(
        .clk                (clk),
        .clk_1MHz           (clk_1MHz)
    );

    rotary_driver rotary_driver_inst(
        .clk                (clk),
        .rst_n              (rst_n),
        .rotary_a           (rotary_a),
        .rotary_b           (rotary_b),
        .rotary_press       (rotary_press),
        .action             (action),
        .start              (start)
    );

    control_center control_center_inst(
        .clk                (clk),
        .rst_n              (rst_n),
        .action             (action),
        .start              (start),
        .busy               (busy),
        .lcd_ena            (lcd_ena),
        .row1               (row1),
        .row2               (row2)
    );

    lcd_driver lcd_driver_inst(
        .clk                (clk),
        .clk_1MHz           (clk_1MHz),
        .rst_n              (rst_n),
        .lcd_ena            (lcd_ena),
        .row1               (row1),
        .row2               (row2),
        .busy               (busy),
        .scl                (scl),
        .sda                (sda)
    );

endmodule
