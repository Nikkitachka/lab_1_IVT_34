module kuznechik_cipher(
  input              clk_i,      // Тактовый сигнал
                     resetn_i,   // Синхронный сигнал сброса с активным уровнем LOW
                     request_i,  // Сигнал запроса на начало шифрования
                     ack_i,      // Сигнал подтверждения приема зашифрованных данных
             [127:0] data_i,     // Шифруемые данные

  output             busy_o,     // Сигнал, сообщающий о невозможности приёма
                                 // очередного запроса на шифрование, поскольку
                                 // модуль в процессе шифрования предыдущего
                                 // запроса
         reg         valid_o,    // Сигнал готовности зашифрованных данных
         reg [127:0] data_o      // Зашифрованные данные
);

  reg [127:0] key_mem [0:9];

  reg [7:0] S_box_mem [0:255];

  reg [7:0] L_mul_16_mem  [0:255];
  reg [7:0] L_mul_32_mem  [0:255];
  reg [7:0] L_mul_133_mem [0:255];
  reg [7:0] L_mul_148_mem [0:255];
  reg [7:0] L_mul_192_mem [0:255];
  reg [7:0] L_mul_194_mem [0:255];
  reg [7:0] L_mul_251_mem [0:255];

  initial begin
<<<<<<< HEAD
    $readmemh("keys.mem",key_mem );         // память ключей
    $readmemh("S_box.mem",S_box_mem );      // память ключей
=======
    $readmemh("keys.mem",key_mem );
    $readmemh("S_box.mem",S_box_mem );
>>>>>>> 652b854f0a5710831852145c39c3910637dabb0d

    $readmemh("L_16.mem", L_mul_16_mem );
    $readmemh("L_32.mem", L_mul_32_mem );
    $readmemh("L_133.mem",L_mul_133_mem);
    $readmemh("L_148.mem",L_mul_148_mem);
    $readmemh("L_192.mem",L_mul_192_mem);
    $readmemh("L_194.mem",L_mul_194_mem);
    $readmemh("L_251.mem",L_mul_251_mem);
  end

  reg [3:0] round_cnt;
  reg [3:0] l_phase_cnt;

  localparam ROUND_N  = 'd10;
  localparam LINEAR_N = 'd16;

  reg [2:0] state;  
  reg [2:0] next_state;

  localparam IDLE_S      = 3'b000;
  localparam KEY_PHASE_S = 3'b001;  
  localparam S_PHASE_S   = 3'b010;
  localparam L_PHASE_S   = 3'b011;
  localparam FINISH_S    = 3'b100;

  assign busy_o = !(state == IDLE_S || state == FINISH_S);

  always @( posedge clk_i )
    if( !resetn_i ) begin
      state       <= IDLE_S;
      round_cnt   <= 'b0;
      l_phase_cnt <= 'b0;
    end else
      state <= next_state;

  always @( posedge clk_i ) begin
    case( state )
      IDLE_S:
        begin
          if( request_i ) begin
            round_cnt <= 'b0;
            next_state = KEY_PHASE_S;
          end
        end

      KEY_PHASE_S:
        begin
          if( round_cnt < ROUND_N - 'd1 ) 
            next_state = S_PHASE_S;
          else 
            next_state = FINISH_S; 
        end

      S_PHASE_S:
        begin
          next_state = L_PHASE_S;
          round_cnt  = round_cnt + 'd1;
        end

      L_PHASE_S:
        begin
          if( l_phase_cnt < LINEAR_N - 'd1 ) begin
            next_state  = L_PHASE_S;
            l_phase_cnt = l_phase_cnt + 'd1;
          end
          else
            next_state = KEY_PHASE_S; 
        end

      FINISH_S:
        begin
          if( request_i ) 
            next_state = IDLE_S;
          else if( ack_i )
            next_state = KEY_PHASE_S;
        end

      default:
        begin
          next_state = IDLE_S;
        end

    endcase
  end

  reg [127:0] data;

  always @( posedge clk_i ) begin
    if( !resetn_i ) begin
      data    <= 'b0;
      valid_o <= 'b0;
    end else
      case( state )
        IDLE_S:
          begin
            if( request_i )
              data  <= data_i;
            valid_o <= 'b0;
          end

        KEY_PHASE_S:
          begin
            data <= key_mem[round_cnt] ^ data;
            valid_o <= 'b0;
          end

        S_PHASE_S:
          begin // два 16 ричных числа, на каждое по 4 бита
            data <= {S_box_mem[data[127:120]], S_box_mem[data[119:112]], S_box_mem[data[111:104]], S_box_mem[data[103:96]], S_box_mem[data[95:88]], S_box_mem[data[87:80]], S_box_mem[data[79:72]], S_box_mem[data[71:64]], S_box_mem[data[63:56]], S_box_mem[data[55:48]], S_box_mem[data[47:40]], S_box_mem[data[39:32]], S_box_mem[data[31:24]], S_box_mem[data[23:16]], S_box_mem[data[15:8]], S_box_mem[data[7:0]]};
          end

        L_PHASE_S:
          begin
            data <= {L_mul_148_mem[data[127:120]] ^ L_mul_32_mem[data[119:112]] ^ L_mul_133_mem[data[111:104]] ^ L_mul_16_mem[data[103:96]] ^ L_mul_194_mem[data[95:88]] ^ L_mul_192_mem[data[87:80]] ^ data[79:72] ^ L_mul_251_mem[data[71:64]] ^ data[63:56] ^ L_mul_192_mem[data[55:48]] ^ L_mul_194_mem[data[47:40]] ^ L_mul_16_mem[data[39:32]] ^ L_mul_133_mem[data[31:24]] ^ L_mul_32_mem[data[23:16]] ^ L_mul_148_mem[data[15:8]] ^ data[7:0], data[127:8]};
          end

        FINISH_S:
          begin
<<<<<<< HEAD
            data_o  <= data;
            valid_o <= 'b1;
=======
            if( request_i ) 
              next_state = IDLE_S;
            else if( ack_i )
              next_state = KEY_PHASE_S;
          end

        default:
          begin
            next_state = IDLE_S;
>>>>>>> 652b854f0a5710831852145c39c3910637dabb0d
          end
      endcase
  end

endmodule