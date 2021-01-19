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
