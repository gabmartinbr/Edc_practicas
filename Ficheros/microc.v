module microc(
  output wire [5:0] Opcode, 
  output wire z, 
  input wire clk, reset, s_inc, s_inm, we3, wez, 
  input wire [2:0] Op
  );
//Microcontrolador sin memoria de datos de un solo ciclo

// declaración señales internas
wire [9:0] PC;             // registro de program counter 10b
wire [15:0] instruc;      // instruccion a usar 16b
wire [7:0] reg_1, reg_2;  // registros de los operandos 8b
wire [7:0] alu_output;    // registro resultado alu 8b
wire [7:0] dato_a_reg;    // wd3, dato a escribir en los registros
wire [9:0] sig_pc;        // dirección del siguiente program counter 10b
wire z_flag;              // salida, flag de zero de el flipflop
wire [9:0] pc_siguiente;  // 10 bits, dirección siguiente del PC

// asignación del opcode de salida
assign Opcode = instruc [15:10];

// instanciar los módulos
// instancia del sumador para siguiente dir del pc
sum sumador_pc (
  .Y(sig_pc),    // Salida del sumador: dirección siguiente del PC
  .A(PC),        // Entrada A: PC actual
  .B(10'b0000000001)      // Entrada B: constante 1
);

// instancia de multiplexor output -> program counter
mux2 #(10) mux_a_pc (
  pc_siguiente,       // salida mux que va al pc
  instruc[9:0],       // entrada 0, dir salto
  sig_pc,             // entrada 1, salida del sumador_pc, siguiente dir pc
  s_inc               // 0 = saltar  1 = incrementar
);

// instancia del registro del PC
registro #(10) registro_PC (
  .Q(PC),           // Salida del registro, valor de PC
  .clk(clk),        // Señal de reloj
  .reset(reset),    // Señal de reseteo
  .D(pc_siguiente)  // Entrada de datos: pc_siguiente
);

// instancia de memoria de programa
memprog memoria_prog (
  instruc,    // salida, instrucción actual 16b
  clk,        // señal reloj
  PC          // entrada pc actual
);

// instancia multiplexor output -> banco de registros
mux2 #(8) mux_a_banco_reg (
  dato_a_reg,       // salida, dato a escribir en el registro
  alu_output,       // entrada 0, salida alu
  instruc [11:4],   // entrada 1, carga de inmediato
  s_inc             // 0 = operando reg_2  1 = cargar inmediato
);

// instancia banco de registros
regfile banco_registros (
  reg_1,            // salida 1 rd1
  reg_2,            // salida 2 rd2
  clk,              // señal de reloj
  we3,              // señal habilitar escritura
  instruc [11:8],   // ra1, dir primer reg leido
  instruc [7:4],    // ra2, dir segundo  reg leido 
  instruc [3:0],    // wa3, dir reg donde se va a escribir
  dato_a_reg        // wd3, salida mux_a_banco_reg
);

// instancia alu
alu alu_module (
  .S(alu_output),    // Salida de la ALU
  .zero(z_flag),           // Flag de cero
  .A(reg_1),          // Operando 1 (reg_1)
  .B(reg_2),          // Operando 2 (reg_2)
  .Op(Op)             // Selector de operación
);

// instancia flipflop
ffd flipflop_zero (
  .clk(clk),      // Entrada de reloj
  .reset(reset),  // Entrada de reseteo
  .d(z_flag),          // Entrada de datos (flag de zero)
  .carga(wez),    // Entrada de control para cargar (habilitador)
  .q(z)      // Salida del flip-flop (z_flag)
);
endmodule
