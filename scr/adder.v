module adder(
    input a,
    input b,
    input cin,
    output sum,
    output carry
);

    wire ab_xor, and1, and2;

xor(ab_xor, a, b);
xor(sum, ab_xor, cin);

and(and1, a, b);
and(and2, cin, ab_xor);

or (carry, and1, and2);

endmodule

