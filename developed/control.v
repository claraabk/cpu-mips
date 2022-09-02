module control(
    input wire clock,
    input wire reset,

    input wire [5:0] OPCODE,
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

    output reg reset_out
);

reg [1:0] STATE;
reg [2:0] COUNTER;

parameter ST_COMMON = 2'b00;
parameter ST_ADD = 2'b01;
parameter ST_RESET = 2'b10;

// OPCODES
parameter R = 6'b000000;
parameter RESET = 6'b111111;

// funct 
parameter add_funct = 6'b100000;

initial begin
    // Lembrete: colocar valor 227 no registrador 29
    reset_out = 1'b1;
end

always @(posedge clock) begin
    if (reset == 1'b1) begin
        if (STATE  != ST_RESET) begin
            STATE = ST_RESET;

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
            reset_out = 1'b1;  ///

            COUNTER = 3'b000;
        end
        else begin
            STATE = ST_COMMON;

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
            reset_out = 1'b0;  ///

            COUNTER = 3'b000;
        end
    end
    else begin
        case (STATE)
            ST_COMMON: begin
                if (COUNTER == 3'b000 || COUNTER == 3'b001 || COUNTER == 3'b010) begin
                    STATE = ST_COMMON;

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
                    reset_out = 1'b0;

                    COUNTER = COUNTER + 1;
                end
                else if (COUNTER == 3'b011) begin
                    STATE = ST_COMMON;

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
                    reset_out = 1'b0;

                    COUNTER = COUNTER + 1;
                end
                else if (COUNTER == 3'b100) begin
                    STATE = ST_COMMON;

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
                    reset_out = 1'b0;

                    COUNTER = COUNTER + 1;
                end
                else if (COUNTER == 3'b101) begin
                    case (OPCODE)
                        R: begin
                            case (OFFSET[5:0])
                            add_funct: begin
                                STATE = ST_ADD;
                            end
                            endcase
                        end
                        RESET: begin
                            STATE = ST_RESET;
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
                    reset_out = 1'b0;

                    COUNTER = 3'b000;
                end
            end
            ST_ADD: begin
                if (COUNTER == 3'b000) begin
                    STATE = ST_ADD;

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
                    reset_out = 1'b0;

                    COUNTER = COUNTER + 1;
                end
                else if (COUNTER == 3'b001) begin
                    STATE = ST_COMMON;

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
                    reset_out = 1'b0;

                    COUNTER = 3'b000;
                end
            end
            ST_RESET: begin
                if (COUNTER == 3'b000) begin
                    STATE = ST_RESET;

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
                    reset_out = 1'b1;

                    COUNTER = 3'b000;
                end
            end
        endcase
    end
end

endmodule
