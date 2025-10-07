module shift(
input[3:0] a,
input [3:0] shift_,

output[6:0] shift_number,
output done
);

assign shift_number = a<<shift_;
assign done = 1'b1;

endmodule


