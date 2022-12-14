module mem_to_reg(
    input wire [3:0] MEMtoREG_SELETOR,

    input wire [31:0] ULA_output,         // Output da ULA - 0000
    input wire [31:0] sign_extend1_32_output, //             - 0001
    input wire [31:0] shift_reg_output,   // Registrador Shift - 0010
    input wire [31:0] HI_output, //                              - 0011
    input wire [31:0] LO_output,     //                          - 0100
    input wire [31:0] SL_16to32_output,              //          - 0101
    input wire [31:0] LScontrol_output,                 //       - 0110
    input wire [31:0] excpCtrl2_output,                 //       - 0111

    output reg [31:0] MEMtoREG_output
);

    assign MEMtoREG_output = MEMtoREG_SELETOR[2] ? (MEMtoREG_SELETOR[1] ? (MEMtoREG_SELETOR[0] ? excpCtrl2_output : LScontrol_output) : (MEMtoREG_SELETOR[0] ? SL_16to32_output : LO_output)) : (MEMtoREG_SELETOR[1] ? (MEMtoREG_SELETOR[0] ? HI_output : shift_reg_output) : (MEMtoREG_SELETOR[0] ? sign_extend1_32_output : ULA_output));

    //assign MEMtoREG_output = MEMtoREG_SELETOR == 4'b0000 ? ULA_output : MEMtoREG_SELETOR == 4'b0100 ? sign_extend1_32_output : shift_reg_output;

    // [3] = ent8, senão (se [2] = ent7 a ent4 (se [1] = ent7 ou ent6 (se [0] = ent7, senão = ent6), senão = ent5 ou ent4 (se [0] = ent5, senão ent4)), senão = ent3 a ent0 (se [1] = ent3 ou ent2 (se [0] = ent3, senão = ent2), senão = ent1 ou ent0 (se [0] = ent1, senão = ent0)))
endmodule