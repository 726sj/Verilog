module LED(
    input clk,
    input reset_p,
    input btn,
    output reg brightness
);

    reg [1:0] state;
    wire btn_pedge;

    button_cntr btn_bright(
        .clk(clk),
        .reset_p(reset_p),
        .btn(btn),
        .btn_pe(btn_pedge)
    );

    reg [6:0] duty_cycle;
    reg [13:0] pwm_freq;
    wire pwm_out;

    pwm_128step_last pwm_led(
        .clk(clk),
        .reset_p(reset_p),
        .duty(duty_cycle),
        .pwm_freq(pwm_freq),
        .pwm_128(pwm_out)
    );

    parameter BRIGHT_OFF    = 2'b00;
    parameter BRIGHT_LOW    = 2'b01;
    parameter BRIGHT_MID    = 2'b10;
    parameter BRIGHT_HIGH   = 2'b11;

always @(posedge clk or posedge reset_p) begin
        if (reset_p) begin
            state <= BRIGHT_OFF;
            duty_cycle <= 7'd0;
            pwm_freq <= 14'd10; // 1kHz (2^10)
        end 
        else if (btn_pedge) begin
            case (state)
                BRIGHT_OFF: begin
                    state <= BRIGHT_LOW;
                    duty_cycle <= 7'd25;
                    pwm_freq <= 14'd10; // 1kHz (2^10)
                end
                BRIGHT_LOW: begin
                    state <= BRIGHT_MID;
                    duty_cycle <= 7'd50;
                    pwm_freq <= 14'd12; // 4kHz (2^12)
                end
                BRIGHT_MID: begin
                    state <= BRIGHT_HIGH;
                    duty_cycle <= 7'd75;
                    pwm_freq <= 14'd13; // 8kHz (2^13)
                end
                BRIGHT_HIGH: begin
                    state <= BRIGHT_OFF;
                    duty_cycle <= 7'd0;
                    pwm_freq <= 14'd10; // 1kHz (2^10)
                end
            endcase
        end
    end

    always @(posedge clk or posedge reset_p) begin
        if (reset_p) begin
            brightness <= 1'b0;
        end
        else begin
            brightness <= pwm_out;
        end
    end
endmodule