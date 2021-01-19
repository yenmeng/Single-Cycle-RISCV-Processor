// Your code
module RISCV(clk,rst_n,mem_wen_D,mem_addr_D,mem_wdata_D,mem_rdata_D,mem_addr_I,mem_rdata_I);

input               clk,rst_n;
//mem I
input       [31:0]  mem_rdata_I;
output  reg [31:2]  mem_addr_I; //PC
//mem D
input       [63:0]  mem_rdata_D; //mem read
output  reg [31:2]  mem_addr_D; //mem address
output  reg         mem_wen_D; //MemWrite
output  reg [63:0]  mem_wdata_D; //mem write

//--reg--//
//PC//
reg     [31:2]  n_mem_addr_I;
//control//
wire    [11:0]  ctrl_signal;
//immediate//
wire    [31:0]  immediate;
reg     [63:0]  data1;
reg     [63:0]  data2;
//ALU//
wire    [63:0]  rs1;
wire    [63:0]  rs2;
wire            zero;
wire    [63:0]  ALUresult;
//regiter write//
reg    [63:0]   writeback_data;
reg    [31:0]   reverse;

integer i;

HW4 control(.clk(clk),
            .rst_n(rst_n),
            .mem_rdata_I(reverse),
            .ctrl_signal(ctrl_signal),
            .immediate(immediate));

ALU ALU(.data1(data1),
        .data2(data2),
        .ALUOp(ctrl_signal[3:0]),
        .zero(zero),
        .result(ALUresult));

REGFILE regfile(.clk(clk),
                .rst_n(rst_n),
                .regr1(reverse[19:15]),
                .regr2(reverse[24:20]),
                .regw(reverse[11:7]),
                .wdata(writeback_data),
                .rdata1(rs1),
                .rdata2(rs2),
                .RegWrite(ctrl_signal[5]));  

//Combinational Blocks:PC (mem_addr_I)
always@(*) begin
    if (!rst_n) begin
        n_mem_addr_I = 0;
        reverse = 0;
        data1 = 0;
        data2 = 0;
        mem_wdata_D = 0;
        mem_wen_D = 0;
        writeback_data = 0;
        mem_addr_D = -1;
    end
    else begin 
        reverse[7:0] = mem_rdata_I[31:24];
        reverse[15:8] = mem_rdata_I[23:16];
        reverse[23:16] = mem_rdata_I[15:8];
        reverse[31:24] = mem_rdata_I[7:0];
        //PC//
        if (ctrl_signal[10]==1) n_mem_addr_I = immediate[31:2] + rs1;//jal
        else begin
            if ((zero == 1 && ctrl_signal[9]==1) || ctrl_signal[11]==1) n_mem_addr_I = mem_addr_I + immediate[31:2];
            else n_mem_addr_I = mem_addr_I + 1;
        end
        //ALU//
        data1 = rs1;
        data2 = (ctrl_signal[4] == 1)? immediate : rs2;
        //mem//
        mem_wdata_D[7:0] = rs2[63:56];
        mem_wdata_D[15:8] = rs2[55:48];
        mem_wdata_D[23:16] = rs2[47:40];
        mem_wdata_D[31:24] = rs2[39:32];
        mem_wdata_D[39:32] = rs2[31:24];
        mem_wdata_D[47:40] = rs2[23:16];
        mem_wdata_D[55:48] = rs2[15:8];
        mem_wdata_D[63:56] = rs2[7:0];
        mem_wen_D = ctrl_signal[7];
        if (ctrl_signal[11] == 1 || ctrl_signal[10] == 1) writeback_data = mem_addr_I + 1;
        else begin
            if (ctrl_signal[6] == 1) begin
                writeback_data[7:0] = mem_rdata_D[63:56];
                writeback_data[15:8] = mem_rdata_D[55:48];
                writeback_data[23:16] = mem_rdata_D[47:40];
                writeback_data[31:24] = mem_rdata_D[39:32];
                writeback_data[39:32] = mem_rdata_D[31:24];
                writeback_data[47:40] = mem_rdata_D[23:16];
                writeback_data[55:48] = mem_rdata_D[15:8];
                writeback_data[63:56] = mem_rdata_D[7:0];
            end 
            else writeback_data = ALUresult;
        end
        mem_addr_D = ALUresult[31:2];
    end
end

//Sequential Block//
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        mem_addr_I <= 0;
    end 
    else begin
        mem_addr_I <= n_mem_addr_I;
    end
end



endmodule

module ALU(data1,data2,ALUOp,zero,result);

input     [63:0]  data1;
input     [63:0]  data2;
input       [3:0]   ALUOp;
output  reg         zero;
output  reg [63:0]  result;

always@(*) begin
    case(ALUOp)
        4'b0000:begin
            result = data1 + data2;//add
            zero = 0;
        end
        4'b1000:begin//sub
            result = data1 - data2;
            zero = (!result)?1:0;
        end 
        4'b0001:begin
            result = data1 << data2;//sll
            zero = 0;
        end 
        4'b0010:begin
            result = (data1 < data2)?1:0;//slt
            zero = 0;
        end 
        4'b0100:begin
            result = data1 ^ data2;//xor
            zero = 0;
        end 
        4'b0101:begin
            result = data1 >> data2;//srl
            zero = 0;
        end 
        4'b1101:begin
            result = data1 >>> data2;//sra
            zero = 0;
        end 
        4'b0110:begin
            result = data1 | data2;//or
            zero = 0;
        end 
        4'b0111:begin
            result = data1 & data2;//and
            zero = 0;
        end 
        4'b1001:begin//bne
            result = data1 - data2;
            zero = (!result)?0:1;
        end 
        default:begin
            result = 0;
            zero = 0;
        end
    endcase
end

endmodule

module REGFILE(clk,rst_n,regr1,regr2,regw,wdata,rdata1,rdata2,RegWrite);
    input clk, rst_n;
    input [4:0] regr1,regr2,regw;
    output [63:0] rdata1, rdata2;
    input [63:0] wdata;
    input RegWrite;

    integer i;
    reg [63:0] registers [0:31];
    reg [63:0] rdata1, rdata2;

    always@(*) begin
        if (!rst_n) begin
            rdata1 = 0;
            rdata2 = 0;
        end
        else  begin
            rdata1 = registers[regr1];
            rdata2 = registers[regr2];
        end
    end

    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i=0; i<32; i=i+1)
                registers[i] <= 'h0;
        end
        else begin
            if(RegWrite) begin
                if (regw != 0) registers[regw] <= wdata;
            end
        end
    end
    
endmodule

module HW3(clk,
            rst_n,
            // for mem_I
            mem_addr_I,
            mem_rdata_I,
			// for result output
			instruction_type,
			instruction_format,
			);

    input         clk, rst_n        	;
    output [31:2] mem_addr_I     		;
    input  [31:0] mem_rdata_I       	;
	output reg [22:0] instruction_type  ;
	output reg [ 4:0] instruction_format;

//combinatial part
always @(*) begin
	instruction_format = 'b0;
	instruction_type = 'b0;
	if (!rst_n) begin
		instruction_format = 'b0;
		instruction_type = 'b0;
	end
	else begin
		case(mem_rdata_I[6:0])
			// R type
			7'b0110011: begin
                instruction_format = 5'b10000;
                case(mem_rdata_I[14:12])
                    3'b000:
                        case(mem_rdata_I[31:25])
                            7'b0000000: instruction_type = {14'b0,1'b1,8'b0}; //ADD (15)
                            7'b0100000: instruction_type = {15'b0,1'b1,7'b0}; //SUB (16)
                            default: instruction_type = 'b0;
                        endcase
                    3'b001: instruction_type = {16'b0,1'b1,6'b0}; //SLL (17)
                    3'b010: instruction_type = {17'b0,1'b1,5'b0}; //SLT (18)
                    3'b100: instruction_type = {18'b0,1'b1,4'b0}; //XOR (19)
                    3'b101:
                        case(mem_rdata_I[31:25])
                            7'b0000000: instruction_type = {19'b0,1'b1,3'b0}; //XOR (20)
                            7'b0100000: instruction_type = {20'b0,1'b1,2'b0}; //SRL (21)
                            default: instruction_type = 'b0;
                        endcase
                    3'b110: instruction_type = {21'b0,1'b1,1'b0}; //OR (22)
                    3'b111: instruction_type = {22'b0,1'b1}; //AND (23)
                    default: instruction_type = 'b0;
				endcase
      		end
        	// S type
			7'b0100011: begin
        		instruction_format = 5'b00100;
            	instruction_type = {5'b0,1'b1,17'b0}; //sd (6)
			end
        	// B type
			7'b1100011: begin
            	instruction_format = 5'b00010;
            	case(mem_rdata_I[14:12])
            		3'b000:	instruction_type = {2'b0,1'b1,20'b0}; //BEQ (3)
           			3'b001:	instruction_type = {3'b0,1'b1,19'b0}; //BNE (4)
            	endcase
			end
      		// J type
			7'b1101111: begin
            	instruction_format = 5'b00001;
            	instruction_type = {1'b1,22'b0}; //jal (1)
			end
     		// I type
     		//(mem_rdata_I[6:0]==7'b0000011 || mem_rdata_I[6:0]==7'b0010011 || mem_rdata_I[6:0]==7'b1100111)
			default: begin
				instruction_format = 5'b01000;
        		//mem_rdata_I[31:25] = mem_rdata_I[31:25];
				case(mem_rdata_I[6:0])
					7'b1100111: instruction_type = {1'b0,1'b1,21'b0}; // JALR (2)
					7'b0000011: instruction_type = {4'b0,1'b1,18'b0}; // LD (5)
				default:
					case(mem_rdata_I[14:12])
						3'b000: instruction_type = {6'b0,1'b1,16'b0}; //ADDI (7)
						3'b001: instruction_type = {11'b0,1'b1,11'b0}; //SLLI (12)
						3'b010: instruction_type = {7'b0,1'b1,15'b0}; //SLTI (8)
						3'b100: instruction_type = {8'b0,1'b1,14'b0}; //XORI (9)
						3'b101:
							case(mem_rdata_I[31:25])
								7'b0000000: instruction_type = {12'b0,1'b1,10'b0}; //SRLI (13)
								7'b0100000: instruction_type = {13'b0,1'b1,9'b0}; //SRAI (14)
								default: instruction_type = 'b0;
							endcase
		  				3'b110: instruction_type = {9'b0,1'b1,13'b0}; //ORI (10)
						3'b111: instruction_type = {10'b0,1'b1,12'b0}; //ANDI (11)
						default: instruction_type = 'b0;
					endcase
				endcase
			end
		endcase
	end
end

endmodule

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
				immediate = {{27{mem_rdata_I[24]}},mem_rdata_I[24:20]};
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
