module pcsrc(
    input wire [2:0] pcsrc_selector,

    input wire [31:0] ULAresult,                            // - 000
    input wire [31:0] conc_SL26_PC_output,                  // - 001
    input wire [31:0] RegULAout,                            // - 010
    input wire [31:0] EPC_output,                           // - 011
    input wire [31:0] sign_extend8_32_output,               // - 100

    output wire [31:0] PCSrc_output
);

    assign PCSrc_output = pcsrc_selector[2] ? sign_extend8_32_output : (pcsrc_selector[1] ? (pcsrc_selector[0] ? EPC_output : RegULAout) : (pcsrc_selector[0] ? conc_SL26_PC_output : ULAresult));

endmodule
