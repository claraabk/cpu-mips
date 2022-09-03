module pcsrc(
    input wire pcsrc_selector,

    input wire [31:0] ULAresult,                   // - 0
    input wire [31:0] conc_SL26_PC_output,         // - 1

    output wire [31:0] PCSrc_output
);

    assign PCSrc_output = pcsrc_selector ? conc_SL26_PC_output : ULAresult;

endmodule
