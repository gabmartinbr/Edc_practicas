module microc(
  output wire [5:0] Opcode, 
  output wire z, 
  input wire clk, reset, s_inc, s_inm, we3, wez, 
  input wire [2:0] Op
  );
//Microcontrolador sin memoria de datos de un solo ciclo

// declaración señales internas
reg [9:0] PC;             // registro de program counter 10b
wire [15:0] instruc;      // instruccion a usar 16b
wire [7:0] reg_1, reg_2;  // registros de los operandos 8b
wire [7:0] alu_output;    // registro resultado alu 8b
wire [7:0] dato_a_reg;    // wd3, dato a escribir en los registros
wire [9:0] sig_pc;        // dirección del siguiente program counter 10b
wire z_flag;              // salida, flag de zero de el flipflop

// instanciar los módulos
// instancia del sumador para siguiente dir del pc
sum sumador_pc (
  pc_siguiente,   // salida del sumador pc incrementado sig dir del pc
  10'b1           // entrada 0(a), constante 1 para la suma
  PC,             // entrada 1(b), valor actual del pc
);

// instancia de multiplexor output -> program counter
mux2 #(10) mux_a_pc (
  sig_pc,       // salida mux que va al pc
  instruc[9:0], // entrada 0, dir salto
  pc_siguiente, // entrada 1, salida del sumador_pc, siguiente dir pc
  s_inc         // 0 = saltar  1 = incrementar
);

// instancia del registro del PC
registro #(10) registro_PC (
  PC,           // valor actual del pc, salida pc
  clk,          // señal reloj
  reset,        // señar reseteo
  sig_pc        // salida del mux, entrada del registro pc
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
  alu_output,       // salida alu, entrada 0 mux
  z,                // salida, flag cero
  reg_1,            // entrada 0, operando 1 rd1
  reg_2,            // entrada 1, operando 2 rd2
  Op,               // selector de operación a realizar
);

// instancia flipflop
ffd flipflop_zero (
  clk,            // entrada, señal de reloj
  reset,          // entrada, señal de reseteo
  z,
  wez,
  z_flag
);
endmodule
