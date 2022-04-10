module kuznechik_cipher(
    input               clk_i,      // �������� ������
                        resetn_i,   // ���������� ������ ������ � �������� ������� LOW
                        request_i,  // ������ ������� �� ������ ����������
                        ack_i,      // ������ ������������� ������ ������������� ������
                [127:0] data_i,     // ��������� ������

    output              busy_o,     // ������, ���������� � ������������� �����
                                    // ���������� ������� �� ����������, ���������
                                    // ������ � �������� ���������� �����������
                                    // �������
           reg          valid_o,    // ������ ���������� ������������� ������
           reg  [127:0] data_o      // ������������� ������
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
    $readmemh("keys.mem",key_mem );
    $readmemh("S_box.mem",S_box_mem );

    $readmemh("L_16.mem", L_mul_16_mem );
    $readmemh("L_32.mem", L_mul_32_mem );
    $readmemh("L_133.mem",L_mul_133_mem);
    $readmemh("L_148.mem",L_mul_148_mem);
    $readmemh("L_192.mem",L_mul_192_mem);
    $readmemh("L_194.mem",L_mul_194_mem);
    $readmemh("L_251.mem",L_mul_251_mem);
end

  reg [1:0] state;  
  reg [1:0] next_state;

  localparam IDLE_S      = 3'b000;
  localparam KEY_PHASE_S = 3'b001;  
  localparam S_PHASE_S   = 3'b010;
  localparam L_PHASE_S   = 3'b011;
  localparam FINISH_S    = 3'b100;

  always @( posedge clk_i or negedge resetn_i )
    if( !resetn_i )
      state <= IDLE_S;
    else
      state <= next_state;

  always @( * )
    begin
      next_state = state;

      case( state )
        IDLE_S:
          begin
          //  if( ... )
              next_state = KEY_PHASE_S;
          end

        KEY_PHASE_S:
          begin
         //   if( ... ) 
              next_state = S_PHASE_S;
         //   else
         //     if( )
                next_state = FINISH_S; 
          end

        S_PHASE_S:
          begin
        //    if( ... )
              next_state = L_PHASE_S;
          end

        L_PHASE_S:
          begin
         //   if( ... ) 
              next_state = KEY_PHASE_S;
         //   else
         //     if( )
                next_state = L_PHASE_S; 
          end

        FINISH_S:
          begin
         //   if( ... ) 
              next_state = IDLE_S;
         //   else
         //     if( )
                next_state = KEY_PHASE_S; 
          end

        default:
          begin
            next_state = IDLE_S;
          end
 
      endcase
    end

endmodule