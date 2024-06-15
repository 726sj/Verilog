`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/15 16:01:26
// Design Name: 
// Module Name: Reservation
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Reservation( //예약기능
    input clk, reset_p,
    input btn,
    input motor_idle,
    output [3:0] com,
    output [7:0] seg_7,
    output reg led0_b,
    output reg [2:0] led,
    output reg timer_end
    );
    
     //타이머모드 4개 선언
    reg [3:0] timer_mode;
    
    //세팅시간, 현재시간
    wire [15:0] cur_time, set_time; 
    wire [3:0] cur_sec1, cur_sec10, cur_min1, cur_min10; 
    reg [3:0] set_sec1, set_sec10, set_min1, set_min10;
    wire load_enable,dec_clk;   //loadable_downcounter_dec_60
    wire btn_pedge,btn_nedge;        //버튼 p_edge, n_edge 생성
    wire [15:0] value;          //[임시] 7_seg 출력용 value
    
    //시작/정지(clk)
    wire clk_start;
    reg start_stop;
    reg time_out;
    
    assign clk_start = start_stop ? clk : 0;
    assign cur_time = {cur_min10, cur_min1, cur_sec10, cur_sec1};
    assign set_time = {set_min10, set_min1, set_sec10, set_sec1};
    assign value =  cur_time;
    
    clock_set clock(.clk(clk_start), .reset_p(reset_p),  .clk_usec(clk_usec), .clk_msec(clk_msec), .clk_sec(clk_sec));
    
    button_cntr btn_cntr(.clk(clk), .reset_p(reset_p), .btn(btn), .btn_pe(btn_pedge), .btn_ne(btn_nedge));
    
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(start_stop), .p_edge(load_enable));
    
    edge_detector_n ed_timeout(.clk(clk), .reset_p(reset_p), .cp(time_out), .p_edge(timeout_pedge));
    
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_ca(seg_7), .com(com));
    
    loadable_downcounter_dec_60 cur_sec( .clk(clk), .reset_p(reset_p), .clk_time(clk_sec), .load_enable(load_enable),
                                                            .set_value1(set_sec1), .set_value10(set_sec10), .dec1(cur_sec1),
                                                                .dec10(cur_sec10), .dec_clk(dec_clk));
                                                                
    loadable_downcounter_dec_60 cur_min( .clk(clk), .reset_p(reset_p), .clk_time(dec_clk), .load_enable(load_enable),
                                                            .set_value1(set_min1), .set_value10(set_min10), .dec1(cur_min1),
                                                                .dec10(cur_min10));
   
    //전원버튼 입력/정지 ([임시] 0번버튼)
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) start_stop = 0;
        else begin
            if(btn_nedge)start_stop = 1;
            else if(btn_pedge) start_stop = 0;
            else if(timeout_pedge) start_stop = 0;
            else if(timer_mode == 4'b0001)start_stop = 0;
    
        end
    end
    
    //time_out (0h 0m 0s 정지)
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) time_out = 0;
        else begin
            if(start_stop && clk_msec && cur_time == 0) time_out = 1;
            else time_out = 0;
        end
    end
    
    //타이머 동작
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) timer_mode <= 4'b0001;
        else if(btn_pedge) timer_mode <= {timer_mode[2:0],timer_mode[3]};
        else if(time_out) timer_mode <= 4'b0001;
        else if (motor_idle) timer_mode =4'b0001;
    end
    
    //타이머 모드(OFF/1H/3H/5H)
    always @(posedge clk)begin
        case (timer_mode)
            4'b0001:begin       //TIMER_OFF
                set_min1 = 0;
                led[0] = 0;
                led[1] = 0;
                led[2] = 0;
                led0_b = 1;
            end
            4'b0010:begin       //1H
                set_min1 = 1;
                led[0] = 1;
                led[1] = 0;
                led[2] = 0;
                led0_b = 0;
            end
            4'b0100:begin       //3H
                set_min1 = 3;
                led[0] = 0;
                led[1] = 1;
                led[2] = 0;
                led0_b = 0;
            end
            4'b1000:begin       //5H
                set_min1 = 5;
                led[0] = 0;
                led[1] = 0;
                led[2] = 1;
                led0_b = 0;
            end
        endcase
    end
    
    always @(posedge clk or posedge reset_p) begin
        if (reset_p) begin
            timer_end <= 0;
        end
        else if (time_out) begin
            timer_end <= 1;
        end
        else begin
            timer_end <= 0;
        end
    end
endmodule