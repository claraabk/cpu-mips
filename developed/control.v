module control(
    input wire clock,
    input wire reset,

    input wire [31:26] OPCODE,
    input wire [15:0] OFFSET,
    
    output reg PC_control,
    output reg ReadWrite,
    output reg IRWrite,
    output reg RegWrite,
    output reg AWrite,
    output reg BWrite,
    output reg ULAout_ctrl,

    output reg [2:0] ULAop,

    output reg srcA_selector,
    output reg [1:0] srcB_selector,
    output reg HI_write,
    output reg LO_write,
    output reg [1:0] REGDEST_SELETOR,
    output reg [3:0] MEMtoREG_SELETOR,
    output reg [2:0] pcsrc_selector,
    output reg [1:0] iord_selector,
    output reg [1:0] SScontrol,
    output reg [1:0] LScontrol,
    output reg MemDataReg_write,
    output reg shiftAmt,
    output reg shiftSrc,
    output reg [2:0] shiftCtrl,
    
    input wire EQ,
    input wire GT,
    input wire Overflow,

    output reg [1:0] excpCtrl,
    output reg [1:0] excpCtrl2,
    output reg EPCCtrl,

    output reg reset_out
);

reg [6:0] state;
reg [2:0] counter;

parameter common_st = 7'b0000000;
parameter add_st = 7'b0000101;
parameter addi_st = 7'b0000110;
parameter sub_st = 7'b0000111;
parameter and_st = 7'b0001000;
parameter sll_st = 7'b0001001;
parameter slt_st = 7'b0001010;
parameter sra_st = 7'b0001011;
parameter srl_st = 7'b0001100;
parameter sllv_st = 7'b0001101;
parameter srav_st = 7'b0001110;
parameter slti_st = 7'b0001111;
parameter reset_st = 7'b1111111;
parameter j_st = 7'b0101001;
parameter jal_st = 7'b0111101;
parameter jr_st = 7'b0111001;
parameter beq_st = 7'b0010000;
parameter bne_st = 7'b0010001;
parameter mfhi_st = 7'b0011001;
parameter mflo_st = 7'b0011101;
parameter break_st = 7'b1000000;
parameter lui_st = 7'b1011101;
parameter ble_st = 7'b0010010;
parameter bgt_st = 7'b0010011;
parameter addiu_st = 7'b0010100;
parameter loads_st = 7'b0110001;
parameter lw_st = 7'b1011001;
parameter lh_st = 7'b1001001;
parameter lb_st = 7'b1001011;
parameter stores_st = 7'b0110011;
parameter sw_st = 7'b1111001;
parameter sh_st = 7'b1101001;
parameter sb_st = 7'b1101011;
parameter overflow_st = 7'b0010101;
parameter rte_st = 7'b0010110;

// OPCODES
parameter R = 6'b000000;
parameter addi_op = 6'b001000;
parameter addiu_op = 6'b001001;
parameter j_op = 6'b000010;
parameter jal_op = 6'b000011;
parameter slti_op = 6'b001010;
parameter beq_op = 6'b000100;
parameter bne_op = 6'b000101;
parameter ble_op = 6'b000110;
parameter bgt_op = 6'b000111;
parameter reset_op = 6'b111111;
parameter lui_op = 6'b001111;
parameter lw_op = 6'b100011;
parameter lh_op = 6'b100001;
parameter lb_op = 6'b100000;
parameter sw_op = 6'b101011;
parameter sh_op = 6'b101001;
parameter sb_op = 6'b101000;

// funct 
parameter add_funct = 6'b100000;
parameter sub_funct = 6'b100010;
parameter and_funct = 6'b100100;
parameter sll_funct = 6'b000000;
parameter slt_funct = 6'b101010;
parameter sra_funct = 6'b000011;
parameter srl_funct = 6'b000010;
parameter sllv_funct = 6'b000100;
parameter srav_funct = 6'b000111;
parameter jr_funct = 6'b001000;
parameter mfhi_funct = 6'b010000;
parameter mflo_funct = 6'b010010;
parameter break_funct = 6'b001101;
parameter rte_funct = 6'b010011;

initial begin
    reset_out = 1'b1;
end

always @(posedge clock) begin
    if (reset == 1'b1) begin
        if (state  != reset_st) begin
            state = reset_st;

            PC_control = 1'b0;
            ReadWrite = 1'b0;
            IRWrite = 1'b0;
            RegWrite = 1'b0;
            AWrite = 1'b0;
            BWrite = 1'b0;
            ULAop = 3'b000;
            ULAout_ctrl = 1'b0;
            srcA_selector = 1'b0;
            srcB_selector = 2'b00;
            HI_write = 1'b0;
            LO_write = 1'b0;
            REGDEST_SELETOR = 2'b00;
            MEMtoREG_SELETOR = 4'b0000;
            pcsrc_selector = 3'b000;
            iord_selector = 2'b00;
            SScontrol = 2'b00;
            LScontrol = 2'b00;
            MemDataReg_write = 1'b0;
            shiftAmt = 1'b0;
            shiftSrc = 1'b0;
            shiftCtrl = 3'b000;
            excpCtrl = 2'b00;
            excpCtrl2 = 2'b00;
            EPCCtrl = 1'b0;
            reset_out = 1'b1;  //

            counter = 3'b000;
        end
        else begin
            state = common_st;

            PC_control = 1'b0;
            ReadWrite = 1'b0;
            IRWrite = 1'b0;
            RegWrite = 1'b0;
            AWrite = 1'b0;
            BWrite = 1'b0;
            ULAop = 3'b000;
            ULAout_ctrl = 1'b0;
            srcA_selector = 1'b0;
            srcB_selector = 2'b00;
            HI_write = 1'b0;
            LO_write = 1'b0;
            REGDEST_SELETOR = 2'b00;
            MEMtoREG_SELETOR = 4'b0000;
            pcsrc_selector = 3'b000;
            iord_selector = 2'b00;
            SScontrol = 2'b00;
            LScontrol = 2'b00;
            MemDataReg_write = 1'b0;
            shiftAmt = 1'b0;
            shiftSrc = 1'b0;
            shiftCtrl = 3'b000;
            excpCtrl = 2'b00;
            excpCtrl2 = 2'b00;
            EPCCtrl = 1'b0;
            reset_out = 1'b0;  //

            counter = 3'b000;
        end
    end
    else begin
        case (state)
            common_st: begin
                if (counter == 3'b000 || counter == 3'b001 || counter == 3'b010) begin
                    state = common_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;      //
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b001;  //
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;       //
                    srcB_selector = 2'b01;      //
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b011) begin
                    state = common_st;

                    PC_control = 1'b1;       //
                    ReadWrite = 1'b0;
                    IRWrite = 1'b1;       //
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b001;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b01;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b100) begin
                    state = common_st;

                    PC_control = 1'b0;       //
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;       //
                    RegWrite = 1'b0;       //
                    AWrite = 1'b1;        //
                    BWrite = 1'b1;        //
                    ULAop = 3'b001;  //
                    ULAout_ctrl = 1'b1;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b11;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b101) begin
                    case (OPCODE)
                        R: begin
                            case (OFFSET[5:0])
                                add_funct: begin
                                    state = add_st;
                                end

                                sub_funct: begin
                                    state = sub_st;
                                end

                                and_funct: begin
                                    state = and_st;
                                end

                                sll_funct: begin
                                    state = sll_st;
                                end

                                slt_funct: begin
                                    state = slt_st;
                                end

                                sra_funct: begin
                                    state = sra_st;
                                end

                                srl_funct: begin
                                    state = srl_st;
                                end

                                sllv_funct: begin
                                    state = sllv_st;
                                end

                                srav_funct: begin
                                    state = srav_st;
                                end

                                jr_funct: begin
                                    state = jr_st;
                                end

                                mfhi_funct: begin
                                    state = mfhi_st;
                                end

                                mflo_funct: begin
                                    state = mflo_st;
                                end

                                break_funct: begin
                                    state = break_st;
                                end

                                rte_funct: begin
                                    state = rte_st;
                                end

                            endcase
                        end

                        reset_op: begin
                            state = reset_st;
                        end

                        addi_op: begin
                            state = addi_st;
                        end

                        addiu_op: begin
                            state = addiu_st;
                        end

                        j_op: begin
                            state = j_st;
                        end

                        jal_op: begin
                            state = jal_st;
                        end

                        slti_op: begin
                            state = slti_st;
                        end

                        beq_op: begin
                            state = beq_st;
                        end

                        bne_op: begin
                            state = bne_st;
                        end

                        ble_op: begin
                            state = ble_st;
                        end

                        bgt_op: begin
                            state = bgt_st;
                        end

                        lui_op: begin
                            state = lui_st;
                        end

                        lw_op: begin
                            state = loads_st;
                        end

                        lh_op: begin
                            state = loads_st;
                        end

                        lb_op: begin
                            state = loads_st;
                        end

                        sw_op: begin
                            state = stores_st;
                        end

                        sh_op: begin
                            state = stores_st;
                        end

                        sb_op: begin
                            state = stores_st;
                        end

                    endcase

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;      
                    RegWrite = 1'b0;       
                    AWrite = 1'b0;        
                    BWrite = 1'b0;       
                    ULAop = 3'b000;  
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = 3'b000;
                end
            end

            add_st: begin
                if (counter == 3'b000) begin
                    state = add_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b001;
                    ULAout_ctrl = 1'b1;
                    srcA_selector = 1'b1;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end
                
                else if (counter == 3'b001) begin
                    if (Overflow) begin
                        state = overflow_st;
                    end else begin
                        state = common_st;   
                    end

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b001;
                    ULAout_ctrl = 1'b1;
                    srcA_selector = 1'b1;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b01;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = 3'b000;
                end
            end

            reset_st: begin
                if (counter == 3'b000) begin
                    state = reset_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b000;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b1;

                    counter = 3'b000;
                end
            end

            addi_st: begin
                if (counter == 3'b000) begin
                    state = addi_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b001;
                    ULAout_ctrl = 1'b1;
                    srcA_selector = 1'b1;
                    srcB_selector = 2'b10;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b001) begin
                    if (Overflow) begin
                        state = overflow_st;
                    end else begin
                        state = common_st;   
                    end

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b001;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b1;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = 3'b000;
                end
            end

            addiu_st: begin
                if (counter == 3'b000) begin
                    state = addiu_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b001;
                    ULAout_ctrl = 1'b1;
                    srcA_selector = 1'b1;
                    srcB_selector = 2'b10;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b001) begin
                    state = common_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b001;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b1;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = 3'b000;
                end
            end

            sub_st: begin
                if (counter == 3'b000) begin
                    state = sub_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b010;
                    ULAout_ctrl = 1'b1;
                    srcA_selector = 1'b1;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b001) begin
                    if (Overflow) begin
                        state = overflow_st;
                    end else begin
                        state = common_st;   
                    end

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b010;
                    ULAout_ctrl = 1'b1;
                    srcA_selector = 1'b1;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b01;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = 3'b000;
                end
            end

            and_st: begin
                if (counter == 3'b000) begin
                    state = and_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b011;
                    ULAout_ctrl = 1'b1;
                    srcA_selector = 1'b1;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b001) begin
                    state = common_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b011;
                    ULAout_ctrl = 1'b1;
                    srcA_selector = 1'b1;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b01;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = 3'b000;
                end
            end

            sll_st: begin
                if (counter == 3'b000) begin
                    state = sll_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b000;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b01;
                    MEMtoREG_SELETOR = 4'b1000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b1;
                    shiftSrc = 1'b1;
                    shiftCtrl = 3'b001;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end

                else if (counter == 3'b001) begin
                    state = sll_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b000;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b01;
                    MEMtoREG_SELETOR = 4'b1000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b010;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end

                else if (counter == 3'b010) begin
                    state = common_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b000;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b01;
                    MEMtoREG_SELETOR = 4'b0010;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b010;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = 3'b000;
                end

            end

            slt_st: begin
                state = common_st;

                PC_control = 1'b0;
                ReadWrite = 1'b0;
                IRWrite = 1'b0;
                RegWrite = 1'b1;
                AWrite = 1'b0;
                BWrite = 1'b0;
                ULAop = 3'b111;
                ULAout_ctrl = 1'b0;
                srcA_selector = 1'b1;
                srcB_selector = 2'b00;
                HI_write = 1'b0;
                LO_write = 1'b0;
                REGDEST_SELETOR = 2'b01;
                MEMtoREG_SELETOR = 4'b0001;
                pcsrc_selector = 3'b000;
                iord_selector = 2'b00;
                SScontrol = 2'b00;
                LScontrol = 2'b00;
                MemDataReg_write = 1'b0;
                shiftAmt = 1'b0;
                shiftSrc = 1'b0;
                shiftCtrl = 3'b000;
                excpCtrl = 2'b00;
                excpCtrl2 = 2'b00;
                EPCCtrl = 1'b0;
                reset_out = 1'b0;

                counter = 3'b000;
            end

            sra_st: begin
                if (counter == 3'b000) begin
                    state = sra_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b000;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b01;
                    MEMtoREG_SELETOR = 4'b1000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b1;
                    shiftSrc = 1'b1;
                    shiftCtrl = 3'b001;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end

                else if (counter == 3'b001) begin
                    state = sra_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b000;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b01;
                    MEMtoREG_SELETOR = 4'b1000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b100;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end

                else if (counter == 3'b010) begin
                    state = common_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b000;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b01;
                    MEMtoREG_SELETOR = 4'b0010;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b010;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = 3'b000;
                end
            end

            srl_st: begin
                if (counter == 3'b000) begin
                    state = srl_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b000;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b01;
                    MEMtoREG_SELETOR = 4'b1000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b1;
                    shiftSrc = 1'b1;
                    shiftCtrl = 3'b001;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end

                else if (counter == 3'b001) begin
                    state = srl_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b000;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b01;
                    MEMtoREG_SELETOR = 4'b1000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b011;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end

                else if (counter == 3'b010) begin
                    state = common_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b000;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b01;
                    MEMtoREG_SELETOR = 4'b0010;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b010;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = 3'b000;
                end
            end

            sllv_st: begin
                if (counter == 3'b000) begin
                    state = sllv_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b000;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b01;
                    MEMtoREG_SELETOR = 4'b1000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b001;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end

                else if (counter == 3'b001) begin
                    state = sllv_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b000;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b01;
                    MEMtoREG_SELETOR = 4'b1000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b010;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end

                else if (counter == 3'b010) begin
                    state = common_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b000;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b01;
                    MEMtoREG_SELETOR = 4'b0010;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b010;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = 3'b000;
                end
            end

            srav_st: begin
                if (counter == 3'b000) begin
                    state = srav_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b000;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b01;
                    MEMtoREG_SELETOR = 4'b1000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b001;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end

                else if (counter == 3'b001) begin
                    state = srav_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b000;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b01;
                    MEMtoREG_SELETOR = 4'b1000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b100;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end

                else if (counter == 3'b010) begin
                    state = common_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b000;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b01;
                    MEMtoREG_SELETOR = 4'b0010;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b010;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = 3'b000;
                end
            end

            slti_st: begin
                state = common_st;

                PC_control = 1'b0;
                ReadWrite = 1'b0;
                IRWrite = 1'b0;
                RegWrite = 1'b1;
                AWrite = 1'b0;
                BWrite = 1'b0;
                ULAop = 3'b111;
                ULAout_ctrl = 1'b0;
                srcA_selector = 1'b1;
                srcB_selector = 2'b10;
                HI_write = 1'b0;
                LO_write = 1'b0;
                REGDEST_SELETOR = 2'b00;
                MEMtoREG_SELETOR = 4'b0001;
                pcsrc_selector = 3'b000;
                iord_selector = 2'b00;
                SScontrol = 2'b00;
                LScontrol = 2'b00;
                MemDataReg_write = 1'b0;
                shiftAmt = 1'b0;
                shiftSrc = 1'b0;
                shiftCtrl = 3'b000;
                excpCtrl = 2'b00;
                excpCtrl2 = 2'b00;
                EPCCtrl = 1'b0;
                reset_out = 1'b0;

                counter = 3'b000;
            end

            j_st: begin
                state = common_st;

                PC_control = 1'b1;              //
                ReadWrite = 1'b0;
                IRWrite = 1'b0;
                RegWrite = 1'b0;
                AWrite = 1'b0;
                BWrite = 1'b0;
                ULAop = 3'b000;
                ULAout_ctrl = 1'b0;
                srcA_selector = 1'b0;
                srcB_selector = 2'b00;
                HI_write = 1'b0;
                LO_write = 1'b0;
                REGDEST_SELETOR = 2'b00;
                MEMtoREG_SELETOR = 4'b0000;
                pcsrc_selector = 3'b001;          //
                iord_selector = 2'b00;
                SScontrol = 2'b00;
                LScontrol = 2'b00;
                MemDataReg_write = 1'b0;
                shiftAmt = 1'b0;
                shiftSrc = 1'b0;
                shiftCtrl = 3'b000;
                excpCtrl = 2'b00;
                excpCtrl2 = 2'b00;
                EPCCtrl = 1'b0;
                reset_out = 1'b0;

                counter = 3'b000;
            end

            jal_st: begin
                if (counter == 3'b000) begin
                    state = jal_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b000;
                    ULAout_ctrl = 1'b1;     //
                    srcA_selector = 1'b0;   //
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end
                else if (3'b001) begin
                    state = common_st;    //

                    PC_control = 1'b1;    //
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1;      //
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b000;
                    ULAout_ctrl = 1'b0; 
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b10;    //
                    MEMtoREG_SELETOR = 4'b0000; //
                    pcsrc_selector = 3'b001;     //
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = 3'b000;  //
                end
            end

            jr_st: begin
                state = common_st;

                PC_control = 1'b1;              //
                ReadWrite = 1'b0;
                IRWrite = 1'b0;
                RegWrite = 1'b0;
                AWrite = 1'b0;
                BWrite = 1'b0;
                ULAop = 3'b000;                 //
                ULAout_ctrl = 1'b0;
                srcA_selector = 1'b1;           //
                srcB_selector = 2'b00;
                HI_write = 1'b0;
                LO_write = 1'b0;
                REGDEST_SELETOR = 2'b00;
                MEMtoREG_SELETOR = 4'b0000;
                pcsrc_selector = 3'b000;          //
                iord_selector = 2'b00;
                SScontrol = 2'b00;
                LScontrol = 2'b00;
                MemDataReg_write = 1'b0;
                shiftAmt = 1'b0;
                shiftSrc = 1'b0;
                shiftCtrl = 3'b000;
                excpCtrl = 2'b00;
                excpCtrl2 = 2'b00;
                EPCCtrl = 1'b0;
                reset_out = 1'b0;

                counter = 3'b000;
            end

            beq_st: begin
                if (counter == 3'b000) begin
                    state = beq_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b111;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b1;
                    srcB_selector = 2'b00;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b010;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b001) begin
                    state = common_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b111;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b1;
                    srcB_selector = 2'b00;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b010;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = 3'b000;

                    if (EQ == 1'b1) begin
                        PC_control = 1'b1;
                    end

                    else if (EQ == 1'b0) begin
                        PC_control = 1'b0;
                    end
                end
            end

            bne_st: begin
                if (counter == 3'b000) begin
                    state = bne_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b111;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b1;
                    srcB_selector = 2'b00;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b010;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b001) begin
                    state = common_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b111;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b1;
                    srcB_selector = 2'b00;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b010;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = 3'b000;

                    if (EQ == 1'b0) begin
                        PC_control = 1'b1;
                    end

                    else if (EQ == 1'b1) begin
                        PC_control = 1'b0;
                    end
                end
            end

            ble_st: begin
                if (counter == 3'b000) begin
                    state = ble_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b111;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b1;
                    srcB_selector = 2'b00;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b010;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b001) begin
                    state = common_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b111;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b1;
                    srcB_selector = 2'b00;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b010;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = 3'b000;

                    if (GT == 1'b0) begin
                        PC_control = 1'b1;
                    end

                    else if (GT == 1'b1) begin
                        PC_control = 1'b0;
                    end
                end
            end

            bgt_st: begin
                if (counter == 3'b000) begin
                    state = bgt_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b111;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b1;
                    srcB_selector = 2'b00;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b010;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b001) begin
                    state = common_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b111;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b1;
                    srcB_selector = 2'b00;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b010;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = 3'b000;

                    if (GT == 1'b1) begin
                        PC_control = 1'b1;
                    end

                    else if (GT == 1'b0) begin
                        PC_control = 1'b0;
                    end
                end
            end

            mfhi_st: begin
                state = common_st;

                PC_control = 1'b0;
                ReadWrite = 1'b0;
                IRWrite = 1'b0;
                RegWrite = 1'b1; //
                AWrite = 1'b0;
                BWrite = 1'b0;
                ULAop = 3'b000;
                ULAout_ctrl = 1'b0;
                srcA_selector = 1'b0;
                srcB_selector = 2'b00;
                HI_write = 1'b0;
                LO_write = 1'b0;
                REGDEST_SELETOR = 2'b01; //
                MEMtoREG_SELETOR = 4'b0011; //
                pcsrc_selector = 3'b000;
                iord_selector = 2'b00;
                SScontrol = 2'b00;
                LScontrol = 2'b00;
                MemDataReg_write = 1'b0;
                shiftAmt = 1'b0;
                shiftSrc = 1'b0;
                shiftCtrl = 3'b000;
                excpCtrl = 2'b00;
                excpCtrl2 = 2'b00;
                EPCCtrl = 1'b0;
                reset_out = 1'b0;

                counter = 3'b000;
            end

            mflo_st: begin
                state = common_st;

                PC_control = 1'b0;
                ReadWrite = 1'b0;
                IRWrite = 1'b0;
                RegWrite = 1'b1; //
                AWrite = 1'b0;
                BWrite = 1'b0;
                ULAop = 3'b000;
                ULAout_ctrl = 1'b0;
                srcA_selector = 1'b0;
                srcB_selector = 2'b00;
                HI_write = 1'b0;
                LO_write = 1'b0;
                REGDEST_SELETOR = 2'b01; //
                MEMtoREG_SELETOR = 4'b0100; //
                pcsrc_selector = 3'b000;
                iord_selector = 2'b00;
                SScontrol = 2'b00;
                LScontrol = 2'b00;
                MemDataReg_write = 1'b0;
                shiftAmt = 1'b0;
                shiftSrc = 1'b0;
                shiftCtrl = 3'b000;
                excpCtrl = 2'b00;
                excpCtrl2 = 2'b00;
                EPCCtrl = 1'b0;
                reset_out = 1'b0;

                counter = 3'b000;
            end

            break_st: begin
                if (counter == 3'b000) begin
                    state = break_st;

                    PC_control = 1'b1; //
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b010; //
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b01; //
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b001) begin
                    state = break_st;

                    PC_control = 1'b0; //
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b000; //
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b00; //
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                end
            end

            lui_st: begin
                state = common_st;

                PC_control = 1'b0;  
                ReadWrite = 1'b0;
                IRWrite = 1'b0;
                RegWrite = 1'b1; //
                AWrite = 1'b0;
                BWrite = 1'b0;
                ULAop = 3'b000;  
                ULAout_ctrl = 1'b0;
                srcA_selector = 1'b0;
                srcB_selector = 2'b00;
                HI_write = 1'b0;
                LO_write = 1'b0;
                REGDEST_SELETOR = 2'b00; //
                MEMtoREG_SELETOR = 4'b0101; //
                pcsrc_selector = 3'b000; 
                iord_selector = 2'b00;
                SScontrol = 2'b00;
                LScontrol = 2'b00;
                MemDataReg_write = 1'b0;
                shiftAmt = 1'b0;
                shiftSrc = 1'b0;
                shiftCtrl = 3'b000;
                excpCtrl = 2'b00;
                excpCtrl2 = 2'b00;
                EPCCtrl = 1'b0;
                reset_out = 1'b0;

                counter = 3'b000;
            end

            loads_st: begin
                // clock 1
                if (counter == 3'b000) begin
                    state = loads_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0; //
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b001; // ADD
                    ULAout_ctrl = 1'b1; // 
                    srcA_selector = 1'b1; //
                    srcB_selector = 2'b10; //
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00;
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end
                // clock 2 - wait 1
                else if (counter == 3'b001) begin

                    state = loads_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0; //
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b000;
                    ULAout_ctrl = 1'b0; 
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b10; //
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b1; //
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;

                end
                // clock 3 - wait 2
                else if (counter == 3'b010) begin
                    case(OPCODE)
                        lw_op : begin
                            state = lw_st;
                        end
                        lh_op: begin
                            state = lh_st;
                        end
                        lb_op: begin
                            state = lb_st;
                        end
                    endcase

                    PC_control = 1'b0;
                    ReadWrite = 1'b0; //
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b000;
                    ULAout_ctrl = 1'b0; 
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b10; //
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b1; //
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;
                    
                    counter = 3'b000;
                end

            end

            lw_st: begin
                if (counter == 3'b000) begin

                    state = lw_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1; //
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b000;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00; //
                    MEMtoREG_SELETOR = 4'b0110; //
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00; 
                    SScontrol = 2'b00;
                    LScontrol = 2'b01; //
                    MemDataReg_write = 1'b1; // ????????
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;

                end
                else if (counter == 3'b001) begin
                    state = common_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1; //
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b000;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00; //
                    MEMtoREG_SELETOR = 4'b0110; //
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00; 
                    SScontrol = 2'b00;
                    LScontrol = 2'b01; //
                    MemDataReg_write = 1'b0; // 
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = 3'b000;
                end

            end

            lh_st: begin
                if (counter == 3'b000) begin

                    state = lh_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1; //
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b000;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00; //
                    MEMtoREG_SELETOR = 4'b0110; //
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00; 
                    SScontrol = 2'b00;
                    LScontrol = 2'b10; //
                    MemDataReg_write = 1'b1; // ????????
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;

                end
                else if (counter == 3'b001) begin
                    state = common_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1; //
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b000;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00; //
                    MEMtoREG_SELETOR = 4'b0110; //
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00; 
                    SScontrol = 2'b00;
                    LScontrol = 2'b10; //
                    MemDataReg_write = 1'b0; // 
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = 3'b000;
                end

            end

            lb_st: begin
                if (counter == 3'b000) begin

                    state = lb_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1; //
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b000;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00; //
                    MEMtoREG_SELETOR = 4'b0110; //
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00; 
                    SScontrol = 2'b00;
                    LScontrol = 2'b11; //
                    MemDataReg_write = 1'b1; // ????????
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;

                end
                else if (counter == 3'b001) begin
                    state = common_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1; //
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b000;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b00;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00; //
                    MEMtoREG_SELETOR = 4'b0110; //
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b00; 
                    SScontrol = 2'b00;
                    LScontrol = 2'b11; //
                    MemDataReg_write = 1'b0; // 
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = 3'b000;
                end
            end

            stores_st: begin
                // clock 1
                if (counter == 3'b000) begin
                    state = stores_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0; //
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b001; //
                    ULAout_ctrl = 1'b1; //
                    srcA_selector = 1'b1; //
                    srcB_selector = 2'b10; //
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b10; //
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end
                // clock 2 - wait 1
                else if (counter == 3'b001) begin
                    state = stores_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0; //
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b001; //
                    ULAout_ctrl = 1'b0; //
                    srcA_selector = 1'b1; //
                    srcB_selector = 2'b10; //
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b10; //
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end
                // clock 3 - wait 2
                else if (counter == 3'b010) begin
                    state = stores_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0; //
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b001; //
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b1; //
                    srcB_selector = 2'b10; //
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b10; //
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end
                // clock 4 - wait 3
                else if (counter == 3'b011) begin
                    case(OPCODE)
                        sw_op : begin
                            state = sw_st;
                        end
                        sh_op: begin
                            state = sh_st;
                        end
                        sb_op: begin
                            state = sb_st;
                        end
                    endcase

                    PC_control = 1'b0;
                    ReadWrite = 1'b0; //
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b001; //
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b1; //
                    srcB_selector = 2'b10; //
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b10; //
                    SScontrol = 2'b00;
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b1; //
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b00;
                    excpCtrl2 = 2'b00;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = 3'b000;
                end

            end

            sw_st: begin

                state = common_st;

                PC_control = 1'b0;
                ReadWrite = 1'b1; //
                IRWrite = 1'b0;
                RegWrite = 1'b0;
                AWrite = 1'b0;
                BWrite = 1'b0;
                ULAop = 3'b000; 
                ULAout_ctrl = 1'b0;
                srcA_selector = 1'b0;
                srcB_selector = 2'b00;
                HI_write = 1'b0;
                LO_write = 1'b0;
                REGDEST_SELETOR = 2'b00;
                MEMtoREG_SELETOR = 4'b0000;
                pcsrc_selector = 3'b000;
                iord_selector = 2'b10; //
                SScontrol = 2'b01; //
                LScontrol = 2'b00;
                MemDataReg_write = 1'b0;
                shiftAmt = 1'b0;
                shiftSrc = 1'b0;
                shiftCtrl = 3'b000;
                excpCtrl = 2'b00;
                excpCtrl2 = 2'b00;
                EPCCtrl = 1'b0;
                reset_out = 1'b0;

                counter = 3'b000;
                
            end

            sh_st: begin
                state = common_st;

                PC_control = 1'b0;
                ReadWrite = 1'b1; //
                IRWrite = 1'b0;
                RegWrite = 1'b0;
                AWrite = 1'b0;
                BWrite = 1'b0;
                ULAop = 3'b000; 
                ULAout_ctrl = 1'b0;
                srcA_selector = 1'b0;
                srcB_selector = 2'b00;
                HI_write = 1'b0;
                LO_write = 1'b0;
                REGDEST_SELETOR = 2'b00;
                MEMtoREG_SELETOR = 4'b0000;
                pcsrc_selector = 3'b000;
                iord_selector = 2'b10; //
                SScontrol = 2'b10; //
                LScontrol = 2'b00;
                MemDataReg_write = 1'b0;
                shiftAmt = 1'b0;
                shiftSrc = 1'b0;
                shiftCtrl = 3'b000;
                excpCtrl = 2'b00;
                excpCtrl2 = 2'b00;
                EPCCtrl = 1'b0;
                reset_out = 1'b0;

                counter = 3'b000;

            end

            sb_st: begin
                state = common_st;

                PC_control = 1'b0;
                ReadWrite = 1'b1; //
                IRWrite = 1'b0;
                RegWrite = 1'b0;
                AWrite = 1'b0;
                BWrite = 1'b0;
                ULAop = 3'b000; 
                ULAout_ctrl = 1'b0;
                srcA_selector = 1'b0;
                srcB_selector = 2'b00;
                HI_write = 1'b0;
                LO_write = 1'b0;
                REGDEST_SELETOR = 2'b00;
                MEMtoREG_SELETOR = 4'b0000;
                pcsrc_selector = 3'b000;
                iord_selector = 2'b10; //
                SScontrol = 2'b11; //
                LScontrol = 2'b00;
                MemDataReg_write = 1'b0;
                shiftAmt = 1'b0;
                shiftSrc = 1'b0;
                shiftCtrl = 3'b000;
                excpCtrl = 2'b00;
                excpCtrl2 = 2'b00;
                EPCCtrl = 1'b0;
                reset_out = 1'b0;

                counter = 3'b000;

            end

            overflow_st: begin
                if (counter == 3'b000) begin
                    state = overflow_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0; //
                    IRWrite = 1'b0;
                    RegWrite = 1'b1;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b010; 
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b01;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b11;
                    MEMtoREG_SELETOR = 4'b0111;
                    pcsrc_selector = 3'b000;
                    iord_selector = 2'b11; //
                    SScontrol = 2'b11; //
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b01;
                    excpCtrl2 = 2'b01;
                    EPCCtrl = 1'b1;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b001) begin
                    state = common_st;

                    PC_control = 1'b1;
                    ReadWrite = 1'b1; //
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b010; 
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b01;
                    HI_write = 1'b0;
                    LO_write = 1'b0;
                    REGDEST_SELETOR = 2'b11;
                    MEMtoREG_SELETOR = 4'b0111;
                    pcsrc_selector = 3'b100;
                    iord_selector = 2'b11; //
                    SScontrol = 2'b11; //
                    LScontrol = 2'b00;
                    MemDataReg_write = 1'b0;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    excpCtrl = 2'b01;
                    excpCtrl2 = 2'b01;
                    EPCCtrl = 1'b0;
                    reset_out = 1'b0;

                    counter = 3'b000;
                end
            end

            rte_st: begin
                state = common_st; //

                PC_control = 1'b1; //
                ReadWrite = 1'b0; 
                IRWrite = 1'b0;
                RegWrite = 1'b0;
                AWrite = 1'b0;
                BWrite = 1'b0;
                ULAop = 3'b000; 
                ULAout_ctrl = 1'b0;
                srcA_selector = 1'b0;
                srcB_selector = 2'b00;
                HI_write = 1'b0;
                LO_write = 1'b0;
                REGDEST_SELETOR = 2'b00;
                MEMtoREG_SELETOR = 4'b0000;
                pcsrc_selector = 3'b011; //
                iord_selector = 2'b00;
                SScontrol = 2'b00;
                LScontrol = 2'b00;
                MemDataReg_write = 1'b0;
                shiftAmt = 1'b0;
                shiftSrc = 1'b0;
                shiftCtrl = 3'b000;
                excpCtrl = 2'b00;
                excpCtrl2 = 2'b00;
                EPCCtrl = 1'b0; 
                reset_out = 1'b0;

                counter = 3'b000; //
            end
            
        endcase
    end
end

endmodule
