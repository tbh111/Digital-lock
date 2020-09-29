module lcd (
    input clk,
    input rst_n,
    input wire [127:0] row_1,
    input wire [127:0] row_2,

    output lcd_en,
    output lcd_rw,
    output reg lcd_rs,
    output reg [7:0] lcd_data
);
	 //wire [127:0] row_1;
    //wire [127:0] row_2;

    reg [5:0] state;
    reg [5:0] state_next;

    parameter IDLE = 6'b00;
    parameter SET_FUNCTION = 6'b01;
    parameter DISP_OFF = 6'b10;
    parameter DISP_CLEAR = 6'b11;
    parameter ENTRY = 6'b100;
    parameter DISP_ON = 6'b101;

    parameter ROW1_ADDR = 6'b110;
    parameter ROW1_0 = 6'b111;
    parameter ROW1_1 = 6'b1000;
    parameter ROW1_2 = 6'b1001;
    parameter ROW1_3 = 6'b1010;
    parameter ROW1_4 = 6'b1011;
    parameter ROW1_5 = 6'b1100;
    parameter ROW1_6 = 6'b1101;
    parameter ROW1_7 = 6'b1110;
    parameter ROW1_8 = 6'b1111;
    parameter ROW1_9 = 6'b10000;
    parameter ROW1_10 = 6'b10001;
    parameter ROW1_11 = 6'b10010;
    parameter ROW1_12 = 6'b10011;
    parameter ROW1_13 = 6'b10100;
    parameter ROW1_14 = 6'b10101;
    parameter ROW1_15 = 6'b10110;

    parameter ROW2_ADDR = 6'b10111;
    parameter ROW2_0 = 6'b11000;
    parameter ROW2_1 = 6'b11001;
    parameter ROW2_2 = 6'b11010;
    parameter ROW2_3 = 6'b11011;
    parameter ROW2_4 = 6'b11100;
    parameter ROW2_5 = 6'b11101;
    parameter ROW2_6 = 6'b11110;
    parameter ROW2_7 = 6'b11111;
    parameter ROW2_8 = 6'b100000;
    parameter ROW2_9 = 6'b100001;
    parameter ROW2_10 = 6'b100010;
    parameter ROW2_11 = 6'b100011;
    parameter ROW2_12 = 6'b100100;
    parameter ROW2_13 = 6'b100101;
    parameter ROW2_14 = 6'b100110;
    parameter ROW2_15 = 6'b100111;

    parameter TIME_20MS = 1_000_000;
    reg [19:0] count_20ms;
    wire delay_done;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            count_20ms <= 1'b0;
        end
        else if (count_20ms == TIME_20MS - 1) begin
            count_20ms <= count_20ms;
        end
        else
            count_20ms <= count_20ms + 1'b1;
    end
    assign delay_done = (count_20ms == TIME_20MS-1)? 1'b1: 1'b0;

    parameter TIME_500HZ = 100_000;
    reg [19:0] count_500hz;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            count_500hz <= 1'b0;
        end
        else if (delay_done == 1) begin
            if (count_500hz == TIME_500HZ - 1) begin
                count_500hz <= 0;
            end else begin
                count_500hz <= count_500hz + 1'b1;
            end
        end
        else
            count_500hz <= 1'b0;
    end
	 wire write_flag;
    assign lcd_en = (count_500hz > (TIME_500HZ - 1) / 2)? 1'b0: 1'b1;
    assign write_flag = (count_500hz == TIME_500HZ - 1)? 1'b1: 1'b0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end
        else if (write_flag == 1) begin
            state <= state_next;
        end
        else
            state <= state;
    end

    always @(*) begin
        case (state)
            IDLE: state_next <= SET_FUNCTION;
            SET_FUNCTION: state_next <= DISP_OFF;
            DISP_OFF: state_next <= DISP_CLEAR; 
            DISP_CLEAR: state_next <= ENTRY; 
            ENTRY: state_next <= DISP_ON; 
            DISP_ON: state_next <= ROW1_ADDR;

            ROW1_ADDR: state_next <= ROW1_0; 
            ROW1_0: state_next <= ROW1_1; 
            ROW1_1: state_next <= ROW1_2; 
            ROW1_2: state_next <= ROW1_3; 
            ROW1_3: state_next <= ROW1_4; 
            ROW1_4: state_next <= ROW1_5; 
            ROW1_5: state_next <= ROW1_6; 
            ROW1_6: state_next <= ROW1_7; 
            ROW1_7: state_next <= ROW1_8; 
            ROW1_8: state_next <= ROW1_9; 
            ROW1_9: state_next <= ROW1_10; 
            ROW1_10: state_next <= ROW1_11; 
            ROW1_11: state_next <= ROW1_12; 
            ROW1_12: state_next <= ROW1_13; 
            ROW1_13: state_next <= ROW1_14; 
            ROW1_14: state_next <= ROW1_15; 
            ROW1_15: state_next <= ROW2_ADDR; 

            ROW2_ADDR: state_next <= ROW2_0;
            ROW2_0: state_next <= ROW2_1; 
            ROW2_1: state_next <= ROW2_2; 
            ROW2_2: state_next <= ROW2_3; 
            ROW2_3: state_next <= ROW2_4; 
            ROW2_4: state_next <= ROW2_5; 
            ROW2_5: state_next <= ROW2_6; 
            ROW2_6: state_next <= ROW2_7; 
            ROW2_7: state_next <= ROW2_8; 
            ROW2_8: state_next <= ROW2_9; 
            ROW2_9: state_next <= ROW2_10; 
            ROW2_10: state_next <= ROW2_11; 
            ROW2_11: state_next <= ROW2_12; 
            ROW2_12: state_next <= ROW2_13; 
            ROW2_13: state_next <= ROW2_14; 
            ROW2_14: state_next <= ROW2_15;
            ROW2_15: state_next <= ROW1_ADDR;

            default: state_next <= state_next;
        endcase
    end

    assign lcd_rw = 1'b0;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            lcd_rs <= 1'b0;
        end
        else if (write_flag == 1'b1) begin
            if ((state_next == SET_FUNCTION)||(state_next == DISP_OFF)||(state_next == DISP_CLEAR)||
                (state_next == ENTRY)||(state_next == DISP_ON)||(state_next == ROW1_ADDR)||
                (state_next == ROW2_ADDR)) begin
                lcd_rs <= 1'b0;
            end else begin
                lcd_rs <= 1'b1;
            end
        end
        else
            lcd_rs <= lcd_rs;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            lcd_data <= 1'b0;
        else if (write_flag) begin
            case (state_next)
                IDLE: lcd_data <= 8'hxx;
                SET_FUNCTION: lcd_data <= 8'h38;
                DISP_OFF: lcd_data <= 8'h08;
                DISP_CLEAR: lcd_data <= 8'h01;
                ENTRY: lcd_data <= 8'h06;
                DISP_ON: lcd_data <= 8'h0c;  //显示功能开，没有光标，且不闪烁，
                ROW1_ADDR: lcd_data <= 8'h80; //00+80
                ROW1_0: lcd_data <= row_1 [127:120];
                ROW1_1: lcd_data <= row_1 [119:112];
                ROW1_2: lcd_data <= row_1 [111:104];
                ROW1_3: lcd_data <= row_1 [103: 96];
                ROW1_4: lcd_data <= row_1 [ 95: 88];
                ROW1_5: lcd_data <= row_1 [ 87: 80];
                ROW1_6: lcd_data <= row_1 [ 79: 72];
                ROW1_7: lcd_data <= row_1 [ 71: 64];
                ROW1_8: lcd_data <= row_1 [ 63: 56];
                ROW1_9: lcd_data <= row_1 [ 55: 48];
                ROW1_10: lcd_data <= row_1 [ 47: 40];
                ROW1_11: lcd_data <= row_1 [ 39: 32];
                ROW1_12: lcd_data <= row_1 [ 31: 24];
                ROW1_13: lcd_data <= row_1 [ 23: 16];
                ROW1_14: lcd_data <= row_1 [ 15:  8];
                ROW1_15: lcd_data <= row_1 [  7:  0];

                ROW2_ADDR: lcd_data <= 8'hc0;      //40+80
                ROW2_0: lcd_data <= row_2 [127:120];
                ROW2_1: lcd_data <= row_2 [119:112];
                ROW2_2: lcd_data <= row_2 [111:104];
                ROW2_3: lcd_data <= row_2 [103: 96];
                ROW2_4: lcd_data <= row_2 [ 95: 88];
                ROW2_5: lcd_data <= row_2 [ 87: 80];
                ROW2_6: lcd_data <= row_2 [ 79: 72];
                ROW2_7: lcd_data <= row_2 [ 71: 64];
                ROW2_8: lcd_data <= row_2 [ 63: 56];
                ROW2_9: lcd_data <= row_2 [ 55: 48];
                ROW2_10: lcd_data <= row_2 [ 47: 40];
                ROW2_11: lcd_data <= row_2 [ 39: 32];
                ROW2_12: lcd_data <= row_2 [ 31: 24];
                ROW2_13: lcd_data <= row_2 [ 23: 16];
                ROW2_14: lcd_data <= row_2 [ 15:  8];
                ROW2_15: lcd_data <= row_2 [  7:  0];
                default: lcd_data <= lcd_data;
            endcase
        end
        else
            lcd_data <= lcd_data;
    end

endmodule