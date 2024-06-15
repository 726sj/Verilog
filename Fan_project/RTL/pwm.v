`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/15 16:16:23
// Design Name: 
// Module Name: pwm
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


module pwm_100pc_project(
    input clk, reset_p,
    input [6:0] duty,
    input [13:0] pwm_freq,
    output reg pwm_100pc);
    
    parameter sys_clk_freq = 125_000_000; //100MHz / cora?? 125MHz
    
    reg [26:0] cnt;      //?? 134_000_000
//    reg pwm_clk;
    reg pwm_freqX100;  //10000 x 100
        
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            pwm_freqX100 = 0;
            cnt = 0;
        end
        else begin
            if(cnt >= sys_clk_freq / pwm_freq/100 - 1)   cnt = 0;
            else cnt = cnt+1;
     
            //if pwm_freqX100 = ~pwm_freqX100;
            if (cnt < sys_clk_freq / pwm_freq /100 / 2)  pwm_freqX100 = 0;
            else pwm_freqX100 = 1;
        end
    end
    
    wire pwm_freqX100_nedge;
    edge_detector_n pwm_freq100_ed(.clk(clk), .reset_p(reset_p), .cp(pwm_freqX100), .n_edge(pwm_freqX100_nedge));
    
    reg [6:0] cnt_duty; //100??% ????? ????
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) begin
            cnt_duty = 0;
            pwm_100pc = 0;
        end
        else begin
            if(pwm_freqX100_nedge)begin
                if(cnt_duty >99) cnt_duty = 0;
                else cnt_duty = cnt_duty + 1;
                if(cnt_duty<duty) pwm_100pc = 1;
                else pwm_100pc = 0; 
            end
            else begin
            
            end
        end
    end 
endmodule

module pwm_128step_last(
    input clk, reset_p,
    input [6:0] duty,
    input [13:0] pwm_freq,
    output reg pwm_128);
    
    parameter sys_clk_freq = 125000000; //cora : 125_000_000
    
    reg [26:0] cnt = 0;
    reg pwm_freqX128;
    wire [26:0] temp;

    assign temp = sys_clk_freq >> pwm_freq;
   
    
    always @(posedge clk, posedge reset_p) begin
        if (reset_p) begin
            pwm_freqX128 = 0;
            cnt = 0;
        end
        else begin
            if(cnt >= temp[26:8]  - 1)  cnt = 0;
            else cnt =  cnt + 1;
            
            if(cnt < temp[26:9]) pwm_freqX128 = 0;
            else pwm_freqX128 = 1;
        end
    end    
    
    wire pwm_freqX128_nedge;
    
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(pwm_freqX128), .n_edge(pwm_freqX128_nedge));
    
    reg [6:0] cnt_duty;
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            cnt_duty = 0;
            pwm_128 = 0;         
        end
        else begin
            if(pwm_freqX128_nedge) begin
                cnt_duty = cnt_duty + 1;
                
                if(cnt_duty < duty) pwm_128 = 1;
                else pwm_128 = 0;
            end
        end
    end   
endmodule

module pwm512_period(
    input clk, reset_p,
    input [20:0] duty,
    input [20:0] pwm_period,
    output reg pwm_512
);  
    parameter sys_clk_freq = 125_000_000;    //cora | basys´Â 100_000_000
    reg [20:0] cnt_duty;

    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            cnt_duty = 0;
            pwm_512 = 0;
        end
        else begin
            if(cnt_duty >= pwm_period)cnt_duty = 0;
            else cnt_duty = cnt_duty + 1;

            if(cnt_duty < duty)pwm_512 = 1;
            else pwm_512 = 0;
        end
    end
endmodule