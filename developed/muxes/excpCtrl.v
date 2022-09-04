module excpCtrl (
    input wire [1:0] excp,
    output wire [31:0] excpCtrl_output
);

    assign excpCtrl_output = excp == 2'b00 ? 32'd253 : excp == 2'b001 ? 32'd254 : 32'd255;

endmodule