`timescale 1ns / 1ps

module Clock(
    input clk, reset_p,
    input [4:0] btn,
    output [3:0] com,
    output [7:0] seg_7,
    output buzz_clk
);      
    //파라미터 선언
    parameter WATCH_MODE = 3'b001;
    parameter STOP_WATCH_MODE = 3'b010;
    parameter TIMER_MODE = 3'b100;

    wire [2:0] watch_btn, stopw_btn;
    wire [3:0] timer_btn;
    wire [15:0] value, watch_value, stop_watch_value, timer_value;
    wire [3:0] btn_pedge;
    wire btn_mode;
      
    reg [2:0] mode;
       
    button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
    button_cntr btn_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
    button_cntr btn_cntr2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));
    button_cntr btn_cntr3(.clk(clk), .reset_p(reset_p), .btn(btn[3]), .btn_pe(btn_pedge[3]));    
    button_cntr btn_cntr4(.clk(clk), .reset_p(reset_p), .btn(btn[4]), .btn_pe(btn_mode));   //버튼 생성
        
    //모듈 가져옴(시계, 스톱워치, 타이머)
    loadable_watch watch(clk, reset_p, watch_btn, watch_value);
    stop_watch stop_watch(clk, reset_p, stopw_btn, stop_watch_value);
    timer timer(clk, reset_p, timer_btn, timer_value, buzz_clk);
        
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_an(seg_7), .com(com));
    
    assign value = (mode == TIMER_MODE) ? timer_value:
                        (mode == STOP_WATCH_MODE) ? stop_watch_value : watch_value;

    //Demux
    assign {timer_btn, stopw_btn, watch_btn} = (mode == WATCH_MODE) ? {7'b0, btn_pedge[2:0]} :
                       (mode == STOP_WATCH_MODE) ? {4'b0, btn_pedge[2:0], 3'b0} : {btn_pedge[3:0], 6'b0};

    //링카운트
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) mode = WATCH_MODE;
        else if(btn_mode)begin
            case(mode)
            WATCH_MODE : mode = STOP_WATCH_MODE;
                STOP_WATCH_MODE : mode = TIMER_MODE;
                TIMER_MODE : mode = WATCH_MODE;
                default : mode = WATCH_MODE;
            endcase
        end
    end
endmodule
