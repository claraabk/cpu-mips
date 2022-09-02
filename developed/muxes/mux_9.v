module ulasrcB(
    input wire [1:0] srcB_selector,
    input wire [31:0] B_output,
    input wire [31:0] extend_16,
    output wire [31:0] srcB_output
);

    assign srcB_output = (srcB_selector[1]) ? extend_16 : srcB_selector[0] ? 32'd4 : B_output;

endmodule
