`timescale 1 ns / 10 ps
module microc_tb;

// declaración de variables
reg clk, reset;
reg s_inc, s_inm, we3, wez;
reg [2:0] Op;
wire [5:0] Opcode;
wire z;
wire [9:0] PC;
wire [7:0] reg_1, reg_2, alu_output, dato_a_reg;
wire z_flag;
wire [15:0] instruc;

// instanciación del camino de datos
microc micro_procesador (
  Opcode, 
  z,
  clk,
  reset,
  s_inc,
  s_inm,
  we3,
  wez,
  Op
);

// generación de reloj clk
always begin
  clk = 0; #5;
  clk = 1; #5;
end

// Reseteo y configuración de salidas del testbench
initial begin
    $dumpfile("microc_tb.vcd");
    $dumpvars(0, microc_tb);  // Volcado de señales para ver en GTKWave

    // Inicializamos las señales
    clk = 0;
    reset = 1;  // Activar el reset al principio
    s_inc = 0;  // No incrementar el PC inicialmente
    s_inm = 0;  // No usar valor inmediato
    we3 = 0;    // No habilitar escritura en registros
    wez = 0;    // No habilitar el flag de cero
    Op = 3'b000; // Operación de la ALU inicial (puedes ajustarlo según las pruebas)

    // Desactivamos el reset después de 10 ns
    #10 reset = 0;
end

// Bloque de simulación: señales control por ciclo
initial begin
    // Primer ciclo: ejecutar una instrucción (por ejemplo, cargar un valor)
    #20 s_inc = 1;    // Incrementar el PC (ciclo 1)
    Op = 3'b010;      // Operación de la ALU, por ejemplo, ADD
    we3 = 1;          // Habilitar escritura en el banco de registros
    s_inm = 1;        // Usar valor inmediato
    wez = 1;          // Actualizar bandera de cero
    #20;              // Esperar un ciclo de reloj
    // Aquí puedes observar cómo se comportan las señales y el PC

    // Segundo ciclo: ejecutar otra instrucción (por ejemplo, una suma)
    #20 s_inc = 1;    // Incrementar el PC
    Op = 3'b010;      // ALU realiza una suma
    we3 = 1;          // Habilitar escritura en el banco de registros
    s_inm = 0;        // Usar registros en lugar de inmediato
    wez = 1;          // Actualizar bandera de cero
    #20;              // Esperar un ciclo de reloj

    // Más ciclos de prueba, puedes agregar más instrucciones aquí.

    $finish;          // Termina la simulación
end

endmodule
