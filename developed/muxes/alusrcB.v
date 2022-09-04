module ulasrcB(
    input wire [1:0] srcB_selector,
    
    input wire [31:0] B_output, // 00
    // imediato 4 - 01
    input wire [31:0] extend_16, // 10
    input wire [31:0] shift_left_2_output, //11

    output wire [31:0] srcB_output 
);

    assign srcB_output = (srcB_selector[1]) ? (srcB_selector[0] ? shift_left_2_output : extend_16) : (srcB_selector[0] ? 32'd4 : B_output);

endmodule
