module mult(
    input [3:0] a,
    input [3:0] b,
    input clk,
    input init,
    output reg [7:0] result,
    output reg done
);

    // Estados de la máquina de estados
    parameter star   = 3'b000;
    parameter check  = 3'b001;
    parameter add    = 3'b010;
    parameter shift  = 3'b011;
    parameter finish = 3'b100;

    reg [2:0] state, next_state;
    reg [7:0] pp;
    reg [7:0] a_copy, b_copy;

    // 1. FSM: transición de estado
    always @(posedge clk) begin
        if (init)
            state <= star;
        else
            state <= next_state;
    end

    // 2. Lógica combinacional para determinar el siguiente estado
    always @(*) begin
        case(state)
            star:   next_state = check;
            check:  next_state = (b_copy[0] == 1'b1) ? add : shift;
            add:    next_state = shift;
            shift:  next_state = (b_copy == 0) ? finish : check;
            finish: next_state = finish;
            default:next_state = star;
        endcase
    end

    // 3. Lógica secuencial: operaciones y salidas
    always @(posedge clk) begin
        if (init) begin
            // Reset de registros al iniciar una nueva multiplicación
            pp      <= 6'b0;
            a_copy  <= {4'b0000, a};  // Extensión a 6 bits
            b_copy  <= {4'b0000, b};  // Extensión a 6 bits
            result  <= 6'b0;
            done    <= 1'b0;
        end else begin
            case(state)
                star: begin
                    pp     <= 6'b0;
                    a_copy <= {3'b000, a};  // Guardamos copia extendida
                    b_copy <= {3'b000, b};
                    done   <= 1'b0;
                end

                add: begin
                    pp <= pp + a_copy;
                end

                shift: begin
                    a_copy <= a_copy << 1;
                    b_copy <= b_copy >> 1;
                end

                finish: begin
                    result <= pp;
                    done   <= 1'b1;
                end
            endcase
        end
    end

endmodule

