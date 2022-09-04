module excpCtrl2 (
    input wire [1:0] excp2,
    output wire [31:0] excpCtrl2_output
);

    assign excpCtrl2_output = excp2 == 2'b00 ? 32'd1 : excp2 == 2'b001 ? 32'd2 : 32'd3;

endmodule