`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/15 16:20:13
// Design Name: 
// Module Name: Rotation
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


module Rotation(
    input clk, reset_p,
    input btn,
    input motor_pwm,
    input motor_idle,
    input timer_end,
    output s_motor_pwm
);
    //clk_div 
    wire clk_div_pedge;
    reg [31:0] clk_div;
       
    wire btn_pedge;
    wire clk_start;

    reg [21:0] duty;
    reg start_stop;
    reg up_down;

    edge_detector_n ed_time(.clk(clk_start), .reset_p(reset_p), .cp(clk_div[17]), .p_edge(clk_div_pedge));

    
    button_cntr btn_cntr(.clk(clk), .reset_p(reset_p), .btn(btn), .btn_pe(btn_pedge));

    pwm512_period pwm_ser(.clk(clk), .reset_p(reset_p), .duty(duty), 
                                          .pwm_period(3_000_000), .pwm_512(s_motor_pwm));
        
    assign clk_start = start_stop ? clk : 0;

    //clk_div
    always @(posedge clk) clk_div = clk_div + 1;
    
    //회전버튼  회전/고정
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) start_stop = 0;
        else if(btn_pedge && motor_pwm) begin
            start_stop = ~start_stop;
        end
       else if(start_stop && motor_idle)begin
            start_stop = 0;
        end
        else if(start_stop && timer_end) begin
            start_stop = 0;
        end
    end
    always @(posedge clk)begin      //58000~326000  0~180
        if(clk_div_pedge)begin
            if(duty >= 328_000) up_down = 0;            
            else if(duty <= 126_000)up_down = 1;
                                
            if(up_down)duty = duty + 100;
            else duty = duty - 100;
        end
    end    
endmodule
