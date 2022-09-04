module iord(
    input wire [1:0] iord_selector,

    input wire [31:0] PC_output,        // 00
    input wire [31:0] ULAresult,        // 01
    input wire [31:0] ULAout,           // 10
    input wire [31:0] excpCtrl_output,  // 11

    output wire [31:0] iord_output
);

    assign iord_output = (iord_selector[1]) ? (iord_selector[0] ? excpCtrl_output : ULAout) : (iord_selector[0] ? ULAresult : PC_output);

endmodule