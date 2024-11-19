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
  clk = 1; #10;
  clk = 0; #10;
end

// Reseteo y configuración de salidas del testbench
initial begin
    $dumpfile("microc_tb.vcd");
    $dumpvars(0, microc_tb);  // Volcado de señales para ver en GTKWave

    // Inicializamos las señales
    clk = 1;
    reset = 1;  // Activar el reset al principio
    s_inc = 0;  // No incrementar el PC inicialmente
    s_inm = 0;  // No usar valor inmediato
    we3 = 0;    // No habilitar escritura en registros
    wez = 0;    // No habilitar el flag de cero
    Op = 3'b000; // Operación de la ALU inicial

    // Desactivamos el reset después de 5 ns
    #5 reset = 0;

    // ciclo 0: jump Start
    #5 
    s_inc = 0;    // No incrementar PC
    s_inm = 0;    // No usar valor inmediato
    we3 = 0;      // No escribir en registro
    wez = 0;      // No actualizar flag zero
    Op = 3'b000;

    // ciclo 5: li 0, R2
    #20 
    s_inc = 1;    // Incrementar PC
    s_inm = 1;    // Usar valor inmediato
    we3 = 1;      // Habilitar escritura en registro
    wez = 0;      // habilitar flag zero
    Op = 3'b000;  // Operación ALU default
    
    // ciclo 6: li 2, R1
    #20
    s_inc = 1;    // Incrementar PC
    s_inm = 1;    // Usar valor inmediato
    we3 = 1;      // Habilitar escritura en registro
    Op = 3'b000;  // Operación ALU default

    // ciclo 7: li 4, R3
    #20
    s_inc = 1;    // Incrementar PC
    s_inm = 1;    // Usar valor inmediato
    we3 = 1;      // Habilitar escritura en registro
    Op = 3'b000;  // Operación ALU default

    // ciclo 8: li 1, R4
    #20
    s_inc = 1;    // Incrementar PC
    s_inm = 1;    // Usar valor inmediato
    we3 = 1;      // Habilitar escritura en registro
    Op = 3'b000;  // Operación ALU default
    wez = 0;

    // Ciclo 9-11: Primera Iteración del bucle
    #20 s_inc = 1; s_inm = 0; we3 = 1; Op = 3'b010; wez = 1;       // add R2, R3, R2
    #20 s_inc = 1; s_inm = 0; we3 = 1; Op = 3'b011; wez = 1;       // sub R1, R4, R1
    #20 s_inc = 0; s_inm = 0; we3 = 0; Op = 3'b000; wez = 0;       // jnz Iter

    // Ciclo 9-11: Segunda Iteración del bucle
    #20 s_inc = 1; s_inm = 0; we3 = 1; Op = 3'b010; wez = 1;        // add R2, R3, R2
    #20 s_inc = 1; s_inm = 0; we3 = 1; Op = 3'b011; wez = 1;        // sub R1, R4, R1
    #20 s_inc = 1; s_inm = 0; we3 = 0; Op = 3'b000; wez = 0;        // jnz Iter

    // Ciclo 12: Salida del bucle, jmp Fin
    #20 s_inc = 0; s_inm = 0; we3 = 0; wez = 1;

    // Finalizar la simulación
    #35 $finish;
  end
endmodule