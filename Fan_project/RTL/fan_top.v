module fan_top(
    input clk, reset_p,
    input [3:0] btn,
    input echo_data,  //초음파echo
    output trig_data, //초음파trigger
    output [3:0] com_sr04, //초음파fnd
    output [7:0] seg_7_sr04, //초음파fnd
    output [3:0] led_bar_sr04, //초음파센서의 현재상태
    output motor_pwm,
    output led_brightness,
    output [3:0] com,
    output [7:0] seg_7,
    output led0_b,
    output s_motor_pwm,
    output [2:0] led_power_ctn,
    output [2:0] led_time_ctn);

    wire [3:0] btn_pedge;
    wire [11:0] distance;
    wire [15:0] value;
    wire [15:0] bcd_dis;
    wire timer_end;
    wire motor_idle;
    wire motor_off_ultrasonic;

    assign value = bcd_dis;

    // 버튼 입력 검출
    button_cntr btn0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
    button_cntr btn1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
    button_cntr btn2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));
    button_cntr btn3(.clk(clk), .reset_p(reset_p), .btn(btn[3]), .btn_pe(btn_pedge[3]));

    //seg_7
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_an(seg_7_sr04), .com(com_sr04));
    bin_to_dec dec(.bin({1'b0,distance}), .bcd(bcd_dis));

    // 바람 세기 제어 모듈
    Power wind_control(
        .clk(clk),
        .reset_p(reset_p),
        .btn(btn[0]),
        .timer_end(timer_end),
        .motor_off_ultrasonic(motor_off_ultrasonic),
        .motor_pwm(motor_pwm),
        .led_power(led_power_ctn),
        .motor_idle(motor_idle)
    );

    // 선풍기 조명 제어 모듈
    LED  led_control(
        .clk(clk),
        .reset_p(reset_p),
        .btn(btn[1]),
        .brightness(led_brightness)
    );
    
    // 시간 예약 제어 모듈
    Reservation timer_control(
        .clk(clk),
        .reset_p(reset_p),
        .motor_idle(motor_idle),
        .btn(btn[2]),
        .com(com),
        .seg_7(seg_7),
        .led0_b(led0_b),
        .led(led_time_ctn),
        .timer_end(timer_end)
    );

    //선풍기 회전/고정
    Rotation rotation(
    .clk(clk),
    .reset_p(reset_p),
    .btn(btn[3]),
    .motor_pwm(motor_pwm),
    .motor_idle(motor_idle),
    .timer_end(timer_end),
    .s_motor_pwm(s_motor_pwm)
    );

    //초음파 모듈
    Ultrasensor ultrasensor(
    .clk(clk), 
    .reset_p(reset_p), 
    .echo(echo_data), 
    .trigger(trig_data), 
    .distance(distance), 
    .led_bar(led_bar_sr04), 
    .motor_off_ultrasonic(motor_off_ultrasonic)
    );
    
endmodule