`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/06 16:44:10
// Design Name: 
// Module Name: segment
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


module segment(
    input clk,
    input rstn,
    input [15:0] num_in,
    output reg [3:0] an,
    output reg [7:0] sseg
    );
//counter
localparam N = 18;
reg[N-1:0] regN;
reg[7:0] hex_in;

reg [6:0] decode_1;
reg [6:0] decode_2;
reg [6:0] decode_3;
reg [6:0] decode_4;
parameter _0 = 8'hc0,_1 = 8'hf9,_2 = 8'ha4,_3 = 8'hb0,
	               _4 = 8'h99,_5 = 8'h92,_6 = 8'h82,_7 = 8'hf8,
	               _8 = 8'h80,_9 = 8'h90,_A = 8'h77, _B = 8'h7c, _C = 8'h39, _D = 8'h5e, _E = 8'h0, _F = 8'h0;
always @(posedge clk or negedge rstn)
begin
    if(!rstn)
    decode_1 <= 7'b0;
    else
    begin
        case(num_in[3:0])
        4'h0:
            decode_1 <= ~_0;
        4'h1:
            decode_1 <= ~_1;
        4'h2:
            decode_1 <= ~_2;
        4'h3:
            decode_1 <= ~_3;
        4'h4:
            decode_1 <= ~_4;
        4'h5:
            decode_1 <= ~_5;
        4'h6:
            decode_1 <= ~_6;
        4'h7:
            decode_1 <= ~_7;
        4'h8:
            decode_1 <= ~_8;
        4'h9:
            decode_1 <= ~_9;
        4'hA:
            decode_1 <= _A;
        4'hB:
            decode_1 <= _B;
        4'hC:
            decode_1 <= _C;
        4'hD:
            decode_1 <= _D;
        4'hE:
            decode_1 <= _E;
        4'hF:
            decode_1 <= _F;
        default:
            decode_1 <= 7'b0000000;
    endcase
    end
end

always @(posedge clk or negedge rstn)
begin
    if(!rstn)
    decode_2 <= 7'b0;
    else
    begin
        case(num_in[7:4])
        4'h0:
            decode_2 <= ~_0;
        4'h1:
            decode_2 <= ~_1;
        4'h2:
            decode_2 <= ~_2;
        4'h3:
            decode_2 <= ~_3;
        4'h4:
            decode_2 <= ~_4;
        4'h5:
            decode_2 <= ~_5;
        4'h6:
            decode_2 <= ~_6;
        4'h7:
            decode_2 <= ~_7;
        4'h8:
            decode_2 <= ~_8;
        4'h9:
            decode_2 <= ~_9;
        4'hA:
            decode_2 <= _A;
        4'hB:
            decode_2 <= _B;
        4'hC:
            decode_2 <= _C;
        4'hD:
            decode_2 <= _D;
        4'hE:
            decode_2 <= _E;
        4'hF:
            decode_2 <= _F;
        default:
            decode_2 <= 7'b0000000;
    endcase
    end
end

always @(posedge clk or negedge rstn)
begin
    if(!rstn)
    decode_3 <= 7'b0;
    else
    begin
        case(num_in[11:8])
        4'h0:
            decode_3 <= ~_0;
        4'h1:
            decode_3 <= ~_1;
        4'h2:
            decode_3 <= ~_2;
        4'h3:
            decode_3 <= ~_3;
        4'h4:
            decode_3 <= ~_4;
        4'h5:
            decode_3 <= ~_5;
        4'h6:
            decode_3 <= ~_6;
        4'h7:
            decode_3 <= ~_7;
        4'h8:
            decode_3 <= ~_8;
        4'h9:
            decode_3 <= ~_9;
        4'hA:
            decode_3 <= _A;
        4'hB:
            decode_3 <= _B;
        4'hC:
            decode_3 <= _C;
        4'hD:
            decode_3 <= _D;
        4'hE:
            decode_3 <= _E;
        4'hF:
            decode_3 <= _F;
        default:
            decode_3 <= 7'b0000000;
    endcase
    end
end

always @(posedge clk or negedge rstn)
begin
    if(!rstn)
    decode_4 <= 7'b0;
    else
    begin
        case(num_in[15:12])
        4'h0:
            decode_4 <= ~_0;
        4'h1:
            decode_4 <= ~_1;
        4'h2:
            decode_4 <= ~_2;
        4'h3:
            decode_4 <= ~_3;
        4'h4:
            decode_4 <= ~_4;
        4'h5:
            decode_4 <= ~_5;
        4'h6:
            decode_4 <= ~_6;
        4'h7:
            decode_4 <= ~_7;
        4'h8:
            decode_4 <= ~_8;
        4'h9:
            decode_4 <= ~_9;
        4'hA:
            decode_4 <= _A;
        4'hB:
            decode_4 <= _B;
        4'hC:
            decode_4 <= _C;
        4'hD:
            decode_4 <= _D;
        4'hE:
            decode_4 <= _E;
        4'hF:
            decode_4 <= _F;
        default:
            decode_4 <= 7'b0000000;
    endcase
    end
end

always@(posedge clk or negedge rstn)//clk_div
begin
    if(!rstn)
        regN <= 0;
    else
        regN <= regN + 1;
end

always@(*)//seg
begin
        case (regN[N-1:N-2])
            2'b00:
                begin
                    an = 8'b1000;
                    
                    sseg = decode_1;
                end
            2'b01:
                begin
                    an = 8'b0100;
                    
                    sseg = decode_2;
                end
            2'b10:
                begin
                    an = 8'b0010;
                    
                    sseg = decode_3;
                end
            2'b11:
                begin
                    an = 8'b0001;
                    
                    sseg = decode_4;
                end
            default:
                begin
                    an = 8'b0000;
                    
                    sseg = 8'b0;
              end 
        endcase
end        
endmodule
