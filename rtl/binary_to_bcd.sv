`timescale 1ns / 1ps

// Converts binary numbers into decimal digits (where 4 bits are needed to
// represent each digit)
// Ports :
// bin - the binary number input to be converted into bcd
// tens - the tens digit of the decimal number output
// ones - the ones digit of the decimal number output

module binary_to_bcd (
    input  logic [6:0] bin,   //binary input 0-99
    output logic [3:0] tens,  //decimal tens digit
    output logic [3:0] ones   //decimal ones digit
);
  assign tens = 4'(bin / 7'd10);
  assign ones = 4'(bin % 7'd10);

endmodule

