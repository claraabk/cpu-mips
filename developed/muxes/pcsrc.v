module pcsrc(
    input wire [1:0] pcsrc_selector,

    input wire [31:0] ULAresult,                   // - 00
    input wire [31:0] conc_SL26_PC_output,         // - 01
    input wire [31:0] RegULAout,                   // - 10
    input wire [31:0] EPC_output,                  // - 11

    output wire [31:0] PCSrc_output
);

    assign PCSrc_output = pcsrc_selector[1] ? (pcsrc_selector[0] ? EPC_output : RegULAout) : (pcsrc_selector[0] ? conc_SL26_PC_output : ULAresult);

endmodule
