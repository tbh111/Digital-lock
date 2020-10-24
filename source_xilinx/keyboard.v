module keyboard(
  input            i_clk,
  input            i_rst_n,
  input      [3:0] row,                 // 矩阵键盘 行
  output reg [3:0] col,                 // 矩阵键盘 列
  output reg [3:0] keyboard_val,         // 键盘值
  output reg flag   
);

//++++++++++++++++++++++++++++++++++++++
// 分频部分 开始
//++++++++++++++++++++++++++++++++++++++
reg [18:0] cnt;                         // 计数子

always @ (posedge i_clk, negedge i_rst_n)
  if (!i_rst_n)
    cnt <= 0;
  else
    cnt <= cnt + 1'b1;
    

wire key_clk = cnt[18];                // (2^20/50M = 21)ms 

//--------------------------------------
// 分频部分 结束
//--------------------------------------


//++++++++++++++++++++++++++++++++++++++
// 状态机部分 开始
//++++++++++++++++++++++++++++++++++++++
// 状态数较少，独热码编码
parameter NO_KEY_PRESSED = 6'b000_001;  // 没有按键按下  
parameter SCAN_COL0      = 6'b000_010;  // 扫描第0列 
parameter SCAN_COL1      = 6'b000_100;  // 扫描第1列 
parameter SCAN_COL2      = 6'b001_000;  // 扫描第2列 
parameter SCAN_COL3      = 6'b010_000;  // 扫描第3列 
parameter KEY_PRESSED    = 6'b100_000;  // 有按键按下
parameter DEBOUNCE       = 6'b100_001;

reg [5:0] current_state, next_state;    // 现态、次态
reg key_pressed_flag;             // 键盘按下标志
always @ (posedge key_clk, negedge i_rst_n)
  if (!i_rst_n)
    current_state <= NO_KEY_PRESSED;
  else
    current_state <= next_state;

// 根据条件转移状态
always @ (posedge i_clk)
  case (current_state)
    NO_KEY_PRESSED :                    // 没有按键按下
		  begin
		  flag <= 1'b1;
        if (row != 4'hF)
          next_state = SCAN_COL0;
        else
          next_state = NO_KEY_PRESSED;
		  end
    SCAN_COL0 :                         // 扫描第0列 
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = SCAN_COL1;
    SCAN_COL1 :                         // 扫描第1列 
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = SCAN_COL2;    
    SCAN_COL2 :                         // 扫描第2列
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = SCAN_COL3;
    SCAN_COL3 :                         // 扫描第3列
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = NO_KEY_PRESSED;
    KEY_PRESSED :                       // 有按键按下
        if (row != 4'hF)
		  begin
          next_state = DEBOUNCE;
			 
		  end
        else
          next_state = NO_KEY_PRESSED;
    DEBOUNCE :
			begin
			 flag <= ~key_pressed_flag;
          next_state <= NO_KEY_PRESSED;
			end
  endcase



reg delay_flag;
reg [3:0] col_val, row_val;             // 列值、行值
//reg [3:0] col_val_r, row_val_r;
// 根据次态，给相应寄存器赋值
always @ (posedge key_clk, negedge i_rst_n)
  if (!i_rst_n)
  begin
    col              <= 4'h0;
    key_pressed_flag <=    0;
	 //flag <= 1;
  end
  else
    case (next_state)
      NO_KEY_PRESSED :                  // 没有按键按下
      begin
        col              <= 4'h0;
        key_pressed_flag <=    0;       // 清键盘按下标志
      end
      SCAN_COL0 :                       // 扫描第0列
        col <= 4'b1110;
      SCAN_COL1 :                       // 扫描第1列
        col <= 4'b1101;
      SCAN_COL2 :                       // 扫描第2列
        col <= 4'b1011;
      SCAN_COL3 :                       // 扫描第3列
        col <= 4'b0111;
      KEY_PRESSED :                     // 有按键按下
      begin
        col_val          <= col;        // 锁存列值
        row_val          <= row;        // 锁存行值
        //key_pressed_flag <= 1;          // 置键盘按下标志  
      end
      DEBOUNCE :
      begin
        if(col_val == col && row_val == row)
		  begin
          key_pressed_flag <= 1;
			 //flag <= 0;
		  end
        else
		  begin
          key_pressed_flag <= 0;
			 //flag <= 1;
		  end
      end
		default: col <= col;
    endcase
//--------------------------------------
// 状态机部分 结束
//--------------------------------------


//++++++++++++++++++++++++++++++++++++++
// 扫描行列值部分 开始
//++++++++++++++++++++++++++++++++++++++
always @ (posedge key_clk, negedge i_rst_n)
  if (!i_rst_n)
    keyboard_val <= 4'h0;
  else
    if (key_pressed_flag)
      case ({col_val, row_val})
        8'b1110_1110 : keyboard_val <= 4'h0;
        8'b1110_1101 : keyboard_val <= 4'h4;
        8'b1110_1011 : keyboard_val <= 4'h8;
        8'b1110_0111 : keyboard_val <= 4'hC;
        
        8'b1101_1110 : keyboard_val <= 4'h1;
        8'b1101_1101 : keyboard_val <= 4'h5;
        8'b1101_1011 : keyboard_val <= 4'h9;
        8'b1101_0111 : keyboard_val <= 4'hD;
        
        8'b1011_1110 : keyboard_val <= 4'h2;
        8'b1011_1101 : keyboard_val <= 4'h6;
        8'b1011_1011 : keyboard_val <= 4'hA;
        8'b1011_0111 : keyboard_val <= 4'hE;
        
        8'b0111_1110 : keyboard_val <= 4'h3; 
        8'b0111_1101 : keyboard_val <= 4'h7;
        8'b0111_1011 : keyboard_val <= 4'hB;
        8'b0111_0111 : keyboard_val <= 4'hF;
		  default:keyboard_val <= keyboard_val;
      endcase
	else keyboard_val <= keyboard_val;
//--------------------------------------
//  扫描行列值部分 结束
//--------------------------------------
      
endmodule