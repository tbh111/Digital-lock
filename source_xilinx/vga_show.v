`timescale 1 ns / 1 ns


module vga_show(clk, rst, hsync, vsync, vga_r, vga_g, vga_b, state_ctrl, right_flag, changed_flag);
   input           clk;
   input           rst;
   input  [3:0]    state_ctrl;
   input           right_flag;
   input           changed_flag;
   output          hsync;
   output          vsync;
   output [3:0]    vga_r;
   output [3:0]    vga_g;
   output [3:0]    vga_b;
   
   
   wire            pclk;
   wire            valid;
   wire [9:0]      h_cnt;
   wire [9:0]      v_cnt;
   reg [11:0]      vga_data;
   
   reg [14:0]      rom_addr0;
   wire [11:0]     douta0;

   reg [14:0]      rom_addr1;
   wire [11:0]     douta1;

   reg [14:0]      rom_addr2;
   wire [11:0]     douta2;

   reg [14:0]      rom_addr3;
   wire [11:0]     douta3;
   
   wire            logo_area;
   reg [9:0]       logo_x;
   reg [9:0]       logo_y;
   parameter [9:0] logo_length = 10'b0011001000;
   parameter [9:0] logo_height  = 10'b0001101110;

   
	  dcm_25m u6
         (
         // Clock in ports
          .clk_in1(clk),      // input clk_in1
          // Clock out ports
          .clk_out1(pclk),     // output clk_out1
          // Status and control signals
          .reset(rst));   
 
	vga_640x480 u7 (
		.pclk(pclk), 
		.reset(rst), 
		.hsync(hsync), 
		.vsync(vsync), 
		.valid(valid), 
		.h_cnt(h_cnt), 
		.v_cnt(v_cnt)
		);

	rom_input u8 (
          .clka(pclk),    // input wire clka
          .addra(rom_addr0),  // input wire [13 : 0] addra
          .douta(douta0)  // output wire [11 : 0] douta
        );
	rom_right u9 (
          .clka(pclk),    // input wire clka
          .addra(rom_addr1),  // input wire [13 : 0] addra
          .douta(douta1)  // output wire [11 : 0] douta
        );
	rom_wrong u10 (
          .clka(pclk),    // input wire clka
          .addra(rom_addr2),  // input wire [13 : 0] addra
          .douta(douta2)  // output wire [11 : 0] douta
        );
	rom_lock u11 (
          .clka(pclk),    // input wire clka
          .addra(rom_addr3),  // input wire [13 : 0] addra
          .douta(douta3)  // output wire [11 : 0] douta
        );
 
   assign logo_area = ((v_cnt >= logo_y) & (v_cnt <= logo_y + logo_height - 1) & (h_cnt >= logo_x) & (h_cnt <= logo_x + logo_length - 1)) ? 1'b1 : 
                      1'b0;
   
   
   always @(posedge pclk)
   begin: logo_display
      if (rst == 1'b1)
         vga_data <= 12'b000000000000;
      else 
      begin
         if (valid == 1'b1)
         begin
            if (logo_area == 1'b1)
            begin
               case(state_ctrl)
                    4'b0000: //SYS_INIT
                    begin
                        rom_addr0 <= rom_addr0 + 14'b00000000000001;
                        vga_data <= douta0;
                    end
                    4'b0001: //INPUT_0
                    begin
                        rom_addr0 <= rom_addr0 + 14'b00000000000001;
                        vga_data <= douta0;
                    end
                    4'b0010: //INPUT_1
                    begin
                    	rom_addr0 <= rom_addr0 + 14'b00000000000001;
                        vga_data <= douta0;
                    end
                    4'b0011: //INPUT_2
                    begin
                    	rom_addr0 <= rom_addr0 + 14'b00000000000001;
                        vga_data <= douta0;
                    end
                    4'b0100: //INPUT_3
                    begin
                    	rom_addr0 <= rom_addr0 + 14'b00000000000001;
                        vga_data <= douta0;
                    end
                    4'b0101: //PWD_JUG
                    begin
                        if(changed_flag)
                        begin
                            rom_addr0 <= rom_addr0 + 14'b00000000000001;
	                        vga_data <= douta0;
                        end
                    	else if(right_flag)
                    	begin
	                    	rom_addr1 <= rom_addr1 + 14'b00000000000001;
	                        vga_data <= douta1;
                        end
	                    else
	                    begin
	                    	rom_addr2 <= rom_addr2 + 14'b00000000000001;
	                        vga_data <= douta2;
	                    end
                    end
                    4'b0110: //PWD_CHS
                    begin
                    	rom_addr0 <= rom_addr0 + 14'b00000000000001;
                        vga_data <= douta0;
                    end
                    4'b0111: //PWD_RES
                    begin
                    	rom_addr0 <= rom_addr0 + 14'b00000000000001;
                        vga_data <= douta0;
                    end
                    4'b1000: //SYS_LOCK
                    begin
                    	rom_addr3 <= rom_addr3 + 14'b00000000000001;
                        vga_data <= douta3;
                    end
//               rom_addr <= rom_addr + 14'b00000000000001;
//               vga_data <= douta;
            endcase
            end
            else
            begin
				rom_addr0 <= rom_addr0;
				vga_data <= 12'b0;
				rom_addr1 <= rom_addr1;
//				vga_data <= douta1;
				rom_addr2 <= rom_addr2;
//				vga_data <= douta2;
				rom_addr3 <= rom_addr3;
//				vga_data <= douta3;
            end
         end
         else
         begin
            vga_data <= 12'b111111111111;
            if (v_cnt == 0)
            begin
               rom_addr0 <= 14'b00000000000000;
               rom_addr1 <= 14'b00000000000000;
               rom_addr2 <= 14'b00000000000000;
               rom_addr3 <= 14'b00000000000000;
            end
         end
      end
   end
   
   assign vga_r = vga_data[11:8];
   assign vga_g = vga_data[7:4];
   assign vga_b = vga_data[3:0];
   
   
   
   always @(posedge pclk)
   begin
      
      
      if (rst == 1'b0)
      begin
         
         logo_x <= 10'b0010101110;
         logo_y <= 10'b0010101110;
      end
    end  

	
endmodule