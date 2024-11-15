module microc(
  output wire [5:0] Opcode, 
  output wire z, 
  input wire clk, reset, s_inc, s_inm, we3, wez, 
  input wire [2:0] Op
  );
//Microcontrolador sin memoria de datos de un solo ciclo

// declaración de señales internas
reg [9:0] PC;             // registro de program counter 10b
wire [15:0] instruc;      // instruccion a usar 16b
wire [7:0] reg_1, reg_2;  // registros de los operandos 8b
wire [7:0] alu_output;    // registro resultado alu 8b
wire [9:0] sig_pc;        // dirección del siguiente program counter 10b


endmodule
