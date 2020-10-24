module lcd_top(
	input clk,
	input rst_n,
	input sw_door,
	input [3:0] row,
	output [3:0] col,
	output lcd_en,
	output lcd_rw,
	output lcd_rs,
	output [7:0] lcd_data,
	output [3:0] text_in
);
reg [127:0] row_1;
reg [127:0] row_2;
//reg [3:0] row;
//wire [3:0] col;
//wire [3:0] text_in;
reg [2:0] state;
reg [2:0] state_next;
reg [15:0] init_pwd;
reg [15:0] input_pwd;
reg [1:0] wrong_time;

wire relay_done;
reg rst_pwd_flag;
reg stop_timer_flag;

parameter SYS_INIT = 3'b000;
parameter INPUT_0 = 3'b001;
parameter INPUT_1 = 3'b010;
parameter INPUT_2 = 3'b011;
parameter INPUT_3 = 3'b100;
parameter PWD_JUG = 3'b101;
parameter PWD_RES = 3'b110;
parameter SYS_LOCK = 3'b111;


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

assign right_flag = input_pwd && init_pwd;

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		state_next <= SYS_INIT;
		init_pwd <= 16'd0;
		wrong_time <= 2'b0;
		rst_pwd_flag <= 1'b0;
		stop_timer_flag <= 1'b1;
		
	end
	else
	begin
	case (state)
		SYS_INIT: 
		begin
			if(text_in == 4'hF)
				state_next <= INPUT_0;
			else
				state_next <= SYS_INIT;
		end

		INPUT_0: 
		begin
			if(text_in == 4'hF & ~rst_pwd_flag)
				// state_next <= PWD_JUG;
				state_next <= SYS_INIT;
			else if(text_in == 4'hE)
				state_next <= SYS_INIT;
			else
				state_next <= INPUT_1;
		end
		INPUT_1:
		begin
			if(text_in == 4'hF & ~rst_pwd_flag)
				// state_next <= PWD_JUG;
				state_next <= SYS_INIT;
			else if(text_in == 4'hE)
				state_next <= INPUT_0;
			else
				state_next <= INPUT_2;
		end
		INPUT_2:
		begin
			if(text_in == 4'hF & ~rst_pwd_flag)
				// state_next <= PWD_JUG;
				state_next <= SYS_INIT;
			else if(text_in == 4'hE)
				state_next <= INPUT_1;
			else
				state_next <= INPUT_3;
		end
		INPUT_3:
		begin
			if(text_in == 4'hF & ~rst_pwd_flag)
				// state_next <= PWD_JUG;
				state_next <= SYS_INIT;
			else if(text_in == 4'hF & rst_pwd_flag)
				init_pwd <= input_pwd;
			else if(text_in == 4'hE)
				state_next <= INPUT_2;
			else
				state_next <= INPUT_3;
		end
		PWD_JUG:
		begin
			if(right_flag)
				state_next <= PWD_RES;
			else
			begin
				if(wrong_time > 2)
					state_next <= SYS_LOCK;
				else
					wrong_time <= wrong_time + 1'b1;
					state_next <= INPUT_0;
			end
		end
		PWD_RES:
		begin
			if(text_in == 4'hF)
			begin
				rst_pwd_flag <= 1'b1;
				state_next <= INPUT_0;
			end
			else
				state_next <= SYS_INIT;
		end
		SYS_LOCK:
		begin
			stop_timer_flag <= 1'b0;
			if(relay_done == 1'b1)
				state_next <= SYS_INIT;
			else
				state_next <= SYS_LOCK;
		end
		default: 
			state_next <= SYS_INIT;
	endcase
	end
end

always @(posedge clk)
begin
	case (state)
		SYS_INIT:
			input_pwd <= 16'b0;
		INPUT_0:
		begin
			if (text_in != 4'hF)
			begin
				if(text_in == 4'hE)
					input_pwd <= 16'b0;
				else
					input_pwd <= {12'b0, text_in};
			end
			else
			begin
				input_pwd <= input_pwd;
			end
		end
		INPUT_1: 
		begin
			if (text_in != 4'hF)
			begin
				if(text_in == 4'hE)
					input_pwd <= input_pwd;
				else
					input_pwd <= {8'b0, text_in, input_pwd[3:0]};
			end
			else
			begin
				input_pwd <= input_pwd;
			end
		end
		INPUT_2: 
		begin
			if (text_in != 4'hF)
			begin
				if(text_in == 4'hE)
					input_pwd <= input_pwd;
				else
					input_pwd <= {4'b0, text_in, input_pwd[7:0]};
			end
			else
			begin
				input_pwd <= input_pwd;
			end
		end
		INPUT_3: 
		begin
			if (text_in != 4'hF)
			begin
				if(text_in == 4'hE)
					input_pwd <= input_pwd;
				else
					input_pwd <= {text_in, input_pwd[11:0]};
			end
			else
			begin
				input_pwd <= input_pwd;
			end
		end
		default: input_pwd <= input_pwd;
	endcase
end
always @(posedge clk) begin
	if(text_in < 4'hA)
	begin
		row_1 <= {4'b0011, text_in};
	end
	if(text_in >= 4'hA && text_in <= 4'hF)
	begin
		row_1 <= {4'b0100, text_in - 4'd9};
	end
	
end

always @(posedge clk) begin

case (state)
	SYS_INIT:
		row_2 <= {"SYS INIT"};
	INPUT_0:
		row_2 <= {"INPUT 0"};
	INPUT_1:
		row_2 <= {"INPUT 1"};
	INPUT_2:
		row_2 <= {"INPUT 2"};
	INPUT_3:
		row_2 <= {"INPUT 3"};
	PWD_RES:
		row_2 <= {"PWD RES"};
	PWD_JUG:
		row_2 <= {"PWD JUG"};
	SYS_LOCK:
		row_2 <= {"SYS LOCK"}; 
	default: 
		row_2 <= row_2;
endcase
end

//wire[7:0] data;
//assign data = text_in;
lcd u1(
	.clk(clk),
	.rst_n(rst_n),
	.row_1(row_1),
	.row_2(row_2),
	.lcd_en(lcd_en),
	.lcd_rw(lcd_rw),
	.lcd_rs(lcd_rs),
	.lcd_data(lcd_data)
);

keyboard u3(
	.i_clk(clk),
	.i_rst_n(rst_n),
	.row(row),
	.col(col),
	.keyboard_val(text_in)
);

stop_timer u4(
	.clk_50m(clk),
	.EN(stop_timer_flag),
	.done(relay_done)
);

//ram u2(
//	.clk_50M(clk),
//	.RST_N(rst_n),
//	.wrdata(data)
//);

endmodule