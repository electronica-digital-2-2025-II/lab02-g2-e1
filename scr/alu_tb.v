
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
    wire zero;

    // Instancia del módulo ALU
    alu uut (
        .clk(clk),
        .a(a),
        .b(b),
        .op(op),
        .init(init),
        .cin(cin),
        .result(result),
        .carry(carry),
        .done(done),
        .overflow(overflow),
        .zero(zero)
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
        init = 1;
        cin = 0;
        init = 0;

        // Espera inicial
        #10;

        
        // --- TEST 1: Suma (8 + 9 = 17) -> Genera carry out ---
        op = 3'b001;
        a = 4'b1000;
        b = 4'b1001;
        cin = 0;
        #20;
        

        init = 1;
        a = 4'b1111;
        b = 4'b1111;
        #10;
        // --- TEST 2: Multiplicación (15 * 15 = 225) -> Genera overflow ---
        op = 3'b010;
        init = 0;
        // Esperar hasta que el multiplicador indique que terminó
        wait (done == 1);
        #20;

        
        init = 1;
        a = 4'b1100;
        b = 4'b1101;
        #10;
        // --- TEST 3: Suma con carry de salida (12 + 13 = 25) ---
        init = 0;
        op = 3'b001;
        cin = 0;
        #20;

        init = 1;
        a = 4'b1001;
        b = 4'b0100;
        cin = 1;  // Pasa a B a su complemento a 2
        #10;
        // --- TEST 4: Resta simulada (9 - 4 = 5) usando complemento a 2 ---
        init = 0;
        op = 3'b001;    
        #20;
        cin = 0;


        // --- TEST 5: Operación lógica AND ---
        op = 3'b111;
        a = 4'b1011;
        b = 4'b1110;
        #20;


        #10;
        // TEST 6: Desplazamiento de 1011 un total de 10 veces (Activa bandera de zero)---
        op = 3'b011;
        a = 4'b1011;
        b = 4'b1000;
        #20;      


        init = 1;
        #10;
        // TEST 7: Multiplicación (14 * 0 = 225) -> Activa bandera de zero ---
        op = 3'b010;
        a = 4'b1110;
        b = 4'b0000;
        init = 0;
        // Esperar hasta que el multiplicador indique que terminó
        wait (done == 1);
        #20;


        // --- TEST 8: Resta simulada (9 - 4 = 5) usando complemento a 2 ---
        cin = 1;
        op = 3'b001;
        a = 4'b0010;
        b = 4'b0011;
        #20;
        cin = 0;


        // --- TEST 9: Operación lógica AND ---
        op = 3'b111;
        a = 4'b1010;
        b = 4'b0101;
        #20;


        init = 1;
        #10;
        // TEST 10: Multiplicación (12 * 10 = 120) -> NO Activa bandera de overflow ---
        op = 3'b010;
        init = 0;
        a = 4'b1100;
        b = 4'b1010;
        // Esperar hasta que el multiplicador indique que terminó
        wait (done == 1);
        #20;

        

        init = 1;
        #10;
        // TEST 11: Multiplicación (13 * 10 = 120) -> SI Activa bandera de overflow ---
        op = 3'b010;
        a = 4'b1101;
        b = 4'b1010;
        init = 0;
        // Esperar hasta que el multiplicador indique que terminó
        wait (done == 1);
        #20;


        // TEST 12: Desplazamiento de 1011 un total de 3 veces (Activa bandera de zero)---
        op = 3'b011;
        a = 4'b1011;
        b = 4'b0011;
        #100;       


        $display("=== Fin del test ===");
        $finish;
    end

endmodule


