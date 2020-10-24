module top(
	input sys_clk_in,
	input rst,
	input [3:0] row,
	output [3:0] col,
	output [3:0] val,
	output reg [3:0] state_test,
	output [3:0] seg_cs_pin,
	output [7:0] sseg,
	output reg right_flag,
//    output lcd_ctrl_en,
//    output lcd_ctrl_rw,
//    output lcd_ctrl_rs,
//    output [7:0] lcd_dataout,
    output reg changed_pwd_flag,
    output done,
    output          hsync,
    output          vsync,
    output [3:0]    vga_r,
    output [3:0]    vga_g,
    output [3:0]    vga_b,
    output buzz_out
//    output [5:0] state_test
//    output [2:0] test
    

);
wire clk;
wire rst_n;
reg [3:0] state;
reg [3:0] state_next;
//reg [2:0] state_show;
reg [15:0] init_pwd;
reg [1:0] wrong_time;
reg timer_en;
//wire done;
//assign test[0] = lcd_ctrl_en;
//assign test[1] = lcd_ctrl_rw;
//assign test[2] = lcd_ctrl_rs;
wire relay_done;
reg rst_pwd_flag;
reg stop_timer_flag;
wire key_pressed_flag;
assign rst_n = ~rst;
parameter SYS_INIT = 4'b000;
parameter INPUT_0 = 4'b001;
parameter INPUT_1 = 4'b010;
parameter INPUT_2 = 4'b011;
parameter INPUT_3 = 4'b100;
parameter PWD_JUG = 4'b101;
parameter PWD_CHS = 4'b110;
parameter PWD_RES = 4'b111;
parameter SYS_LOCK = 4'b1000;

reg ena;
reg wea;
reg [1:0] addra;
reg [3:0] dina;
reg enb;
reg [1:0] addrb;
wire [3:0] doutb;
//wire [1:0] 

reg ena_1;
reg wea_1;
reg addra_1;
reg [15:0] dina_1;
reg enb_1;
reg addrb_1;
wire [15:0] doutb_1;

//reg changed_pwd_flag;


reg [127:0] lcd_row_1;
reg [127:0] lcd_row_2;
//wire [127:0] lcd_row_1;
//wire [127:0] lcd_row_2;
//assign row_1 = {"test"};
reg buzz_en;
always@(*)
begin
    lcd_row_1 <= {"test"};
    lcd_row_2 <= {1'b0};
end

always@(*)
begin
state_test <= state;
end
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
	begin
		state <= SYS_INIT;
	end
	else
	begin
		state <= state_next;
		
	end
end

//assign right_flag = input_pwd && init_pwd;

always @(posedge key_pressed_flag or negedge rst_n)
begin
	if(!rst_n)
	begin
		state_next <= SYS_INIT;
		//init_pwd <= 16'd0;
		wrong_time <= 2'b0;
		changed_pwd_flag <= 1'b0;
		stop_timer_flag <= 1'b1;
		timer_en <= 1'b0;
		
	end
	else
	begin
	case (state)
		SYS_INIT: 
		begin
		    changed_pwd_flag <= 1'b0;
		    timer_en <= 1'b0;
		    buzz_en <= 1'b0;
			if(val == 4'hF)
				state_next <= INPUT_0;
			else
				state_next <= SYS_INIT;
		end

		INPUT_0: 
		begin
		    if(val == 4'hF)
		        state_next <= INPUT_1;
			else if(val == 4'hE)
				state_next <= SYS_INIT;
			else
				state_next <= INPUT_0;
		end
		INPUT_1:
		begin
            if(val == 4'hF)
                state_next <= INPUT_2;
			else if(val == 4'hE)
				state_next <= INPUT_0;
			else
				state_next <= INPUT_1;
		end
		INPUT_2:
		begin
            if(val == 4'hF)
                state_next <= INPUT_3;
			else if(val == 4'hE)
				state_next <= INPUT_1;
			else
				state_next <= INPUT_2;
		end
		INPUT_3:
		begin
		    if (val == 4'hF)
                state_next <= PWD_JUG;
			else if(val == 4'hE)
				state_next <= INPUT_2;
			else
				state_next <= INPUT_3;
		end
		PWD_JUG:
		begin
		    if(changed_pwd_flag)
		          state_next <= SYS_INIT;
		    else if(!changed_pwd_flag && right_flag)
			begin
				//row_1 <= {"right"};

				if(val == 4'hF)
				begin
//				    state_next <= PWD_RES;
//                    if(changed_pwd_flag)//已经修改过
//                        state_next <= SYS_INIT;
//                    else
                        state_next <= PWD_RES;
				end
				else if(val == 4'hE)
				    state_next <= SYS_INIT;
				else
				    state_next <= PWD_JUG;
			end
			else
			begin
				//row_1 <= {"wrong"};
//				state_next <= SYS_INIT;

                wrong_time <= wrong_time + 1'b1;
				if(wrong_time > 2'd2)
				begin
					state_next <= SYS_LOCK;
					timer_en <= 1'b1;
					buzz_en <= 1'b1;
					wrong_time <= 1'b0;
			    end
			    else
			    begin
			        state_next <= INPUT_0;
				//else
					timer_en <= 1'b0;
					buzz_en <= 1'b0;
					
			     end
				//	state_next <= INPUT_0;
			end
		end

		PWD_RES:
		begin
            if(val == 4'hF)
            begin
                state_next <= INPUT_0;
                changed_pwd_flag <= 1'b1;
            end
            else if(val == 4'hE)
            begin
                state_next <= SYS_INIT;
                changed_pwd_flag <= 1'b0;
            end
            else
            begin
                state_next <= PWD_RES;
                changed_pwd_flag <= changed_pwd_flag;
            end
		end
		SYS_LOCK:
		begin
		        if(!done)
				    state_next <= SYS_LOCK;
				else
				    state_next <= SYS_INIT;
		end
		default: 
			state_next <= SYS_INIT;
	endcase
	end
end

reg [15:0] val_input;
reg en_read;
reg [3:0] data4;
reg [3:0] data1;
reg [3:0] data2;
reg [3:0] data3;
reg first_edit;
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        val_input <= 16'hff;
        //right_flag <= 1'b0;
//        changed_pwd_flag <= 1'b0;
    end
    else
    begin
    case(state)
    SYS_INIT:
	begin
		
		ena <= 1'b0;
		wea <= 1'b0;
		enb <= 1'b0;
		//addrb <= 2'b11;
		enb_1 <= 1'b1;
		ena_1 <= 1'b0;
		wea_1 <= 1'b0;
		//right_flag <= 1'b0;
		first_edit <= 1'b1;
		//changed_pwd_flag <= 1'b0;
        enb_1 <= 1'b1;
        addrb_1 <= 1'b0;
        init_pwd <= doutb_1;
        val_input <= doutb_1;
        
        
        data1 <= 4'h0;
        data2 <= 4'h0;
        data3 <= 4'h0;
        data4 <= 4'h0;
	end
	INPUT_0:
	begin
	    ena <= 1'b1;
	    enb <= 1'b1;
	    wea <= 1'b1;
	    addra <= 2'b0;
	    addrb <= 2'b0;
	    dina <= val;
	    data1 <= doutb;
	    //init_pwd <= init_pwd;
	    if(!first_edit)
            val_input <= {data4, data3, data2, data1};
        else
            val_input <= {12'hFFF, data1};

        
	end
	INPUT_1:
	begin
        //val_input <= {val_input[15:8], val, val_input[3:0]};
        ena <= 1'b1;
        enb <= 1'b1;
	    wea <= 1'b1;
	    addra <= 2'b1;
	    addrb <= 2'b1;
	    dina <= val;
	    data2 <= doutb;
	    //val_input <= {data4, data3, data2, data1};
	    if(!first_edit)
            val_input <= {data4, data3, data2, data1};
        else
            val_input <= {8'hFF, data2, data1};
	end
	INPUT_2:
	begin
        ena <= 1'b1;
        enb <= 1'b1;
	    wea <= 1'b1;
	    addra <= 2'b10;
	    addrb <= 2'b10;
	    dina <= val;
	    data3 <= doutb;
	    //val_input <= {data4, data3, data2, data1};
	    if(!first_edit)
            val_input <= {data4, data3, data2, data1};
        else
            val_input <= {4'hF, data3, data2, data1};
	end
	INPUT_3:
	begin
        ena <= 1'b1;
        enb <= 1'b1;
	    wea <= 1'b1;
	    addra <= 2'b11;
	    addrb <= 2'b11;
	    dina <= val;
	    data4 <= doutb;
	    val_input <= {data4, data3, data2, data1};
        
        ena_1 <= 1'b1;
        wea_1 <= 1'b1;
        addra_1 <= 1'b1;
        dina_1 <= val_input;
	end
	PWD_JUG:
	begin
	   ena <= 1'b1;
	   wea <= 1'b0;
	   enb <= 1'b1;
       enb_1 <= 1'b1;
       addrb_1 <= 1'b1;
//	   en_read<= 1'b1;
       addrb <= 2'b01;
       first_edit <= 1'b0;
       //val_input <= doutb_1;
       if(changed_pwd_flag)
       begin
            //enb_1 <= 1'b1;
            //addrb_1 <= 1'b1;
            ena_1 <= 1'b1;
            wea_1 <= 1'b1;
            addra_1 <= 1'b0;
            dina_1 <= val_input;
//            changed_pwd_flag <= 1'b0;
       end
       else
       begin
            //enb_1 <= 1'b1;
            ena_1 <= 1'b0;
            wea_1 <= 1'b0;
            addra_1 <= 1'b0;
//            changed_pwd_flag <= 1'b1;
            //addrb_1 <= 1'b1;
            //dina_1 <= val_input;
       end


//           if(doutb_1 == init_pwd)
//               right_flag <= 1'b1;
//           else
//           begin
//               right_flag <= 1'b0;
//               wrong_time <= wrong_time + 1'b1;
//           end

	end
//	PWD_RES:
//	begin
//        changed_pwd_flag <= 1'b1;
//	end
	default: 
	   val_input <= val_input;
	endcase
	end
end

always@(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        right_flag <= 1'b0;
    else
    begin
        if(init_pwd == doutb_1 && state == PWD_JUG)
           right_flag <= 1'b1;
        else
            right_flag <= 1'b0;
    end
end
//always @(posedge clk) begin

//case (state)
//	SYS_INIT:
//		lcd_row_2 <= {"SYS INIT"};
//	INPUT_0:
//		lcd_row_2 <= {"INPUT 0"};
//	INPUT_1:
//		lcd_row_2 <= {"INPUT 1"};
//	INPUT_2:
//		lcd_row_2 <= {"INPUT 2"};
//	INPUT_3:
//		lcd_row_2 <= {"INPUT 3"};
//	PWD_RES:
//		lcd_row_2 <= {"PWD RES"};
//	PWD_JUG:
//		lcd_row_2 <= {"PWD JUG"};
//	SYS_LOCK:
//		lcd_row_2 <= {"SYS LOCK"}; 
//	default: 
//		lcd_row_2 <= lcd_row_2;
//endcase
//end


clk_wiz_0 u0
(
// Clock out ports
.clk_out1(clk),     // output clk_out1
// Status and control signals
.reset(reset), // input reset
.locked(locked),       // output locked
// Clock in ports
.sys_clk_in(sys_clk_in));      // input sys_clk_in

segment u1(
    .clk(clk),
    .rstn(rst_n),
    .num_in(val_input),
    .an(seg_cs_pin),
    .sseg(sseg)
);
blk_mem_gen_1 u2 (//4*4
  .clka(clk),    // input wire clka
  .ena(ena),      // input wire ena
  .wea(wea),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [1 : 0] addra
  .dina(dina),    // input wire [3 : 0] dina
  .clkb(clk),    // input wire clkb
  .enb(enb),      // input wire enb
  .addrb(addrb),  // input wire [1 : 0] addrb
  .doutb(doutb)  // output wire [3 : 0] doutb
);

blk_mem_gen_0 u3 (//input pwd
  .clka(clk),    // input wire clka
  .ena(ena_1),      // input wire ena
  .wea(wea_1),      // input wire [0 : 0] wea
  .addra(addra_1),  // input wire [0 : 0] addra
  .dina(dina_1),    // input wire [15 : 0] dina
  .clkb(clk),    // input wire clkb
  .enb(enb_1),      // input wire enb
  .addrb(addrb_1),  // input wire [0 : 0] addrb
  .doutb(doutb_1)  // output wire [15 : 0] doutb
);

keyboard u4(
	.i_clk(clk),
	.i_rst_n(rst_n),
	.row(row),
	.col(col),
	.keyboard_val(val),
	.flag(key_pressed_flag)
);

//lcd u5(
//    .clk(clk),
//    .rst_n(rst_n),
//    .row_1(lcd_row_1),
//    .row_2(lcd_row_2),
//    .lcd_en(lcd_ctrl_en),
//    .lcd_rw(lcd_ctrl_rw),
//    .lcd_rs(lcd_ctrl_rs),
//    .lcd_data(lcd_dataout)
//);

stop_timer u9(
    .clk_50m(clk),
    .EN(timer_en),
    .done(done)
);

vga_show u10(
    .clk(clk), 
    .rst(rst), 
    .hsync(hsync), 
    .vsync(vsync), 
    .vga_r(vga_r), 
    .vga_g(vga_g), 
    .vga_b(vga_b),
    .state_ctrl(state),
    .right_flag(right_flag),
    .changed_flag(changed_pwd_flag)
);

buzz u11(
    .clk(clk),
    .buzz_en(buzz_en),
    .buzz_out(buzz_out)
);

endmodule