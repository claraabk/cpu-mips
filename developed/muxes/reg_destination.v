module reg_destination(
    input wire [1:0] seletor_regdest,

    input wire [20:16] RT,              // Inst.20-16                - 000 (5 bits, rt)
    input wire [15:11] OFFSET,         // Inst.15-11                - 001 (5 bits, offset/imediato)
    // 29 (Registrador 29, SP)                          - 010
    // 30                                               - 011
    // 31                                               - 100

    output wire [4:0] regDest_output
);
    // 00 RT, 01 OFFSET, 10 31
    assign regDest_output = seletor_regdest[1] ? 5'd31 : (seletor_regdest[0] ? OFFSET : RT);
endmodule