module four_adder(
input[3:0] a,
input [3:0] b,
input clk,
input cin,
output[3:0] sum,
output carry
);


wire in0,in1,in2,in3;

wire carry0, carry1, carry2;

xor(in0,b[0],cin);
xor(in1,b[1],cin);
xor(in2,b[2],cin);
xor(in3,b[3],cin);

adder ad0(
.a(a[0]),
.b(in0),
.cin(cin),
.sum(sum[0]),
.carry(carry0)
);

adder ad1(
.a(a[1]),
.b(in1),
.cin(carry0),
.sum(sum[1]),
.carry(carry1)
);

adder ad2(
.a(a[2]),
.b(in2),
.cin(carry1),
.sum(sum[2]),
.carry(carry2)
);

adder ad3(
.a(a[3]),
.b(in3),
.cin(carry2),
.sum(sum[3]),
.carry(carry)
); 
endmodule
