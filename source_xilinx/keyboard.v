module keyboard(
  input            i_clk,
  input            i_rst_n,
  input      [3:0] row,                 // ������� ��
  output reg [3:0] col,                 // ������� ��
  output reg [3:0] keyboard_val,         // ����ֵ
  output reg flag   
);

//++++++++++++++++++++++++++++++++++++++
// ��Ƶ���� ��ʼ
//++++++++++++++++++++++++++++++++++++++
reg [18:0] cnt;                         // ������

always @ (posedge i_clk, negedge i_rst_n)
  if (!i_rst_n)
    cnt <= 0;
  else
    cnt <= cnt + 1'b1;
    

wire key_clk = cnt[18];                // (2^20/50M = 21)ms 

//--------------------------------------
// ��Ƶ���� ����
//--------------------------------------


//++++++++++++++++++++++++++++++++++++++
// ״̬������ ��ʼ
//++++++++++++++++++++++++++++++++++++++
// ״̬�����٣����������
parameter NO_KEY_PRESSED = 6'b000_001;  // û�а�������  
parameter SCAN_COL0      = 6'b000_010;  // ɨ���0�� 
parameter SCAN_COL1      = 6'b000_100;  // ɨ���1�� 
parameter SCAN_COL2      = 6'b001_000;  // ɨ���2�� 
parameter SCAN_COL3      = 6'b010_000;  // ɨ���3�� 
parameter KEY_PRESSED    = 6'b100_000;  // �а�������
parameter DEBOUNCE       = 6'b100_001;

reg [5:0] current_state, next_state;    // ��̬����̬
reg key_pressed_flag;             // ���̰��±�־
always @ (posedge key_clk, negedge i_rst_n)
  if (!i_rst_n)
    current_state <= NO_KEY_PRESSED;
  else
    current_state <= next_state;

// ��������ת��״̬
always @ (posedge i_clk)
  case (current_state)
    NO_KEY_PRESSED :                    // û�а�������
		  begin
		  flag <= 1'b1;
        if (row != 4'hF)
          next_state = SCAN_COL0;
        else
          next_state = NO_KEY_PRESSED;
		  end
    SCAN_COL0 :                         // ɨ���0�� 
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = SCAN_COL1;
    SCAN_COL1 :                         // ɨ���1�� 
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = SCAN_COL2;    
    SCAN_COL2 :                         // ɨ���2��
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = SCAN_COL3;
    SCAN_COL3 :                         // ɨ���3��
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = NO_KEY_PRESSED;
    KEY_PRESSED :                       // �а�������
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
reg [3:0] col_val, row_val;             // ��ֵ����ֵ
//reg [3:0] col_val_r, row_val_r;
// ���ݴ�̬������Ӧ�Ĵ�����ֵ
always @ (posedge key_clk, negedge i_rst_n)
  if (!i_rst_n)
  begin
    col              <= 4'h0;
    key_pressed_flag <=    0;
	 //flag <= 1;
  end
  else
    case (next_state)
      NO_KEY_PRESSED :                  // û�а�������
      begin
        col              <= 4'h0;
        key_pressed_flag <=    0;       // ����̰��±�־
      end
      SCAN_COL0 :                       // ɨ���0��
        col <= 4'b1110;
      SCAN_COL1 :                       // ɨ���1��
        col <= 4'b1101;
      SCAN_COL2 :                       // ɨ���2��
        col <= 4'b1011;
      SCAN_COL3 :                       // ɨ���3��
        col <= 4'b0111;
      KEY_PRESSED :                     // �а�������
      begin
        col_val          <= col;        // ������ֵ
        row_val          <= row;        // ������ֵ
        //key_pressed_flag <= 1;          // �ü��̰��±�־  
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
// ״̬������ ����
//--------------------------------------


//++++++++++++++++++++++++++++++++++++++
// ɨ������ֵ���� ��ʼ
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
//  ɨ������ֵ���� ����
//--------------------------------------
      
endmodule