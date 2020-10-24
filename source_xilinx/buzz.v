`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/16 20:58:52
// Design Name: 
// Module Name: buzz
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module buzz(
    input clk,
    input buzz_en,
    output reg buzz_out
    );
    reg [13:0] counter;
    reg [25:0] counter_1;
    reg pwm;
    reg clk_1s;
    
    always@(posedge clk or negedge buzz_en)
    begin
        if(!buzz_en)
            counter <= 1'b0;
        else if(counter == 14'd9999)
            counter <= 1'b0;
        else
            counter <= counter + 1'b1;            
    end            
    
    always@(posedge clk or negedge buzz_en)
    begin
        if(!buzz_en)
            pwm <= 1'b0;
        else if(counter == 14'd4999 || counter == 14'd9999)
            pwm <= ~pwm;
        else
            pwm <= pwm;
    end
    
    always@(posedge clk or negedge buzz_en)
    begin
        if(!buzz_en)
            counter_1 <= 1'b0;
        else if(counter_1 == 26'd49999999)
            counter_1 <= 1'b0;
        else
            counter_1 <= counter_1 + 1'b1;    
    end
    
    always @(posedge clk or negedge buzz_en) // T = 1s
    begin
    if(!buzz_en)
	 begin
        clk_1s <= 0;
	 end
    else if (counter_1 == 26'd24999999 || counter_1 == 26'd49999999)
	 begin
        clk_1s <= ~clk_1s;
	 end
    else
	 begin
        clk_1s <= clk_1s;
	 end
    end
    always@(posedge clk or negedge buzz_en)
    begin
        if(!buzz_en)
            buzz_out <= 1'b0;
        else
            buzz_out <= pwm & clk_1s;
    end
endmodule
