----------------------------------------------------------------------------------
--Copyright 2020 Ricardo F Tafas Jr

--Licensed under the Apache License, Version 2.0 (the "License"); you may not
--use this file except in compliance with the License. You may obtain a copy of
--the License at

--   http://www.apache.org/licenses/LICENSE-2.0

--Unless required by applicable law or agreed to in writing, software distributed
--under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
--OR CONDITIONS OF ANY KIND, either express or implied. See the License for
--the specific language governing permissions and limitations under the License.
----------------------------------------------------------------------------------
library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;
	use IEEE.math_real.all;

package prbs_pkg is

	constant MAX_PRBS : integer := 168;

	type prbs_t is protected
		impure function get_data ( input : positive ) return std_logic_vector;
		impure function check_data ( input : std_logic_vector ) return boolean;
		impure function reset return boolean;
	end protected prbs_t;

	procedure prbs_shift ( prbs_sr : inout std_logic_vector; poly : positive; result : out std_logic_vector);

end prbs_pkg;

package body prbs_pkg is

	type prbs_t is protected body
		variable prbs_sr : std_logic_vector(MAX_PRBS downto 0) := (others=>'1');
		variable check_prbs_sr : std_logic_vector(MAX_PRBS downto 0) := (others=>'1');
		variable seed    : std_logic_vector(MAX_PRBS downto 0) := (others=>'1');
		variable poly    : integer range 2 to MAX_PRBS         := 23;

		impure function get_data ( input : positive ) return std_logic_vector is
			variable result_tmp : std_logic_vector(input-1 downto 0);
		begin
			prbs_shift(prbs_sr,poly,result_tmp);
			return result_tmp;
		end function;

		impure function check_data ( input : std_logic_vector ) return boolean is
			variable result_tmp : std_logic_vector(input'range);
		begin
			prbs_shift(check_prbs_sr,poly,result_tmp);
			if result_tmp = input then
				return true;
			end if;
			return false;
		end function;

		impure function reset return boolean is
		begin
			prbs_sr 			:= seed;
			check_prbs_sr := seed;
			return true;
		end function;

	end protected body prbs_t;

	procedure prbs_shift ( prbs_sr : inout std_logic_vector; poly : positive; result : out std_logic_vector) is
	begin
		for j in result'reverse_range loop
			case poly is
				when 3 =>     --3
					prbs_sr(0) := prbs_sr(2) xor prbs_sr(1);
				when 4 =>		  --4
					prbs_sr(0) := prbs_sr(3) xor prbs_sr(2);
				when 5 =>		  --5
					prbs_sr(0) := prbs_sr(4) xor prbs_sr(2);
				when 6 =>		  --6
					prbs_sr(0) := prbs_sr(5) xor prbs_sr(4);
				when 7 =>		  --7
					prbs_sr(0) := prbs_sr(6) xor prbs_sr(5);
				when 8 =>		  --8
					prbs_sr(0) := prbs_sr(7) xor prbs_sr(5) xor prbs_sr(4) xor prbs_sr(3);
				when 9 =>		  --9
					prbs_sr(0) := prbs_sr(8) xor prbs_sr(4);
				when 10 =>		  --10
					prbs_sr(0) := prbs_sr(9) xor prbs_sr(6);
				when 11 =>		  --11
					prbs_sr(0) := prbs_sr(10) xor prbs_sr(8);
				when 12 =>		  --12
					prbs_sr(0) := prbs_sr(11) xor prbs_sr(5) xor prbs_sr(3) xor prbs_sr(0);
				when 13 =>		  --13
					prbs_sr(0) := prbs_sr(12) xor prbs_sr(3) xor prbs_sr(2) xor prbs_sr(0);
				when 14 =>		  --14
					prbs_sr(0) := prbs_sr(13) xor prbs_sr(4) xor prbs_sr(2) xor prbs_sr(0);
				when 15 =>		  --15
					prbs_sr(0) := prbs_sr(14) xor prbs_sr(13);
				when 16 =>		  --16
					prbs_sr(0) := prbs_sr(15) xor prbs_sr(14) xor prbs_sr(12) xor prbs_sr(3);
				when 17 =>		  --17
					prbs_sr(0) := prbs_sr(16) xor prbs_sr(13);
				when 18 =>		  --18
					prbs_sr(0) := prbs_sr(17) xor prbs_sr(10);
				when 19 =>		  --19
					prbs_sr(0) := prbs_sr(18) xor prbs_sr(5) xor prbs_sr(1) xor prbs_sr(0);
				when 20 =>		  --20
					prbs_sr(0) := prbs_sr(19) xor prbs_sr(16);
				when 21 =>		  --21
					prbs_sr(0) := prbs_sr(20) xor prbs_sr(18);
				when 22 =>		  --22
					prbs_sr(0) := prbs_sr(21) xor prbs_sr(20);
				when 23 =>		  --23
					prbs_sr(0) := prbs_sr(22) xor prbs_sr(17);
				when 24 =>		  --24
					prbs_sr(0) := prbs_sr(23) xor prbs_sr(22) xor prbs_sr(21) xor prbs_sr(16);
				when 25 =>		  --25
					prbs_sr(0) := prbs_sr(24) xor prbs_sr(21);
				when 26 =>		  --26
					prbs_sr(0) := prbs_sr(25) xor prbs_sr(5) xor prbs_sr(1) xor prbs_sr(0);
				when 27 =>		  --27
					prbs_sr(0) := prbs_sr(26) xor prbs_sr(4) xor prbs_sr(1) xor prbs_sr(0);
				when 28 =>		  --28
					prbs_sr(0) := prbs_sr(27) xor prbs_sr(24);
				when 29 =>		  --29
					prbs_sr(0) := prbs_sr(28) xor prbs_sr(26);
				when 30 =>		  --30
					prbs_sr(0) := prbs_sr(29) xor prbs_sr(5) xor prbs_sr(3) xor prbs_sr(0);
				when 31 =>		  --31
					prbs_sr(0) := prbs_sr(30) xor prbs_sr(27);
				when 32 =>		  --32
					prbs_sr(0) := prbs_sr(31) xor prbs_sr(21) xor prbs_sr(1) xor prbs_sr(0);
				when 33 =>		  --33
					prbs_sr(0) := prbs_sr(32) xor prbs_sr(19);
				when 34 =>		  --34
					prbs_sr(0) := prbs_sr(33) xor prbs_sr(26) xor prbs_sr(1) xor prbs_sr(0);
				when 35 =>		  --35
					prbs_sr(0) := prbs_sr(34) xor prbs_sr(32);
				when 36 =>		  --36
					prbs_sr(0) := prbs_sr(35) xor prbs_sr(24);
				when 37 =>		  --37
					prbs_sr(0) := prbs_sr(36) xor prbs_sr(4) xor prbs_sr(3) xor prbs_sr(2) xor prbs_sr(1) xor prbs_sr(0);
				when 38 =>		  --38
					prbs_sr(0) := prbs_sr(37) xor prbs_sr(5) xor prbs_sr(4) xor prbs_sr(0);
				when 39 =>		  --39
					prbs_sr(0) := prbs_sr(38) xor prbs_sr(34);
				when 40 =>		  --40
					prbs_sr(0) := prbs_sr(39) xor prbs_sr(37) xor prbs_sr(20) xor prbs_sr(18);
				when 41 =>		  --41
					prbs_sr(0) := prbs_sr(40) xor prbs_sr(37);
				when 42 =>		  --42
					prbs_sr(0) := prbs_sr(41) xor prbs_sr(40) xor prbs_sr(19) xor prbs_sr(18);
				when 43 =>		  --43
					prbs_sr(0) := prbs_sr(42) xor prbs_sr(41) xor prbs_sr(37) xor prbs_sr(36);
				when 44 =>		  --44
					prbs_sr(0) := prbs_sr(43) xor prbs_sr(42) xor prbs_sr(17) xor prbs_sr(16);
				when 45 =>		  --45
					prbs_sr(0) := prbs_sr(44) xor prbs_sr(43) xor prbs_sr(41) xor prbs_sr(40);
				when 46 =>		  --46
					prbs_sr(0) := prbs_sr(45) xor prbs_sr(44) xor prbs_sr(25) xor prbs_sr(24);
				when 47 =>		  --47
					prbs_sr(0) := prbs_sr(46) xor prbs_sr(41);
				when 48 =>		  --48
					prbs_sr(0) := prbs_sr(47) xor prbs_sr(46) xor prbs_sr(20) xor prbs_sr(19);
				when 49 =>		  --49
					prbs_sr(0) := prbs_sr(48) xor prbs_sr(39);
				when 50 =>		  --50
					prbs_sr(0) := prbs_sr(49) xor prbs_sr(48) xor prbs_sr(23) xor prbs_sr(22);
				when 51 =>		  --51
					prbs_sr(0) := prbs_sr(50) xor prbs_sr(49) xor prbs_sr(35) xor prbs_sr(34);
				when 52 =>		  --52
					prbs_sr(0) := prbs_sr(51) xor prbs_sr(48);
				when 53 =>		  --53
					prbs_sr(0) := prbs_sr(52) xor prbs_sr(51) xor prbs_sr(37) xor prbs_sr(36);
				when 54 =>		  --54
					prbs_sr(0) := prbs_sr(53) xor prbs_sr(52) xor prbs_sr(17) xor prbs_sr(16);
				when 55 =>		  --55
					prbs_sr(0) := prbs_sr(54) xor prbs_sr(30);
				when 56 =>		  --56
					prbs_sr(0) := prbs_sr(55) xor prbs_sr(54) xor prbs_sr(34) xor prbs_sr(33);
				when 57 =>		  --57
					prbs_sr(0) := prbs_sr(56) xor prbs_sr(49);
				when 58 =>		  --58
					prbs_sr(0) := prbs_sr(57) xor prbs_sr(38);
				when 59 =>		  --59
					prbs_sr(0) := prbs_sr(58) xor prbs_sr(57) xor prbs_sr(37) xor prbs_sr(36);
				when 60 =>		  --60
					prbs_sr(0) := prbs_sr(59) xor prbs_sr(58);
				when 61 =>		  --61
					prbs_sr(0) := prbs_sr(60) xor prbs_sr(59) xor prbs_sr(45) xor prbs_sr(44);
				when 62 =>		  --62
					prbs_sr(0) := prbs_sr(61) xor prbs_sr(60) xor prbs_sr(5) xor prbs_sr(4);
				when 63 =>		  --63
					prbs_sr(0) := prbs_sr(62) xor prbs_sr(61);
				when 64 =>		  --64
					prbs_sr(0) := prbs_sr(63) xor prbs_sr(62) xor prbs_sr(60) xor prbs_sr(59);
				when 65 =>		  --65
					prbs_sr(0) := prbs_sr(64) xor prbs_sr(46);
				when 66 =>		  --66
					prbs_sr(0) := prbs_sr(65) xor prbs_sr(64) xor prbs_sr(56) xor prbs_sr(55);
				when 67 =>		  --67
					prbs_sr(0) := prbs_sr(66) xor prbs_sr(65) xor prbs_sr(57) xor prbs_sr(56);
				when 68 =>		  --68
					prbs_sr(0) := prbs_sr(67) xor prbs_sr(58);
				when 69 =>		  --69
					prbs_sr(0) := prbs_sr(68) xor prbs_sr(66) xor prbs_sr(41) xor prbs_sr(39);
				when 70 =>		  --70
					prbs_sr(0) := prbs_sr(69) xor prbs_sr(68) xor prbs_sr(54) xor prbs_sr(53);
				when 71 =>		  --71
					prbs_sr(0) := prbs_sr(70) xor prbs_sr(64);
				when 72 =>		  --72
					prbs_sr(0) := prbs_sr(71) xor prbs_sr(65) xor prbs_sr(24) xor prbs_sr(18);
				when 73 =>		  --73
					prbs_sr(0) := prbs_sr(72) xor prbs_sr(47);
				when 74 =>		  --74
					prbs_sr(0) := prbs_sr(73) xor prbs_sr(72) xor prbs_sr(58) xor prbs_sr(57);
				when 75 =>		  --75
					prbs_sr(0) := prbs_sr(74) xor prbs_sr(73) xor prbs_sr(64) xor prbs_sr(63);
				when 76 =>		  --76
					prbs_sr(0) := prbs_sr(75) xor prbs_sr(74) xor prbs_sr(40) xor prbs_sr(39);
				when 77 =>		  --77
					prbs_sr(0) := prbs_sr(76) xor prbs_sr(75) xor prbs_sr(46) xor prbs_sr(45);
				when 78 =>		  --78
					prbs_sr(0) := prbs_sr(77) xor prbs_sr(76) xor prbs_sr(58) xor prbs_sr(57);
				when 79 =>		  --79
					prbs_sr(0) := prbs_sr(78) xor prbs_sr(69);
				when 80 =>		  --80
					prbs_sr(0) := prbs_sr(79) xor prbs_sr(78) xor prbs_sr(42) xor prbs_sr(41);
				when 81 =>		  --81
					prbs_sr(0) := prbs_sr(80) xor prbs_sr(76);
				when 82 =>		  --82
					prbs_sr(0) := prbs_sr(81) xor prbs_sr(78) xor prbs_sr(46) xor prbs_sr(43);
				when 83 =>		  --83
					prbs_sr(0) := prbs_sr(82) xor prbs_sr(81) xor prbs_sr(37) xor prbs_sr(36);
				when 84 =>		  --84
					prbs_sr(0) := prbs_sr(83) xor prbs_sr(70);
				when 85 =>		  --85
					prbs_sr(0) := prbs_sr(84) xor prbs_sr(83) xor prbs_sr(57) xor prbs_sr(56);
				when 86 =>		  --86
					prbs_sr(0) := prbs_sr(85) xor prbs_sr(84) xor prbs_sr(73) xor prbs_sr(72);
				when 87 =>		  --87
					prbs_sr(0) := prbs_sr(86) xor prbs_sr(73);
				when 88 =>		  --88
					prbs_sr(0) := prbs_sr(87) xor prbs_sr(86) xor prbs_sr(16) xor prbs_sr(15);
				when 89 =>		  --89
					prbs_sr(0) := prbs_sr(88) xor prbs_sr(50);
				when 90 =>		  --90
					prbs_sr(0) := prbs_sr(89) xor prbs_sr(88) xor prbs_sr(71) xor prbs_sr(70);
				when 91 =>		  --91
					prbs_sr(0) := prbs_sr(90) xor prbs_sr(89) xor prbs_sr(7) xor prbs_sr(6);
				when 92 =>		  --92
					prbs_sr(0) := prbs_sr(91) xor prbs_sr(90) xor prbs_sr(79) xor prbs_sr(78);
				when 93 =>		  --93
					prbs_sr(0) := prbs_sr(92) xor prbs_sr(90);
				when 94 =>		  --94
					prbs_sr(0) := prbs_sr(93) xor prbs_sr(72);
				when 95 =>		  --95
					prbs_sr(0) := prbs_sr(94) xor prbs_sr(83);
				when 96 =>		  --96
					prbs_sr(0) := prbs_sr(95) xor prbs_sr(93) xor prbs_sr(48) xor prbs_sr(46);
				when 97 =>		  --97
					prbs_sr(0) := prbs_sr(96) xor prbs_sr(90);
				when 98 =>		  --98
					prbs_sr(0) := prbs_sr(97) xor prbs_sr(86);
				when 99 =>		  --99
					prbs_sr(0) := prbs_sr(98) xor prbs_sr(96) xor prbs_sr(53) xor prbs_sr(51);
				when 100 =>		  --100
					prbs_sr(0) := prbs_sr(99) xor prbs_sr(62);
				when 101 =>		  --101
					prbs_sr(0) := prbs_sr(100) xor prbs_sr(99) xor prbs_sr(94) xor prbs_sr(93);
				when 102 =>		  --102
					prbs_sr(0) := prbs_sr(101) xor prbs_sr(100) xor prbs_sr(35) xor prbs_sr(34);
				when 103 =>		  --103
					prbs_sr(0) := prbs_sr(102) xor prbs_sr(93);
				when 104 =>		  --104
					prbs_sr(0) := prbs_sr(103) xor prbs_sr(102) xor prbs_sr(93) xor prbs_sr(92);
				when 105 =>		  --105
					prbs_sr(0) := prbs_sr(104) xor prbs_sr(88);
				when 106 =>		  --106
					prbs_sr(0) := prbs_sr(105) xor prbs_sr(90);
				when 107 =>		  --107
					prbs_sr(0) := prbs_sr(106) xor prbs_sr(104) xor prbs_sr(43) xor prbs_sr(41);
				when 108 =>		  --108
					prbs_sr(0) := prbs_sr(107) xor prbs_sr(76);
				when 109 =>		  --109
					prbs_sr(0) := prbs_sr(108) xor prbs_sr(107) xor prbs_sr(102) xor prbs_sr(101);
				when 110 =>		  --110
					prbs_sr(0) := prbs_sr(109) xor prbs_sr(108) xor prbs_sr(97) xor prbs_sr(96);
				when 111 =>		  --111
					prbs_sr(0) := prbs_sr(110) xor prbs_sr(100);
				when 112 =>		  --112
					prbs_sr(0) := prbs_sr(111) xor prbs_sr(109) xor prbs_sr(68) xor prbs_sr(66);
				when 113 =>		  --113
					prbs_sr(0) := prbs_sr(112) xor prbs_sr(103);
				when 114 =>		  --114
					prbs_sr(0) := prbs_sr(113) xor prbs_sr(112) xor prbs_sr(32) xor prbs_sr(31);
				when 115 =>		  --115
					prbs_sr(0) := prbs_sr(114) xor prbs_sr(113) xor prbs_sr(100) xor prbs_sr(99);
				when 116 =>		  --116
					prbs_sr(0) := prbs_sr(115) xor prbs_sr(114) xor prbs_sr(45) xor prbs_sr(44);
				when 117 =>		  --117
					prbs_sr(0) := prbs_sr(116) xor prbs_sr(114) xor prbs_sr(98) xor prbs_sr(96);
				when 118 =>		  --118
					prbs_sr(0) := prbs_sr(117) xor prbs_sr(84);
				when 119 =>		  --119
					prbs_sr(0) := prbs_sr(118) xor prbs_sr(110);
				when 120 =>		  --120
					prbs_sr(0) := prbs_sr(119) xor prbs_sr(112) xor prbs_sr(8) xor prbs_sr(1);
				when 121 =>		  --121
					prbs_sr(0) := prbs_sr(120) xor prbs_sr(102);
				when 122 =>		  --122
					prbs_sr(0) := prbs_sr(121) xor prbs_sr(120) xor prbs_sr(62) xor prbs_sr(61);
				when 123 =>		  --123
					prbs_sr(0) := prbs_sr(122) xor prbs_sr(120);
				when 124 =>		  --124
					prbs_sr(0) := prbs_sr(123) xor prbs_sr(86);
				when 125 =>		  --125
					prbs_sr(0) := prbs_sr(124) xor prbs_sr(123) xor prbs_sr(17) xor prbs_sr(16);
				when 126 =>		  --126
					prbs_sr(0) := prbs_sr(125) xor prbs_sr(124) xor prbs_sr(89) xor prbs_sr(88);
				when 127 =>		  --127
					prbs_sr(0) := prbs_sr(126) xor prbs_sr(125);
				when 128 =>		  --128
					prbs_sr(0) := prbs_sr(127) xor prbs_sr(125) xor prbs_sr(100) xor prbs_sr(98);
				when 129 =>		  --129
					prbs_sr(0) := prbs_sr(128) xor prbs_sr(123);
				when 130 =>		  --130
					prbs_sr(0) := prbs_sr(129) xor prbs_sr(126);
				when 131 =>		  --131
					prbs_sr(0) := prbs_sr(130) xor prbs_sr(129) xor prbs_sr(83) xor prbs_sr(82);
				when 132 =>		  --132
					prbs_sr(0) := prbs_sr(131) xor prbs_sr(102);
				when 133 =>		  --133
					prbs_sr(0) := prbs_sr(132) xor prbs_sr(131) xor prbs_sr(81) xor prbs_sr(80);
				when 134 =>		  --134
					prbs_sr(0) := prbs_sr(133) xor prbs_sr(76);
				when 135 =>		  --135
					prbs_sr(0) := prbs_sr(134) xor prbs_sr(123);
				when 136 =>		  --136
					prbs_sr(0) := prbs_sr(135) xor prbs_sr(134) xor prbs_sr(10) xor prbs_sr(9);
				when 137 =>		  --137
					prbs_sr(0) := prbs_sr(136) xor prbs_sr(115);
				when 138 =>		  --138
					prbs_sr(0) := prbs_sr(137) xor prbs_sr(136) xor prbs_sr(130) xor prbs_sr(129);
				when 139 =>		  --139
					prbs_sr(0) := prbs_sr(138) xor prbs_sr(135) xor prbs_sr(133) xor prbs_sr(130);
				when 140 =>		  --140
					prbs_sr(0) := prbs_sr(139) xor prbs_sr(110);
				when 141 =>		  --141
					prbs_sr(0) := prbs_sr(140) xor prbs_sr(139) xor prbs_sr(109) xor prbs_sr(108);
				when 142 =>		  --142
					prbs_sr(0) := prbs_sr(141) xor prbs_sr(120);
				when 143 =>		  --143
					prbs_sr(0) := prbs_sr(142) xor prbs_sr(141) xor prbs_sr(122) xor prbs_sr(121);
				when 144 =>		  --144
					prbs_sr(0) := prbs_sr(143) xor prbs_sr(142) xor prbs_sr(74) xor prbs_sr(73);
				when 145 =>		  --145
					prbs_sr(0) := prbs_sr(144) xor prbs_sr(92);
				when 146 =>		  --146
					prbs_sr(0) := prbs_sr(145) xor prbs_sr(144) xor prbs_sr(86) xor prbs_sr(85);
				when 147 =>		  --147
					prbs_sr(0) := prbs_sr(146) xor prbs_sr(145) xor prbs_sr(109) xor prbs_sr(108);
				when 148 =>		  --148
					prbs_sr(0) := prbs_sr(147) xor prbs_sr(120);
				when 149 =>		  --149
					prbs_sr(0) := prbs_sr(148) xor prbs_sr(147) xor prbs_sr(39) xor prbs_sr(38);
				when 150 =>		  --150
					prbs_sr(0) := prbs_sr(149) xor prbs_sr(96);
				when 151 =>		  --151
					prbs_sr(0) := prbs_sr(150) xor prbs_sr(147);
				when 152 =>		  --152
					prbs_sr(0) := prbs_sr(151) xor prbs_sr(150) xor prbs_sr(86) xor prbs_sr(85);
				when 153 =>		  --153
					prbs_sr(0) := prbs_sr(152) xor prbs_sr(151);
				when 154 =>		  --154
					prbs_sr(0) := prbs_sr(153) xor prbs_sr(151) xor prbs_sr(26) xor prbs_sr(24);
				when 155 =>		  --155
					prbs_sr(0) := prbs_sr(154) xor prbs_sr(153) xor prbs_sr(123) xor prbs_sr(122);
				when 156 =>		  --156
					prbs_sr(0) := prbs_sr(155) xor prbs_sr(154) xor prbs_sr(40) xor prbs_sr(39);
				when 157 =>		  --157
					prbs_sr(0) := prbs_sr(156) xor prbs_sr(155) xor prbs_sr(130) xor prbs_sr(129);
				when 158 =>		  --158
					prbs_sr(0) := prbs_sr(157) xor prbs_sr(156) xor prbs_sr(131) xor prbs_sr(130);
				when 159 =>		  --159
					prbs_sr(0) := prbs_sr(158) xor prbs_sr(127);
				when 160 =>		  --160
					prbs_sr(0) := prbs_sr(159) xor prbs_sr(158) xor prbs_sr(141) xor prbs_sr(140);
				when 161 =>		  --161
					prbs_sr(0) := prbs_sr(160) xor prbs_sr(142);
				when 162 =>		  --162
					prbs_sr(0) := prbs_sr(161) xor prbs_sr(160) xor prbs_sr(74) xor prbs_sr(73);
				when 163 =>		  --163
					prbs_sr(0) := prbs_sr(162) xor prbs_sr(161) xor prbs_sr(103) xor prbs_sr(102);
				when 164 =>		  --164
					prbs_sr(0) := prbs_sr(163) xor prbs_sr(162) xor prbs_sr(150) xor prbs_sr(149);
				when 165 =>		  --165
					prbs_sr(0) := prbs_sr(164) xor prbs_sr(163) xor prbs_sr(134) xor prbs_sr(133);
				when 166 =>		  --166
					prbs_sr(0) := prbs_sr(165) xor prbs_sr(164) xor prbs_sr(127) xor prbs_sr(126);
				when 167 =>		  --167
					prbs_sr(0) := prbs_sr(166) xor prbs_sr(160);
				when 168 =>		  --168
					prbs_sr(0) := prbs_sr(167) xor prbs_sr(165) xor prbs_sr(152) xor prbs_sr(150);
				when others =>		  --168
					prbs_sr(0) := '0';
			end case;
			result(j) := prbs_sr(0);
			prbs_sr(prbs_sr'high downto 1) := prbs_sr(prbs_sr'high-1 downto 0);
		end loop;
		prbs_sr(MAX_PRBS downto poly+1) := (others=>'0');
	end prbs_shift;


end prbs_pkg;
