module control_center(
    input               clk,
    input               rst_n,
    input    [1:0]      action,     // 2-bit action: 0=none, 1=left, 2=right, 3=press
    input               start,      // 1-bit pulse to control lcd_driver
    input               busy,       // busy signal from LCD driver
    output              lcd_ena,
    output [127:0]      row1,                           // LCD row 1
    output [127:0]      row2                           // LCD row 2
);

    localparam  IDLE        = 0,
                WELCOME     = 1,
                MENU_VOLUME = 2,
                MENU_BASS   = 3,
                MENU_TREBLE = 4;
    
    reg   [2:0] state;
    reg         lcd_ena_r;
    reg [127:0] row1_r;
    reg [127:0] row2_r;
    reg  [31:0] wait_counter;

    reg   [3:0] volume;
    reg   [3:0] bass;
    reg   [3:0] treble;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            wait_counter <= 0;
            row1_r <= " HELLO JETKING  ";
            row2_r <= "DIGITAL APLIFIER";
            volume <= 7;
            bass   <= 7;
            treble <= 7;
            lcd_ena_r <= 0;
        end else begin

            case (state)
                IDLE: begin
                    row1_r <= " HELLO JETKING  ";
                    row2_r <= "DIGITAL APLIFIER";               
                    if (wait_counter >= 100_000) begin
                        lcd_ena_r <= 1;
                        wait_counter <= 0;
                        state <= WELCOME;
                    end else begin
                        lcd_ena_r <= 0;
                        wait_counter <= wait_counter + 1;
                    end

                end

                WELCOME: begin                
                    if (wait_counter >= 100) begin
                        lcd_ena_r <= 0;
                    end else begin
                        lcd_ena_r <= 1;
                    end

                    if (start && (action == 3)) begin
                        wait_counter <= 0;
                        state <= MENU_VOLUME;
                    end else begin
                        wait_counter <= wait_counter + 1;
                    end
                end

                MENU_VOLUME: begin
                    case (volume)
                        0: {row1_r, row2_r} = {" VOLUME :  0    ","\xFF               "};
                        1: {row1_r, row2_r} = {" VOLUME :  1    ","\xFF\xFF              "};
                        2: {row1_r, row2_r} = {" VOLUME :  2    ","\xFF\xFF\xFF             "};
                        3: {row1_r, row2_r} = {" VOLUME :  3    ","\xFF\xFF\xFF\xFF            "};
                        4: {row1_r, row2_r} = {" VOLUME :  4    ","\xFF\xFF\xFF\xFF\xFF           "};
                        5: {row1_r, row2_r} = {" VOLUME :  5    ","\xFF\xFF\xFF\xFF\xFF\xFF          "};
                        6: {row1_r, row2_r} = {" VOLUME :  6    ","\xFF\xFF\xFF\xFF\xFF\xFF\xFF         "};
                        7: {row1_r, row2_r} = {" VOLUME :  7    ","\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF        "};
                        8: {row1_r, row2_r} = {" VOLUME :  8    ","\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF       "};
                        9: {row1_r, row2_r} = {" VOLUME :  9    ","\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF      "};
                        10:{row1_r, row2_r} = {" VOLUME : 10    ","\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF     "};
                        11:{row1_r, row2_r} = {" VOLUME : 11    ","\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF    "};
                        12:{row1_r, row2_r} = {" VOLUME : 12    ","\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF   "};
                        13:{row1_r, row2_r} = {" VOLUME : 13    ","\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF  "};
                        14:{row1_r, row2_r} = {" VOLUME : 14    ","\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF "}; 
                        15:{row1_r, row2_r} = {" VOLUME : 15    ","\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"};   
                    endcase

                    if (wait_counter >= 500_000_000) begin
                        wait_counter <= 0;
                        state <= IDLE;
                    end else if (wait_counter >= 100) begin
                        lcd_ena_r <= 0;
                    end else begin
                        lcd_ena_r <= 1;
                    end

                    if (start) begin
                        wait_counter <= 0;
                        case (action)
                            1: if (volume > 0)  volume <= volume - 1;
                            2: if (volume < 15) volume <= volume + 1;
                            3: state <= MENU_BASS;
                        endcase
                    end else begin
                        wait_counter <= wait_counter + 1;
                    end
                end

                MENU_BASS: begin
                    case (bass)
                        0: {row1_r, row2_r} = {"  BASS  : -7    "," \xFF\x2D\x2D\x2D\x2D\x2D\x2D\x2B\x2D\x2D\x2D\x2D\x2D\x2D\x2D"};             
                        1: {row1_r, row2_r} = {"  BASS  : -6    "," \x2D\xFF\x2D\x2D\x2D\x2D\x2D\x2B\x2D\x2D\x2D\x2D\x2D\x2D\x2D"};
                        2: {row1_r, row2_r} = {"  BASS  : -5    "," \x2D\x2D\xFF\x2D\x2D\x2D\x2D\x2B\x2D\x2D\x2D\x2D\x2D\x2D\x2D"};
                        3: {row1_r, row2_r} = {"  BASS  : -4    "," \x2D\x2D\x2D\xFF\x2D\x2D\x2D\x2B\x2D\x2D\x2D\x2D\x2D\x2D\x2D"};
                        4: {row1_r, row2_r} = {"  BASS  : -3    "," \x2D\x2D\x2D\x2D\xFF\x2D\x2D\x2B\x2D\x2D\x2D\x2D\x2D\x2D\x2D"}; 
                        5: {row1_r, row2_r} = {"  BASS  : -2    "," \x2D\x2D\x2D\x2D\x2D\xFF\x2D\x2B\x2D\x2D\x2D\x2D\x2D\x2D\x2D"};
                        6: {row1_r, row2_r} = {"  BASS  : -1    "," \x2D\x2D\x2D\x2D\x2D\x2D\xFF\x2B\x2D\x2D\x2D\x2D\x2D\x2D\x2D"};
                        7: {row1_r, row2_r} = {"  BASS  :  0    "," \x2D\x2D\x2D\x2D\x2D\x2D\x2D\xFF\x2D\x2D\x2D\x2D\x2D\x2D\x2D"};
                        8: {row1_r, row2_r} = {"  BASS  : +1    "," \x2D\x2D\x2D\x2D\x2D\x2D\x2D\x2B\xFF\x2D\x2D\x2D\x2D\x2D\x2D"};
                        9: {row1_r, row2_r} = {"  BASS  : +2    "," \x2D\x2D\x2D\x2D\x2D\x2D\x2D\x2B\x2D\xFF\x2D\x2D\x2D\x2D\x2D"};
                        10:{row1_r, row2_r} = {"  BASS  : +3    "," \x2D\x2D\x2D\x2D\x2D\x2D\x2D\x2B\x2D\x2D\xFF\x2D\x2D\x2D\x2D"};
                        11:{row1_r, row2_r} = {"  BASS  : +4    "," \x2D\x2D\x2D\x2D\x2D\x2D\x2D\x2B\x2D\x2D\x2D\xFF\x2D\x2D\x2D"};
                        12:{row1_r, row2_r} = {"  BASS  : +5    "," \x2D\x2D\x2D\x2D\x2D\x2D\x2D\x2B\x2D\x2D\x2D\x2D\xFF\x2D\x2D"};
                        13:{row1_r, row2_r} = {"  BASS  : +6    "," \x2D\x2D\x2D\x2D\x2D\x2D\x2D\x2B\x2D\x2D\x2D\x2D\x2D\xFF\x2D"};
                        14:{row1_r, row2_r} = {"  BASS  : +7    "," \x2D\x2D\x2D\x2D\x2D\x2D\x2D\x2B\x2D\x2D\x2D\x2D\x2D\x2D\xFF"};
                    endcase
                    
                    if (wait_counter >= 500_000_000) begin
                        wait_counter <= 0;
                        state <= IDLE;
                    end else if (wait_counter >= 100) begin
                        lcd_ena_r <= 0;
                    end else begin
                        lcd_ena_r <= 1;
                    end

                    if (start) begin
                        wait_counter <= 0;
                        case (action)
                            1: if (bass > 0)  bass <= bass - 1;
                            2: if (bass < 14) bass <= bass + 1;
                            3: state <= MENU_TREBLE;
                        endcase
                    end else begin
                        wait_counter <= wait_counter + 1;
                    end
                end

                MENU_TREBLE: begin
                    case (treble)
                        0: {row1_r, row2_r} = {" TREBLE : -7    "," \xFF\x2D\x2D\x2D\x2D\x2D\x2D\x2B\x2D\x2D\x2D\x2D\x2D\x2D\x2D"};             
                        1: {row1_r, row2_r} = {" TREBLE : -6    "," \x2D\xFF\x2D\x2D\x2D\x2D\x2D\x2B\x2D\x2D\x2D\x2D\x2D\x2D\x2D"};
                        2: {row1_r, row2_r} = {" TREBLE : -5    "," \x2D\x2D\xFF\x2D\x2D\x2D\x2D\x2B\x2D\x2D\x2D\x2D\x2D\x2D\x2D"};
                        3: {row1_r, row2_r} = {" TREBLE : -4    "," \x2D\x2D\x2D\xFF\x2D\x2D\x2D\x2B\x2D\x2D\x2D\x2D\x2D\x2D\x2D"};
                        4: {row1_r, row2_r} = {" TREBLE : -3    "," \x2D\x2D\x2D\x2D\xFF\x2D\x2D\x2B\x2D\x2D\x2D\x2D\x2D\x2D\x2D"}; 
                        5: {row1_r, row2_r} = {" TREBLE : -2    "," \x2D\x2D\x2D\x2D\x2D\xFF\x2D\x2B\x2D\x2D\x2D\x2D\x2D\x2D\x2D"};
                        6: {row1_r, row2_r} = {" TREBLE : -1    "," \x2D\x2D\x2D\x2D\x2D\x2D\xFF\x2B\x2D\x2D\x2D\x2D\x2D\x2D\x2D"};
                        7: {row1_r, row2_r} = {" TREBLE :  0    "," \x2D\x2D\x2D\x2D\x2D\x2D\x2D\xFF\x2D\x2D\x2D\x2D\x2D\x2D\x2D"};
                        8: {row1_r, row2_r} = {" TREBLE : +1    "," \x2D\x2D\x2D\x2D\x2D\x2D\x2D\x2B\xFF\x2D\x2D\x2D\x2D\x2D\x2D"};
                        9: {row1_r, row2_r} = {" TREBLE : +2    "," \x2D\x2D\x2D\x2D\x2D\x2D\x2D\x2B\x2D\xFF\x2D\x2D\x2D\x2D\x2D"};
                        10:{row1_r, row2_r} = {" TREBLE : +3    "," \x2D\x2D\x2D\x2D\x2D\x2D\x2D\x2B\x2D\x2D\xFF\x2D\x2D\x2D\x2D"};
                        11:{row1_r, row2_r} = {" TREBLE : +4    "," \x2D\x2D\x2D\x2D\x2D\x2D\x2D\x2B\x2D\x2D\x2D\xFF\x2D\x2D\x2D"};
                        12:{row1_r, row2_r} = {" TREBLE : +5    "," \x2D\x2D\x2D\x2D\x2D\x2D\x2D\x2B\x2D\x2D\x2D\x2D\xFF\x2D\x2D"};
                        13:{row1_r, row2_r} = {" TREBLE : +6    "," \x2D\x2D\x2D\x2D\x2D\x2D\x2D\x2B\x2D\x2D\x2D\x2D\x2D\xFF\x2D"};
                        14:{row1_r, row2_r} = {" TREBLE : +7    "," \x2D\x2D\x2D\x2D\x2D\x2D\x2D\x2B\x2D\x2D\x2D\x2D\x2D\x2D\xFF"};
                    endcase
                    if (wait_counter >= 500_000_000) begin
                        wait_counter <= 0;
                        state <= IDLE;
                    end else if (wait_counter >= 100) begin
                        lcd_ena_r <= 0;
                    end else begin
                        lcd_ena_r <= 1;
                    end

                    if (start) begin
                        wait_counter <= 0;
                        case (action)
                            1: if (treble > 0)  treble <= treble - 1;
                            2: if (treble < 14) treble <= treble + 1;
                            3: state <= MENU_VOLUME;
                        endcase
                    end else begin
                        wait_counter <= wait_counter + 1;
                    end 
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

    assign lcd_ena = lcd_ena_r;
    assign row1 = row1_r;
    assign row2 = row2_r;

endmodule