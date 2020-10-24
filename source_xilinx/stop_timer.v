module stop_timer (
    input wire clk_50m,
    input wire EN,
    output reg done
);
reg [25:0] counter;
reg [8:0] counter_300s;
reg clk_1s;

always @(posedge clk_50m or negedge EN) begin
    if(!EN)
        counter <= 0;
    else if (counter == 26'd49999999)
        counter <= 0;
    else
        counter <= counter + 1'b1;
end

always @(posedge clk_50m or negedge EN) begin // T = 1s
    if(!EN)
	 begin
        clk_1s <= 0;
	 end
    else if (counter == 26'd24999999 || counter == 26'd49999999)
	 begin
        clk_1s <= ~clk_1s;
	 end
    else
	 begin
        clk_1s <= clk_1s;
	 end
end

always @(posedge clk_1s or negedge EN) begin
	if(!EN)
		counter_300s <= 1'b0;
	else if(counter_300s == 9'd300)
		counter_300s <= 1'b0;
	else
		counter_300s <= counter_300s + 1'b1;
end
//assign done = (counter_300s == 8'd5);  
always@(*)
begin
//    done <= (counter_300s == 8'd5);  
    if(counter_300s > 8'd5)
        done <= 1'b1;
    else
        done <= 1'b0;
end
endmodule