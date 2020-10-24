module ram
(
input clk_50M,
input   RST_N,
/*RAM端口*/
output reg [4:0] address,  //RAM的地址端口
output reg [7:0] wrdata,   //RAM的写数据端口
output [7:0] rddata,   //RAM的读数据端口
output reg [5:0] time_cnt,  //计数器
output  wren,					//RAM的写使能端口
output  rden					//RAM的读使能端口
);

//计数器
reg [5:0] time_cnt_n;//time_cnt的下一个状态
 //RAM的地址端口
reg [4:0] address_n;  //address的下一个状态
 //RAM的写数据端口
reg [7:0] wrdata_n;  //wrdata的下一个状态

//时序逻辑电路，用来给time_cnt寄存器赋值
always @ (posedge clk_50M or negedge RST_N)
begin
if(!RST_N)
	time_cnt<=1'b0;
else
	time_cnt<=time_cnt_n;
end

/*组合电路*/
always @ (*)
begin
	if(time_cnt==6'd63)
		time_cnt_n=0;
	else
		time_cnt_n=time_cnt+1;
end

/*时序电路,用来给address寄存器赋值*/
always @ (negedge clk_50M or negedge RST_N)
begin
	if(!RST_N)
		address<=1'b0;
	else
		address<=address_n;
end

/*组合电路，用来生成RAM地址*/
always @ (*)
begin
	if(address==5'd31)
		address_n=1'b0;
	else
		address_n=address+1'b1;
end

/*组合电路，根据计数器用来生成RAM写使能*/
assign wren = (time_cnt>=1'b0&&time_cnt<=5'd31)?1'b1:1'b0;

/*时序电路，用来给wrdata寄存器赋值*/
always @ (negedge clk_50M or negedge RST_N)
begin
		if(!RST_N)
			wrdata<=1'b0;
		else
			wrdata<=wrdata_n;	
end

/*组合电路，根据计数器用来生成写入RAM的数据*/
always @ (*)
begin
	if(time_cnt>=1'b0&&time_cnt<=5'd31)
		wrdata_n=time_cnt;
	else
		wrdata_n=wrdata;

end

/*组合电路，根据计数器用来生成RAM读使能*/
assign rden =(time_cnt>=6'd32&&time_cnt<=6'd63)?1'b1:1'b0;

/*RAM IP核模块*/

ram_init	RAM_inst (
	.address ( address ),  //RAM的地址端口
	.clock ( clk_50M ),  //时钟端口
	.data ( wrdata ),//RAM的写数据端口
	.rden ( rden ),	//RAM的读使能端口
	.wren ( wren ),   //RAM的写使能端口
	.q ( rddata )     //RAM的读数据端口
	);
	
endmodule
