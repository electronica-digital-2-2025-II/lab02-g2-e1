
`timescale 1ns / 1ps

module alu_tb;

    // Entradas
    reg clk;
    reg [3:0] a;
    reg [3:0] b;
    reg [2:0] op;
    reg init;
    reg cin;
    wire overflow;

    // Salidas
    wire [6:0] result;
    wire carry;
    wire done;

    // Instancia del módulo ALU
    alu dut (
        .clk(clk),
        .a(a),
        .b(b),
        .op(op),
        .init(init),
        .cin(cin),
        .result(result),
        .carry(carry),
        .done(done),
        .overflow(overflow)
    );

    // Reloj: alterna cada 5 ns (periodo de 10 ns)
    always #5 clk = ~clk;

    initial begin
        // VCD para GTKWave
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);

        // Inicialización
        clk = 0;
        a = 0;
        b = 0;
        op = 3'b000;
        init = 0;
        cin = 0;
        init = 1;

        // Espera inicial
        #10;

        // --- TEST 1: Suma (3 + 4 = 7) ---
        a = 4'd8;
        b = 4'd9;
        cin = 0;
        op = 3'b001;  // Suma
        #20;
        

        // --- TEST 2: Multiplicación (5 * 2 = 10) ---
        a = 4'b1111;
        b = 4'b1111;
        init = 1;
        #10;
        init = 0;
        op = 3'b010;  // Multiplicación
         #100;
        // Esperar hasta que el multiplicador indique que terminó
        wait (done == 1);
        #20;

        // --- TEST 3: Suma con carry (8 + 9 = 17) ---
        a = 4'd8;
        b = 4'd9;
        cin = 0;
        op = 3'b001;
        #20;

        // --- TEST 4: Resta simulada (9 - 4 = 5) usando complemento a 2 ---
        a = 4'd9;
        b = 4'd4; // -4 en complemento a 2
        cin = 1;
        op = 3'b001;
        #20;

        $display("=== Fin del test ===");
        $finish;
    end

endmodule


