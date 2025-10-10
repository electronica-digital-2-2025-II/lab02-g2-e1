`include "four_adder.v"
`include "adder.v"
`include "mult.v"
`include "shift.v"

module alu(
    input clk,
    input [3:0] a  ,
    input [3:0] b ,
    input[2:0] op,
    input init,
    input cin,
    output reg [6:0] result,
    output reg carry,
    output reg done,
    output reg overflow,
    output reg zero
);

wire done_;
wire carry_;
wire [3:0] sum_;
wire [6:0] sum_result =   {carry_,sum_};
wire[7:0] mul_result;
wire[6:0] shift_w;
wire [6:0] rest_result =   {2'b00,sum_};
four_adder sum(
.a(a),
.b(b),
.cin(cin),
.sum(sum_),
.carry(carry_)
);

shift sh(
.a(a),
.shift_(b),
.shift_number(shift_w),
.done(done_)
);

mult mul(
.a(a),
.b(b),
.clk(clk),
.init(init),
.result(mul_result),
.done(done_)
);

            
always @(posedge clk) begin
    if (init) begin
        result   <= 7'b0000000;
        overflow <= 1'b0;
        done <= 1'b0;
        carry <= 1'b0;
        
    end else begin
        case (op)
            3'b001: begin // Suma

            if(cin) begin
              result <= rest_result;
              overflow <= 1'b0;
              carry <= carry_;
              zero <= (rest_result == 0) ? 1:0;

            end else begin 
                result   <= sum_result;
                overflow <= 1'b0;
                carry <= carry_;
                zero <= (sum_result == 0) ? 1:0; 
            end   
            end
            
            3'b010: begin // Multiplicación
                overflow <= mul_result[7]; 
                result   <= mul_result[6:0];
                zero <= (mul_result == 0) ? 1:0;
                done <= done_;
            end
            3'b011: begin
            result <= shift_w;
            zero <= (shift_w == 0) ? 1:0;
            done <= done_;
            end
            3'b111:begin 

                result <= a & b;
                zero <= (result == 0) ? 1:0;
                done <= done_;

            end
            default: begin
                result   <= 7'b0000000;
                overflow <= 1'b0;
            end
        endcase
    end
end


endmodule

