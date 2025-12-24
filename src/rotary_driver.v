module rotary_driver (
    input  wire clk,           // 100 MHz clock
    input  wire rst_n,         // nút reset
    input  wire rotary_a,      // encoder A
    input  wire rotary_b,      // encoder B
    input  wire rotary_press,  // nút nhấn encoder
    output reg  [1:0] action,  // 2-bit action: 0=none, 1=left, 2=right, 3=press
    output reg  start          // 1-bit pulse to control lcd_driver
);

    // ======================
    // Đồng bộ tín hiệu A, B vào clock
    // ======================
    reg [1:0] sync_a, sync_b, sync_press;
    always @(posedge clk) begin
        sync_a <= {sync_a[0], rotary_a};
        sync_b <= {sync_b[0], rotary_b};
        sync_press <= {sync_press[0], rotary_press};
    end
    wire a_db = sync_a[1];
    wire b_db = sync_b[1];
    wire press_db = sync_press[1];

    // ======================
    // Bộ lọc chống bounce (rotary filter)
    // ======================
    reg rotary_q1, rotary_q2;
    reg [1:0] rotary_in;

    always @(posedge clk) begin
        rotary_in <= {b_db, a_db};
        case (rotary_in)
            2'b00: begin rotary_q1 <= 0; rotary_q2 <= rotary_q2; end
            2'b11: begin rotary_q1 <= 1; rotary_q2 <= rotary_q2; end
            2'b10: begin rotary_q1 <= rotary_q1; rotary_q2 <= 1; end
            2'b01: begin rotary_q1 <= rotary_q1; rotary_q2 <= 0; end
        endcase
    end

    // ======================
    // Xác định chiều xoay
    // ======================
    reg delay_q1;
    reg rotary_event;
    reg rotary_left;

    always @(posedge clk) begin
        delay_q1 <= rotary_q1;
        if (rotary_q1 && !delay_q1) begin
            rotary_event <= 1'b1;
            rotary_left  <= rotary_q2;  // 1 = Left, 0 = Right
        end else begin
            rotary_event <= 1'b0;
        end
    end

    // ======================
    // Debounce và edge detection cho nút nhấn
    // ======================
    reg [22:0] press_counter;  // counter 23-bit cho debounce (~20ms với 100MHz)
    reg press_state, press_state_d;
    wire press_pulse;
    
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            press_counter <= 23'd0;
            press_state <= 1'b0;
            press_state_d <= 1'b0;
        end else begin
            press_state_d <= press_state;  // Edge detection
            if (press_db == press_state) begin
                press_counter <= 23'd0;
            end else begin
                press_counter <= press_counter + 1'b1;
                if (press_counter == 23'd1999999) begin  // ~20ms debounce với 100MHz
                    press_state <= press_db;
                    press_counter <= 23'd0;
                end
            end
        end
    end
    
    assign press_pulse = press_state && !press_state_d;

    // ======================
    // Tạo tín hiệu action và start với timing cải thiện
    // ======================
    reg action_valid; // tín hiệu để tạo xung start
    reg [1:0] action_temp; // tín hiệu action tạm thời
    
    // Tạo action_temp trước
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            action_temp <= 2'b00;
            action_valid <= 1'b0;
        end else if (rotary_event) begin
            if (rotary_left) begin
                action_temp <= 2'b01;  // Xoay trái
            end else begin
                action_temp <= 2'b10;  // Xoay phải
            end
            action_valid <= 1'b1;
        end else if (press_pulse) begin
            action_temp <= 2'b11;      // Nhấn nút
            action_valid <= 1'b1;
        end else begin
            action_valid <= 1'b0;
        end
    end
    
    // ======================
    // Điều khiển action
    // ======================
    reg action_valid_d; // delay một chu kỳ để tạo edge detection
    
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            action <= 2'b00;
            action_valid_d <= 1'b0;
        end else begin
            action_valid_d <= action_valid;
            
            // Action thay đổi khi có sự kiện mới
            if (action_valid && !action_valid_d) begin
                action <= action_temp; // action thay đổi ngay lập tức
            end else if (!action_valid) begin
                action <= 2'b00; // action về 0 khi không có sự kiện
            end
        end
    end
    
    // ======================
    // Tạo xung start
    // ======================
    reg start_active; // trạng thái start đang active
    
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            start <= 1'b0;
            start_active <= 1'b0;
        end else begin
            // Tạo xung start sau khi action đã thay đổi
            if (action_valid && !action_valid_d) begin
                start <= 1'b1;
                start_active <= 1'b1;
            end else if (start_active) begin
                start <= 1'b0; // start về 0 sau 1 chu kỳ
                start_active <= 1'b0;
            end
        end
    end

endmodule
