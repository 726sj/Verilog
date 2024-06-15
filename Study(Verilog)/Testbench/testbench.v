`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/19 10:58:23
// Design Name: 
// Module Name: testbench
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

module tb_dht11(
    //�ùķ��̼��̱� ������ ������� ����.
    //testbench�� ����Ʈ������
    );
    reg clk, reset_p; //input�� reg
    tri1 dht11_data; /////////////tri�� �Ӿ�
    wire [7:0] humidity, temperature;//output�� wire��
    dht11 DUT(clk, reset_p, dht11_data, humidity, temperature);//design on the test
    reg dout, wr;
    assign dht11_data = wr ? dout : 1'bz;
    parameter [7:0] humi_value=8'd80;
    parameter [7:0] tmpr_value = 8'd25;
    parameter [7:0] check_sum = humi_value + tmpr_value;
    parameter [39:0] data ={humi_value, 8'b0, tmpr_value, {8{1'b0}}/*�ݺ� ������*/, check_sum};
    initial begin //reg�ʱ�ȭ, testbench������ ���
        clk =0;
        reset_p =1;
        wr = 0;
    end
    always #5/*#�� ������*/ clk = ~clk;
    integer i;
    initial begin
        #10;
        reset_p =0;
        wait(!dht11_data); //=while, dht11_data�� 0�� ������ ����ض�
        wait(dht11_data);
        #20_000;
        dout = 0; wr=1; #80_000;
        wr =0; #80_000;
        wr=1;
        for (i=0; i<40; i=i+1) begin
            dout =0; #50_000;
            dout =1;
            if(data[39-i]) #70_000;
            else         #27_000;
        end
        dout =0; wr =1; #10;
        wr=0; #10_000;
        $stop; //testbench ����� = �ùķ��̼� ����
    end
endmodule
