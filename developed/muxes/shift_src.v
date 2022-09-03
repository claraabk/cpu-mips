module shift_src(
    input  wire seletor,
        
    input wire [31:0] A_output,          // Registrador A - 0
    input wire [31:0] B_output,          // Registrador B - 1

    output wire [31:0] saida
);
    assign saida = (seletor ? B_output : A_output);
    // [0] = ent1, senão = ent0
endmodule