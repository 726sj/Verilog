`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/19 09:22:43
// Design Name: 
// Module Name: tb_stopwatch
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


module tb_stopwatch();
        reg clk, reset_p;
        reg [2:0] btn_pedge;
        wire [15:0] value;
        
        stop_watch_csec DUT(clk,reset_p, btn_pedge, value);
        
        initial begin           //initial은 초기화 코드블록을 정의하는데 사용된다. 주로 시뮬레이션의 초기화단계에서 실행되는 코드를 지정하는데 사용됨
                clk = 0;
                reset_p = 1;
                btn_pedge = 0;
        end
        
        always #4 clk = ~clk;
        
        initial begin
                #10;                    //10us
                reset_p = 0; #10;
                btn_pedge = 1; #10;
                btn_pedge = 0; #500_000_000;        //500초
                btn_pedge = 2; #10;
                btn_pedge = 0; #500_000_000;
                $stop;
        end
endmodule
