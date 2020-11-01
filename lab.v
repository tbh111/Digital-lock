module lab(
	input clk,
	input rst_n,
	input btn1,
	input btn2,
	input btn3,
	output reg led,
	output reg [6:0] seg

);
reg [25:0] counter;
reg clk_1s;
reg clk_led;
reg [3:0] adder;
always@(posedge clk or negedge rst_n)
begin
	if(~rst_n)
		counter <= 26'b0;
	else if(counter == 26'd50_000_000)
		counter <= 26'b0;
	else
		counter <= counter + 1'b1;
end

always@(posedge clk or negedge rst_n)
begin
	if(~rst_n)
		clk_1s <= 1'b0;
	else if (counter==26'd24_999_999 || counter == 26'd49_999_999)
		clk_1s <= ~clk_1s;
	else
		clk_1s <= clk_1s;

end

always@(posedge clk or negedge rst_n)
begin
	if(~rst_n)
		clk_led <= 1'b0;
	else if (counter==26'd4_999_999 || counter == 26'd9_999_999)
		clk_led <= ~clk_led;
	else
		clk_led <= clk_led;
end

reg reg_btn1;
reg reg_btn2;
reg reg_btn3;
wire begin_flag;
assign begin_flag = reg_btn1|reg_btn2|reg_btn3;

always@(posedge clk_1s or negedge rst_n)
begin
	if(~rst_n)
		adder <= 4'd9;
	else if(adder <= 4'd0)
		adder <= 4'd0;
	else if(begin_flag)
		adder <= adder - 1'b1;
end
assign flag = (adder==4'b0)?1'b1:1'b0;




always@(posedge clk or negedge rst_n)
begin
	if(~rst_n)
	begin
		reg_btn1 <= 1'b0;
		reg_btn2 <= 1'b0;
		reg_btn3 <= 1'b0;
		//begin_flag <= 1'b0;
	end
	else if(~btn1)
	begin
		reg_btn1 <= 1'b1;
		reg_btn2 <= reg_btn2;
		reg_btn3 <= reg_btn3;
		//begin_flag <= 1'b1;
	end
	else if(~btn2)
	begin
		reg_btn1 <= reg_btn1;
		reg_btn2 <= 1'b1;
		reg_btn3 <= reg_btn3;
		//begin_flag <= 1'b1;
	end
	else if(~btn3)
	begin
		reg_btn1 <= reg_btn1;
		reg_btn2 <= reg_btn2;
		reg_btn3 <= 1'b1;
		//begin_flag <= 1'b1;
	end
	else
	begin
		reg_btn1 <= reg_btn1;
		reg_btn2 <= reg_btn2;
		reg_btn3 <= reg_btn3;
		//begin_flag <= begin_flag;
	end
end

always@(posedge clk or negedge rst_n)
begin
	if(~rst_n)
		led <= 1'b0;
	else if(flag)
		led <= 1'b0;
	else if((reg_btn1&reg_btn2)||(reg_btn2&reg_btn3)||(reg_btn1&reg_btn3))
		led <= clk_led;
	else
		led <= 1'b1;
end

always@(*)
begin
	case(adder)
	4'd0: seg <= 7'b1000000;
	4'd1: seg <= 7'b1111001;
	4'd2: seg <= 7'b0100100;
	4'd3: seg <= 7'b0110000;
	4'd4: seg <= 7'b0011001;
	4'd5: seg <= 7'b0010010;
	4'd6: seg <= 7'b0000010;
	4'd7: seg <= 7'b1111000;
	4'd8: seg <= 7'b0000000;
	4'd9: seg <= 7'b0010000;
	default: seg <= seg;
	endcase
end

endmodule