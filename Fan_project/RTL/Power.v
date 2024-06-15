module Power(
        input clk, reset_p,
        input btn,
        input timer_end,
        input motor_off_ultrasonic,
        output motor_pwm,
        output reg [2:0] led_power,
        output reg motor_idle
);
        parameter IDLE = 2'b00;
        parameter POWER_LOW = 2'b01;
        parameter POWER_MID = 2'b10;
        parameter POWER_HIGH = 2'b11;
    
        reg [6:0] duty; //0~127 
        reg [1:0] state; //현재상태 
        
        wire [2:0] btn_pedge;
        
        button_cntr btn0(.clk(clk), .reset_p(reset_p), .btn(btn), .btn_pe(btn_pedge[0]));
    
        pwm_100pc_project pwm_moter1(.clk(clk), .reset_p(reset_p), .duty(duty), .pwm_freq(50), .pwm_100pc(motor_pwm));
    
        always @(posedge clk or posedge reset_p) begin
            if (reset_p) begin
                state <= IDLE;
                duty <= 0;
                led_power <= 3'b000;
                motor_idle <= 0;
            end
            else if (timer_end||motor_off_ultrasonic) begin
                state <= IDLE;
                duty <= 0;
                led_power <= 3'b000;
            end 
            else begin
                case(state)
                    IDLE: begin // 0
                        if (btn_pedge) begin
                            state = POWER_LOW; //  duty=10
                            duty = 10;
                            led_power = 3'b001; // led_power[1]
                            motor_idle<=0;
                        end
                    end
                    POWER_LOW: begin //  10
                        if (btn_pedge) begin
                            state = POWER_MID; // duty=20
                            duty = 20;         //10%
                            led_power = 3'b010; // led_power[2]
                        end
                    end
                    POWER_MID: begin //  20
                        if (btn_pedge) begin
                            state = POWER_HIGH; //  duty=30
                            duty = 30;          //20% 
                            led_power = 3'b100; // led_power[3]
                        end
                    end
                    POWER_HIGH: begin //  30
                        if (btn_pedge) begin
                            state = IDLE; //  0
                            duty = 0;           //30%
                            led_power = 3'b000; // led_power[0]
                            motor_idle<=1;
                        end
                    end
                    default: state = IDLE; // default 
                endcase
            end
        end
    endmodule