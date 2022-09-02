module cpu(
    input wire clock,
    input wire reset
);

    wire Overflow;
    wire Neg;
    wire Zero;
    wire EQ;
    wire GT;
    wire LT;

// Control wires

    wire PC_control;
    wire ReadWrite;
    wire IRWrite;
    wire RegWrite;
    wire AWrite;
    wire BWrite;
    wire ULAout_ctrl;

    wire [2:0] ULAop;

    wire srcA_selector;
    wire [1:0] srcB_selector;


// Data wires

    wire [31:0] PCSrc_output;
    wire [31:0] ULAout;
    wire [31:0] PC_output;
    wire [31:0] Mem_output;

    wire [31:26] OPCODE;
    wire [25:21] RS;
    wire [20:16] RT;
    wire [15:0] OFFSET;

    wire [31:0] ReadDataA;
    wire [31:0] ReadDataB;
    wire [31:0] A_output;
    wire [31:0] B_output;
    wire [31:0] sign_extend_1_out;
    wire [31:0] scrA_output;
    wire [31:0] srcB_output;

    Registrador PC_(
        clock,
        reset,
        PC_control,
        PCSrc_output,
        PC_output
    );

    Memoria MEM_(
        PC_output,
        clock,
        ReadWrite,
        PCSrc_output,
        Mem_output
    );

    Instr_Reg IR_(
        clock,
        reset,
        IRWrite,
        Mem_output,
        OPCODE,
        RS,
        RT,
        OFFSET
    );

    Banco_reg Registradores_(
        clock,
        reset,
        RegWrite,
        RS,
        RT,
        OFFSET[15:11],
        ULAout,
        ReadDataA,
        ReadDataB
    );


    Registrador A_(
        clock,
        reset,
        AWrite,
        ReadDataA,
        A_output
    );

    Registrador B_(
        clock,
        reset,
        BWrite,
        ReadDataB,
        B_output
    );

    Registrador ULAoutput_(
        clock,
        reset,
        ULAout_ctrl,
        PCSrc_output,
        ULAout
    );


    sign_extend_1 Sign_extend_1(
        OFFSET,
        sign_extend_1_out
    );

    ulasrcA ulasrcA(
        srcA_selector,
        PC_output,
        A_output,
        scrA_output
    );

    ulasrcB ulasrcB(
        srcB_selector,
        B_output,
        sign_extend_1_out,
        srcB_output
    );

    ula32 ULA_(
        scrA_output,
        srcB_output,
        ULAop,
        PCSrc_output,
        Overflow,
        Neg,
        Zero,
        EQ,
        GT,
        LT
    );

    control control(
        clock,
        reset,
        OPCODE,
        OFFSET,
        PC_control,
        ReadWrite,
        IRWrite,
        RegWrite,
        AWrite,
        BWrite,
        ULAout_ctrl,
        ULAop,
        srcA_selector,
        srcB_selector,
        reset
    );

endmodule