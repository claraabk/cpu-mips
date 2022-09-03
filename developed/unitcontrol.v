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
    output reg [1:0] REGDEST_SELETOR,
    output reg [3:0] MEMtoREG_SELETOR,
    output reg shiftAmt,
    output reg shiftSrc,
    output reg [2:0] shiftCtrl,

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
parameter reset_st = 7'b1111111;

// OPCODES
parameter R = 6'b000000;
parameter addi_op = 6'b001000;
parameter reset_op = 6'b111111;

// funct 
parameter add_funct = 6'b100000;
parameter sub_funct = 6'b100010;
parameter and_funct = 6'b100100;
parameter sll_funct = 6'b000000;
parameter slt_funct = 6'b101010 ;

initial begin
    // Lembrete: colocar valor 227 no registrador 29
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
            REGDEST_SELETOR = 2'b00;
            MEMtoREG_SELETOR = 4'b0000;
            shiftAmt = 1'b0;
            shiftSrc = 1'b0;
            shiftCtrl = 3'b000;
            reset_out = 1'b1;  ///

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
            REGDEST_SELETOR = 2'b00;
            MEMtoREG_SELETOR = 4'b0000;
            shiftAmt = 1'b0;
            shiftSrc = 1'b0;
            shiftCtrl = 3'b000;
            reset_out = 1'b0;  ///

            counter = 3'b000;
        end
    end
    else begin
        case (state)
            common_st: begin
                if (counter == 3'b000 || counter == 3'b001 || counter == 3'b010) begin
                    state = common_st;

                    PC_control = 1'b0;
                    ReadWrite = 1'b0;      ///
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b001;  ///
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;       ///
                    srcB_selector = 2'b01;      ///
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b011) begin
                    state = common_st;

                    PC_control = 1'b1;       ///
                    ReadWrite = 1'b0;
                    IRWrite = 1'b1;       ///
                    RegWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ULAop = 3'b001;
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b01;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
                    reset_out = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b100) begin
                    state = common_st;

                    PC_control = 1'b0;       ///
                    ReadWrite = 1'b0;
                    IRWrite = 1'b0;       ///
                    RegWrite = 1'b0;       ///
                    AWrite = 1'b1;        ///
                    BWrite = 1'b1;        ///
                    ULAop = 3'b000;  ///
                    ULAout_ctrl = 1'b0;
                    srcA_selector = 1'b0;
                    srcB_selector = 2'b01;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
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
                            endcase
                        end

                        reset_op: begin
                            state = reset_st;
                        end

                        addi_op: begin
                            state = addi_st;
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
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
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
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
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
                    ULAout_ctrl = 1'b1;
                    srcA_selector = 1'b1;
                    srcB_selector = 2'b00;
                    REGDEST_SELETOR = 2'b01;
                    MEMtoREG_SELETOR = 4'b0000;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
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
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
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
                    ULAop = 3'b010;
                    ULAout_ctrl = 1'b1;
                    srcA_selector = 1'b1;
                    srcB_selector = 2'b10;
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
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
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
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
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
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
                    ULAop = 3'b010;
                    ULAout_ctrl = 1'b1;
                    srcA_selector = 1'b1;
                    srcB_selector = 2'b00;
                    REGDEST_SELETOR = 2'b01;
                    MEMtoREG_SELETOR = 4'b0000;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
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
                    REGDEST_SELETOR = 2'b00;
                    MEMtoREG_SELETOR = 4'b0000;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
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
                    REGDEST_SELETOR = 2'b01;
                    MEMtoREG_SELETOR = 4'b0000;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b000;
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
                    REGDEST_SELETOR = 2'b01;
                    MEMtoREG_SELETOR = 4'b1000;
                    shiftAmt = 1'b1;
                    shiftSrc = 1'b1;
                    shiftCtrl = 3'b001;
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
                    REGDEST_SELETOR = 2'b01;
                    MEMtoREG_SELETOR = 4'b1000;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b010;
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
                    REGDEST_SELETOR = 2'b01;
                    MEMtoREG_SELETOR = 4'b1000;
                    shiftAmt = 1'b0;
                    shiftSrc = 1'b0;
                    shiftCtrl = 3'b010;
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
                REGDEST_SELETOR = 2'b01;
                MEMtoREG_SELETOR = 4'b0100;
                shiftAmt = 1'b0;
                shiftSrc = 1'b0;
                shiftCtrl = 3'b000;
                reset_out = 1'b0;

                counter = 3'b000;
            end
        endcase
    end
end

endmodule
