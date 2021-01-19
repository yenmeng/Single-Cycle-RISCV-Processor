module HW4(clk,rst_n,mem_rdata_I,ctrl_signal,immediate);

input              clk, rst_n;
input       [31:0] mem_rdata_I;
output reg  [11:0] ctrl_signal;
output reg  [31:0] immediate;
    
// wire/reg //
wire [22:0]  instruction_type;
wire [4:0]   instruction_format;
	
// Connect to your HW3 module //
HW3 decoder(.clk(clk), 
            .rst_n(rst_n),
            .mem_rdata_I(mem_rdata_I), 
            .instruction_type(instruction_type), 
            .instruction_format(instruction_format));

// Sequential Block //
always@(*) begin
    if(!rst_n) begin
        ctrl_signal = 0;
        immediate = 0;
    end
    else begin 
        ctrl_signal = 0;
        if (instruction_format[4]) begin //R
            immediate = 0;
            ctrl_signal[5] = 1'b1;
            if (instruction_type[8]) begin //add
                ctrl_signal[3:0] = 0; 
            end
            else if (instruction_type[7]) begin //sub
                ctrl_signal[3:0] = 4'b1000; 
            end
            else if (instruction_type[6]) begin //sll
                ctrl_signal[3:0] = 4'b0001; 
            end
            else if (instruction_type[5]) begin //slt
                ctrl_signal[3:0] = 4'b0010; 
            end
            else if (instruction_type[4]) begin //xor
                ctrl_signal[3:0] = 4'b0100; 
            end
            else if (instruction_type[3]) begin //srl
                ctrl_signal[3:0] = 4'b0101; 
            end
            else if (instruction_type[2]) begin //sra
                ctrl_signal[3:0] = 4'b1101; 
            end
            else if (instruction_type[1]) begin //or
                ctrl_signal[3:0] = 4'b0110; 
            end
            else begin //and
                ctrl_signal[3:0] = 4'b0111; 
            end
        end
        else if (instruction_format[3]) begin //I
            immediate = {{20{mem_rdata_I[31]}},mem_rdata_I[31:20]};
            ctrl_signal[4] = 1'b1;
            ctrl_signal[5] = 1'b1;
            if (instruction_type[21]) begin //jalr
                ctrl_signal[10] = 1'b1; 
            end
            else if (instruction_type[18]) begin //ld
                ctrl_signal[8] = 1'b1; 
                ctrl_signal[6] = 1'b1;
                ctrl_signal[3:0] = 0; 
            end
            else if (instruction_type[16]) begin //addi
                ctrl_signal[3:0] = 0;
            end
            else if (instruction_type[15]) begin //slti
                ctrl_signal[3:0] = 4'b0010;
            end
            else if (instruction_type[14]) begin // xori
                ctrl_signal[3:0] = 4'b0100;
            end
            else if (instruction_type[13]) begin // ori
                ctrl_signal[3:0] = 4'b0110;
            end
            else if (instruction_type[12]) begin // andi
                ctrl_signal[3:0] = 4'b0111;
            end
            else if (instruction_type[11]) begin // slli
                ctrl_signal[3:0] = 4'b0001;
            end
            else if (instruction_type[10]) begin // srli
                ctrl_signal[3:0] = 4'b0101;
            end
            else begin // srai
                ctrl_signal[3:0] = 4'b1101;
            end
        end
        else if (instruction_format[2]) begin //S
            immediate = {{20{mem_rdata_I[31]}},mem_rdata_I[31:25],mem_rdata_I[11:7]};
            ctrl_signal[7] = 1'b1;
            ctrl_signal[4] = 1'b1;
            ctrl_signal[3:0] = 0; 
        end
        else if (instruction_format[1]) begin //B
            immediate = {{20{mem_rdata_I[31]}},mem_rdata_I[31],mem_rdata_I[7],mem_rdata_I[30:25],mem_rdata_I[11:8],1'b0};
            ctrl_signal[9] = 1'b1; 
            if (instruction_type[20]) ctrl_signal[3:0] = 4'b1000; //beq
            else if (instruction_type[19]) ctrl_signal[3:0] = 4'b1001; //bne
        end
        else begin //J(jal)
            immediate = {{11{mem_rdata_I[31]}},mem_rdata_I[31],mem_rdata_I[19:12],mem_rdata_I[20],mem_rdata_I[30:21],1'b0};
            ctrl_signal[11] = 1'b1; 
            ctrl_signal[5] = 1'b1; 
        end
    end
end

endmodule