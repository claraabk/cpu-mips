module shift_amount(
    input  wire seletor,
        
    input wire [31:0] B_output,          // Registrador B - 0
    input wire [10:6] entrada_1,          // Inst.6-10 - 1

    output wire [4:0] saida
);
    assign saida = (seletor ? entrada_1 : B_output);
    // [0] = ent1, senão = ent0
endmodule