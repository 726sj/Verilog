`timescale 1ns / 1ps

module timer(
    input clk,reset_p,
    input [3:0] btn_pedge,
    output [15:0] value,
    output buzz_clk
);  

    wire [15:0] cur_time, set_time;
    wire [3:0] set_sec1, set_sec10, set_min1, set_min10;        //설정 시간
    wire [3:0] cur_sec1, cur_sec10, cur_min1, cur_min10;        //현재 시간

    wire btn_start, inc_sec, inc_min, alarm_off;
    wire load_enable, dec_clk;
    wire timeout_pedge;
    wire clk_start;
    
    reg [16:0] clk_div = 0;
    reg start_stop;
    reg time_out;
    reg alarm;
        
    assign {alarm_off, inc_min, inc_sec, btn_start} = btn_pedge;
    assign clk_start = start_stop ? clk : 0;
    assign cur_time = {cur_min10, cur_min1, cur_sec10, cur_sec1};
    assign set_time = {set_min10, set_min1, set_sec10, set_sec1};
    assign value = start_stop ? cur_time : set_time;
    assign buzz_clk = alarm ? clk_div[12] : 0;
        
    clock_set clock(.clk(clk_start), .reset_p(reset_p),  .clk_usec(clk_usec), .clk_msec(clk_msec), 
                                    .clk_sec(clk_sec));
        
    counter_dec_60 set_sec(clk, reset_p, inc_sec, set_sec1, set_sec10);     // 초 증가 
    counter_dec_60 set_min(clk, reset_p, inc_min, set_min1, set_min10);     // 분 증가
        
    loadable_downcounter_dec_60 cur_sec( .clk(clk), .reset_p(reset_p), .clk_time(clk_sec), .load_enable(load_enable), 
                                                             .set_value1(set_sec1), .set_value10(set_sec10), .dec1(cur_sec1), 
                                                                .dec10(cur_sec10), .dec_clk(dec_clk));
                                                                
    loadable_downcounter_dec_60 cur_min( .clk(clk), .reset_p(reset_p), .clk_time(dec_clk), .load_enable(load_enable), 
                                                             .set_value1(set_min1), .set_value10(set_min10), .dec1(cur_min1), 
                                                                .dec10(cur_min10)); //dec_clk은 위에 선언되있기 떄문에 지워줘야함

    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(start_stop), .p_edge(load_enable));
    edge_detector_n ed_timeout(.clk(clk), .reset_p(reset_p), .cp(time_out), .p_edge(timeout_pedge));

    always @(posedge clk) clk_div = clk_div + 1;
                    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            alarm = 0;
        end
        else begin
            if(timeout_pedge) alarm = 1;
            else if(alarm && alarm_off)alarm = 0;
        end
    end  
   
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) start_stop = 0;
        else begin
            if(btn_start)start_stop = ~start_stop;
            else if(timeout_pedge) start_stop = 0;
        end
    end
        
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) time_out = 0;
        else begin
            if(start_stop && clk_msec && cur_time == 0) time_out = 1;
            else time_out = 0;
        end
    end
endmodule