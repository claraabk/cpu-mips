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
    wire HI_write;
    wire LO_write;


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

    wire [1:0] REGDEST_SELETOR;   // 3 bits
    wire [4:0] regDest_output;

    wire [3:0] MEMtoREG_SELETOR;
    wire [31:0] memToReg_output;

    wire [2:0] shiftCtrl;
    wire [31:0] shiftReg_output;

    wire shiftAmt;
    wire [4:0] shiftAmt_output;

    wire shiftSrc;
    wire [31:0] shiftSrc_output;

    wire [31:0] sign_extend1_32_output;

    wire [1:0] pcsrc_selector;
    wire [31:0] conc_SL26_PC_output;
    wire [31:0] ULAresult;

    wire [31:0] MultDiv_output;
    wire [31:0] HI_output;
    wire [31:0] LO_output;

    wire [31:0] SL_16to32_output;

    wire [1:0] iord_selector;
    wire [31:0] iord_output;

    wire [1:0] SScontrol;
    wire [31:0] MemDataReg_out;
    wire [31:0] SScontrol_output;

    wire [1:0] LScontrol;
    wire [31:0] LScontrol_output;

    wire MemDataReg_write;

    wire EPCCtrl;
    wire [31:0] EPC_output;

    wire [1:0] excpCtrl;
    wire [31:0] excpCtrl_output;


    Registrador PC_(
        clock,
        reset,
        PC_control,
        PCSrc_output,
        PC_output
    );

    iord IorD(
        iord_selector,
        PC_output,
        ULAresult,
        ULAout,
        excpCtrl_output,

        iord_output
    );

    StoreSize SS(
        SScontrol,
        B_output,
        MemDataReg_out,

        SScontrol_output
    );


    LoadSize LS(
        LScontrol,
        MemDataReg_out,

        LScontrol_output
    );

    Memoria MEM_(
        iord_output,
        clock,
        ReadWrite,
        SScontrol_output,
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

    reg_destination reg_destination_(
        REGDEST_SELETOR,
        RT,
        OFFSET[15:11],
        regDest_output
    );

    shift_amount shift_amount_(
        shiftAmt,
        B_output,
        OFFSET[10:6],
        shiftAmt_output
    );

    shift_src shift_src_(
        shiftSrc,
        A_output,
        B_output,
        shiftSrc_output
    );

    RegDesloc shift_reg_(
        clock,
        reset,
        shiftCtrl,
        shiftAmt_output,
        shiftSrc_output,
        shiftReg_output
    );

    Banco_reg Registradores_(
        clock,
        reset,
        RegWrite,
        RS,
        RT,
        regDest_output,
        memToReg_output,
        ReadDataA,
        ReadDataB
    );

    Registrador HI(
        clock,
        reset,
        HI_write,
        MultDiv_output,

        HI_output
    );

    Registrador LO(
        clock,
        reset,
        LO_write,
        MultDiv_output,

        LO_output
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
        ULAresult,
        ULAout
    );

    Registrador MemDataReg(
        clock,
        reset,
        MemDataReg_write,
        Mem_output,

        MemDataReg_out
    );

    Registrador EPC(
        clock,
        reset,
        EPCCtrl,
        ULAresult,
        EPC_output
    );

    sign_extend_1 Sign_extend_1(
        OFFSET,
        sign_extend_1_out
    );

    sign_extend1_32 sign_extend1_32_(
        LT,
        sign_extend1_32_output
    );

    mem_to_reg mem_to_reg_(
        MEMtoREG_SELETOR,
        ULAout,
        sign_extend1_32_output,
        shiftReg_output,
        HI_output,
        LO_output,
        SL_16to32_output,
        LScontrol_output,

        memToReg_output
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

        ULAresult,
        Overflow,
        Neg,
        Zero,
        EQ,
        GT,
        LT
    );

    SL_26to28_PC concatenacao(
        RS,
        RT,
        OFFSET,
        PC_output,

        conc_SL26_PC_output
    );

    SL_16to32 shiftleft16(
        OFFSET,

        SL_16to32_output
    );

    pcsrc PcSrc_(
        pcsrc_selector,

        ULAresult,
        conc_SL26_PC_output,
        ULAout,
        EPC_output,

        PCSrc_output
    );

    excpCtrl excpCtrl_(
        excpCtrl,
        excpCtrl_output
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
        HI_write,
        LO_write,
        REGDEST_SELETOR,
        MEMtoREG_SELETOR,
        pcsrc_selector,
        iord_selector,
        SScontrol,
        LScontrol,
        MemDataReg_write,
        shiftAmt,
        shiftSrc,
        shiftCtrl,
        EQ,
        GT,
        Overflow,
        excpCtrl,
        EPCCtrl,
        reset
    );

endmodule