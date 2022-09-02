module ulasrcA(
    input wire srcA_selector,
    input wire [31:0] PC_output,
    input wire [31:0] A_output,
    output wire [31:0] srcA_output
);

    assign srcA_output = (srcA_selector) ? A_output : PC_output;

endmodule
