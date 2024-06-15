module Ultrasensor(
    input clk, reset_p,
    input echo, 
    output reg trigger,
    output reg [11:0] distance,
    output [3:0] led_bar,
    output reg motor_off_ultrasonic,
    output reg buzz
);
    
    parameter S_IDLE    = 3'b001;
    parameter TRI_10US  = 3'b010;
    parameter ECHO_STATE= 3'b100;
    
    parameter S_WAIT_PEDGE = 2'b01;
    parameter S_WAIT_NEDGE = 2'b10;
    
    wire clk_usec;
    reg [21:0] count_usec;
    reg count_usec_e;
    
    wire [11:0] cm;
    wire echo_pedge, echo_nedge;
    reg [3:0] state, next_state;
    reg [1:0] read_state;
    reg [11:0] echo_time;
    reg cnt_e;

    clock_usec usec_clk(clk, reset_p, clk_usec);

    sr04_div58 div58(clk, reset_p, clk_usec, cnt_e, cm);
    
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(echo), .p_edge(echo_pedge), .n_edge(echo_nedge));

    assign led_bar[3:0] = state;

    always @(negedge clk or posedge reset_p)begin
        if(reset_p) count_usec = 0;
        else begin
            if(clk_usec && count_usec_e) count_usec = count_usec + 1;
            else if(!count_usec_e) count_usec = 0;
        end
    end

    always @(negedge clk or posedge reset_p)begin
        if(reset_p) state = S_IDLE;
        else state = next_state;
    end
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            count_usec_e = 0;
            next_state = S_IDLE;
            trigger = 0;
            read_state = S_WAIT_PEDGE;
        end
        else begin
            case(state)
                S_IDLE:begin
                    if(count_usec < 22'd100_000)begin 
                        count_usec_e = 1; 
                    end
                    else begin 
                        next_state = TRI_10US;
                        count_usec_e = 0; 
                    end
                end
                TRI_10US:begin 
                    if(count_usec <= 22'd10)begin 
                        count_usec_e = 1;
                        trigger = 1;
                    end
                    else begin
                        count_usec_e = 0;
                        trigger = 0;
                        next_state = ECHO_STATE;
                    end
                end
                ECHO_STATE:begin 
                    case(read_state)
                        S_WAIT_PEDGE:begin
                            count_usec_e = 0;
                            if(echo_pedge)begin
                                read_state = S_WAIT_NEDGE;
                                cnt_e = 1;
                            end
                        end
                        S_WAIT_NEDGE:begin
                            if(echo_nedge)begin       
                                read_state = S_WAIT_PEDGE;
                                count_usec_e = 0;                    
                                distance = cm;
                                cnt_e = 0;
                                next_state = S_IDLE;
                            end
                            else begin
                                count_usec_e = 1;
                            end
                        end
                    endcase
                end
                default:next_state = S_IDLE;
            endcase
        end
    end
    
    always @(*) begin
        if(reset_p) begin
            motor_off_ultrasonic=0;
        end
        else begin
            if (distance >= 80) // 거리가 80cm 이상일 경우 (사람이 앞에 없는 경우)
                motor_off_ultrasonic = 1; // 모터를 끕니다.
            else if (distance <= 7) // 거리가 7cm 이하일 경우 (너무 가까워 위험한 경우)
                motor_off_ultrasonic = 1; // 모터를 끕니다.
            else // 그 외의 경우
                motor_off_ultrasonic = 0; // 모터를 켭니다.
        end
    end
endmodule