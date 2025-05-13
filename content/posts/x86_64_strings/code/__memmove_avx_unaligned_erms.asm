<+0>:	endbr64
<+4>:	mov    rax,rdi												; Copy the pointer to destination into rax
<+7>:	cmp    rdx,0x20												; Compare size to 0x20 (32 bytes)
<+11>:	jb     0x7ffff7f27130 <__memmove_avx_unaligned_erms+48>		; If smaller jump
<+13>:	vmovdqu ymm0,YMMWORD PTR [rsi]								; Otherwise loads the first 32 bytes of src into ymm0
<+17>:	cmp    rdx,0x40												; Compare size to 0x40 (64 bytes)
<+21>:	ja     0x7ffff7f271c0 <__memmove_avx_unaligned_erms+192>	; If above jump
<+27>:	vmovdqu ymm1,YMMWORD PTR [rsi+rdx*1-0x20]
<+33>:	vmovdqu YMMWORD PTR [rdi],ymm0
<+37>:	vmovdqu YMMWORD PTR [rdi+rdx*1-0x20],ymm1
<+43>:	vzeroupper
<+46>:	ret
<+47>:	nop
<+48>:	cmp    edx,0x10
<+51>:	jae    0x7ffff7f27162 <__memmove_avx_unaligned_erms+98>
<+53>:	cmp    edx,0x8
<+56>:	jae    0x7ffff7f27180 <__memmove_avx_unaligned_erms+128>
<+58>:	cmp    edx,0x4
<+61>:	jae    0x7ffff7f27155 <__memmove_avx_unaligned_erms+85>
<+63>:	cmp    edx,0x1
<+66>:	jl     0x7ffff7f27154 <__memmove_avx_unaligned_erms+84>
<+68>:	mov    cl,BYTE PTR [rsi]
<+70>:	je     0x7ffff7f27152 <__memmove_avx_unaligned_erms+82>
<+72>:	movzx  esi,WORD PTR [rsi+rdx*1-0x2]
<+77>:	mov    WORD PTR [rdi+rdx*1-0x2],si
<+82>:	mov    BYTE PTR [rdi],cl
<+84>:	ret
<+85>:	mov    ecx,DWORD PTR [rsi+rdx*1-0x4]
<+89>:	mov    esi,DWORD PTR [rsi]
<+91>:	mov    DWORD PTR [rdi+rdx*1-0x4],ecx
<+95>:	mov    DWORD PTR [rdi],esi
<+97>:	ret
<+98>:	vmovdqu xmm0,XMMWORD PTR [rsi]
<+102>:	vmovdqu xmm1,XMMWORD PTR [rsi+rdx*1-0x10]
<+108>:	vmovdqu XMMWORD PTR [rdi],xmm0
<+112>:	vmovdqu XMMWORD PTR [rdi+rdx*1-0x10],xmm1
<+118>:	ret
<+119>:	nop    WORD PTR [rax+rax*1+0x0]
<+128>:	mov    rcx,QWORD PTR [rsi+rdx*1-0x8]
<+133>:	mov    rsi,QWORD PTR [rsi]
<+136>:	mov    QWORD PTR [rdi],rsi
<+139>:	mov    QWORD PTR [rdi+rdx*1-0x8],rcx
<+144>:	ret
<+145>:	vmovdqu ymm2,YMMWORD PTR [rsi+rdx*1-0x20]
<+151>:	vmovdqu ymm3,YMMWORD PTR [rsi+rdx*1-0x40]
<+157>:	vmovdqu YMMWORD PTR [rdi],ymm0
<+161>:	vmovdqu YMMWORD PTR [rdi+0x20],ymm1
<+166>:	vmovdqu YMMWORD PTR [rdi+rdx*1-0x20],ymm2
<+172>:	vmovdqu YMMWORD PTR [rdi+rdx*1-0x40],ymm3
<+178>:	vzeroupper
<+181>:	ret
<+182>:	cs nop WORD PTR [rax+rax*1+0x0]
<+192>:	cmp    rdx,QWORD PTR [rip+0x7a051]        # 0x7ffff7fa1218 <__x86_rep_movsb_threshold>
<+199>:	ja     0x7ffff7f273c0 <__memmove_avx_unaligned_erms+704> ; Jump if size > __x86_rep_movsb_threshold
<+205>:	cmp    rdx,0x100
<+212>:	ja     0x7ffff7f27235 <__memmove_avx_unaligned_erms+309>
<+214>:	vmovdqu ymm1,YMMWORD PTR [rsi+0x20]
<+219>:	cmp    rdx,0x80
<+226>:	jbe    0x7ffff7f27191 <__memmove_avx_unaligned_erms+145>
<+228>:	vmovdqu ymm2,YMMWORD PTR [rsi+0x40]
<+233>:	vmovdqu ymm3,YMMWORD PTR [rsi+0x60]
<+238>:	vmovdqu ymm4,YMMWORD PTR [rsi+rdx*1-0x20]
<+244>:	vmovdqu ymm5,YMMWORD PTR [rsi+rdx*1-0x40]
<+250>:	vmovdqu ymm6,YMMWORD PTR [rsi+rdx*1-0x60]
<+256>:	vmovdqu ymm7,YMMWORD PTR [rsi+rdx*1-0x80]
<+262>:	vmovdqu YMMWORD PTR [rdi],ymm0
<+266>:	vmovdqu YMMWORD PTR [rdi+0x20],ymm1
<+271>:	vmovdqu YMMWORD PTR [rdi+0x40],ymm2
<+276>:	vmovdqu YMMWORD PTR [rdi+0x60],ymm3
<+281>:	vmovdqu YMMWORD PTR [rdi+rdx*1-0x20],ymm4
<+287>:	vmovdqu YMMWORD PTR [rdi+rdx*1-0x40],ymm5
<+293>:	vmovdqu YMMWORD PTR [rdi+rdx*1-0x60],ymm6
<+299>:	vmovdqu YMMWORD PTR [rdi+rdx*1-0x80],ymm7
<+305>:	vzeroupper
<+308>:	ret
<+309>:	mov    rcx,rdi
<+312>:	sub    rcx,rsi
<+315>:	cmp    rcx,rdx
<+318>:	jb     0x7ffff7f272f0 <__memmove_avx_unaligned_erms+496>
<+324>:	cmp    rdx,QWORD PTR [rip+0x80fe5]        # 0x7ffff7fa8230 <__x86_shared_non_temporal_threshold>
<+331>:	ja     0x7ffff7f27420 <__memmove_avx_unaligned_erms+800>
<+337>:	lea    r8,[rcx+rdx*1]
<+341>:	xor    r8,rcx
<+344>:	shr    r8,0x3f
<+348>:	and    ecx,0xf00
<+354>:	add    ecx,r8d
<+357>:	je     0x7ffff7f272f5 <__memmove_avx_unaligned_erms+501>
<+363>:	vmovdqu ymm5,YMMWORD PTR [rsi+rdx*1-0x20]
<+369>:	vmovdqu ymm6,YMMWORD PTR [rsi+rdx*1-0x40]
<+375>:	mov    rcx,rdi
<+378>:	or     rdi,0x1f
<+382>:	vmovdqu ymm7,YMMWORD PTR [rsi+rdx*1-0x60]
<+388>:	vmovdqu ymm8,YMMWORD PTR [rsi+rdx*1-0x80]
<+394>:	sub    rsi,rcx
<+397>:	inc    rdi
<+400>:	add    rsi,rdi
<+403>:	lea    rdx,[rcx+rdx*1-0x80]
<+408>:	nop    DWORD PTR [rax+rax*1+0x0]
<+416>:	vmovdqu ymm1,YMMWORD PTR [rsi]
<+420>:	vmovdqu ymm2,YMMWORD PTR [rsi+0x20]
<+425>:	vmovdqu ymm3,YMMWORD PTR [rsi+0x40]
<+430>:	vmovdqu ymm4,YMMWORD PTR [rsi+0x60]
<+435>:	sub    rsi,0xffffffffffffff80
<+439>:	vmovdqa YMMWORD PTR [rdi],ymm1
<+443>:	vmovdqa YMMWORD PTR [rdi+0x20],ymm2
<+448>:	vmovdqa YMMWORD PTR [rdi+0x40],ymm3
<+453>:	vmovdqa YMMWORD PTR [rdi+0x60],ymm4
<+458>:	sub    rdi,0xffffffffffffff80
<+462>:	cmp    rdx,rdi
<+465>:	ja     0x7ffff7f272a0 <__memmove_avx_unaligned_erms+416>
<+467>:	vmovdqu YMMWORD PTR [rdx+0x60],ymm5
<+472>:	vmovdqu YMMWORD PTR [rdx+0x40],ymm6
<+477>:	vmovdqu YMMWORD PTR [rdx+0x20],ymm7
<+482>:	vmovdqu YMMWORD PTR [rdx],ymm8
<+486>:	vmovdqu YMMWORD PTR [rcx],ymm0
<+490>:	vzeroupper
<+493>:	ret
<+494>:	xchg   ax,ax
<+496>:	test   rcx,rcx
<+499>:	je     0x7ffff7f272ea <__memmove_avx_unaligned_erms+490>
<+501>:	vmovdqu ymm5,YMMWORD PTR [rsi+0x20]
<+506>:	vmovdqu ymm6,YMMWORD PTR [rsi+0x40]
<+511>:	lea    rcx,[rdi+rdx*1-0x81]
<+519>:	vmovdqu ymm7,YMMWORD PTR [rsi+0x60]
<+524>:	vmovdqu ymm8,YMMWORD PTR [rsi+rdx*1-0x20]
<+530>:	sub    rsi,rdi
<+533>:	and    rcx,0xffffffffffffffe0
<+537>:	add    rsi,rcx
<+540>:	nop    DWORD PTR [rax+0x0]
<+544>:	vmovdqu ymm1,YMMWORD PTR [rsi+0x60]
<+549>:	vmovdqu ymm2,YMMWORD PTR [rsi+0x40]
<+554>:	vmovdqu ymm3,YMMWORD PTR [rsi+0x20]
<+559>:	vmovdqu ymm4,YMMWORD PTR [rsi]
<+563>:	add    rsi,0xffffffffffffff80
<+567>:	vmovdqa YMMWORD PTR [rcx+0x60],ymm1
<+572>:	vmovdqa YMMWORD PTR [rcx+0x40],ymm2
<+577>:	vmovdqa YMMWORD PTR [rcx+0x20],ymm3
<+582>:	vmovdqa YMMWORD PTR [rcx],ymm4
<+586>:	add    rcx,0xffffffffffffff80
<+590>:	cmp    rdi,rcx
<+593>:	jb     0x7ffff7f27320 <__memmove_avx_unaligned_erms+544>
<+595>:	vmovdqu YMMWORD PTR [rdi],ymm0
<+599>:	vmovdqu YMMWORD PTR [rdi+0x20],ymm5
<+604>:	vmovdqu YMMWORD PTR [rdi+0x40],ymm6
<+609>:	vmovdqu YMMWORD PTR [rdi+0x60],ymm7
<+614>:	vmovdqu YMMWORD PTR [rdx+rdi*1-0x20],ymm8
<+620>:	vzeroupper
<+623>:	ret
<+624>:	data16 cs nop WORD PTR [rax+rax*1+0x0]
<+635>:	nop    DWORD PTR [rax+rax*1+0x0]
<+640>:	vmovdqu ymm1,YMMWORD PTR [rsi+0x20]
<+645>:	test   ecx,0xe00
<+651>:	jne    0x7ffff7f273f2 <__memmove_avx_unaligned_erms+754>
<+653>:	mov    r9,rcx
<+656>:	lea    rcx,[rsi+rdx*1-0x1]
<+661>:	or     rsi,0x3f
<+665>:	lea    rdi,[rsi+r9*1+0x1]
<+670>:	sub    rcx,rsi
<+673>:	inc    rsi
<+676>:	rep movs BYTE PTR es:[rdi],BYTE PTR ds:[rsi]
<+678>:	vmovdqu YMMWORD PTR [r8],ymm0
<+683>:	vmovdqu YMMWORD PTR [r8+0x20],ymm1
<+689>:	vzeroupper
<+692>:	ret
<+693>:	data16 cs nop WORD PTR [rax+rax*1+0x0]
<+704>:	mov    rcx,rdi												; Copy pointer to dest in rcx
<+707>:	sub    rcx,rsi												; rcx = dest - src
<+710>:	cmp    rcx,rdx												; if (rcx < size)
<+713>:	jb     0x7ffff7f272f0 <__memmove_avx_unaligned_erms+496>	;	 jump
<+719>:	mov    r8,rdi												; Copy pointer to dest in r8
<+722>:	cmp    rdx,QWORD PTR [rip+0x80e4f]        # 0x7ffff7fa8228 <__x86_rep_movsb_stop_threshold>
<+729>:	jae    0x7ffff7f27420 <__memmove_avx_unaligned_erms+800>	; if(size >= __x86_rep_movsb_stop_threshold) jump
<+731>:	test   BYTE PTR [rip+0x80e3e],0x1        # 0x7ffff7fa8220 <__x86_string_control>
<+738>:	je     0x7ffff7f27380 <__memmove_avx_unaligned_erms+640>	; if(__x86_string_control & 0x1 == 0) jump
<+740>:	cmp    ecx,0xffffffc0										; if(rcx > 0xffffffc0)
<+743>:	ja     0x7ffff7f2726b <__memmove_avx_unaligned_erms+363>	;	 jump
<+749>:	vmovdqu ymm1,YMMWORD PTR [rsi+0x20]							; Loads the first 32th-63th bytes of src into ymm1
<+754>:	sub    rsi,rdi												; rsi = src - dest
<+757>:	add    rdi,0x3f												; rdi = dest + 63 bytes
<+761>:	lea    rcx,[r8+rdx*1]										; rcx = dest + size
<+765>:	and    rdi,0xffffffffffffffc0								; Align rdi on 64 bytes
<+769>:	add    rsi,rdi												; rsi = (src - dest + (dest{64 bytes aligned}))
<+772>:	sub    rcx,rdi												; rcx = dest + size - dest{64 bytes aligned}
<+775>:	rep movs BYTE PTR es:[rdi],BYTE PTR ds:[rsi] 				; OUR REP MOVSB INSTRUCTION !!!
<+777>:	vmovdqu YMMWORD PTR [r8],ymm0								; Copy ymm0 content to dest
<+782>:	vmovdqu YMMWORD PTR [r8+0x20],ymm1							; Copy ymm1 content to dest
<+788>:	vzeroupper													; Reset for SSE2
<+791>:	ret
<+792>:	nop    DWORD PTR [rax+rax*1+0x0]
<+800>:	mov    r11,QWORD PTR [rip+0x80e09]        # 0x7ffff7fa8230 <__x86_shared_non_temporal_threshold>
<+807>:	cmp    rdx,r11
<+810>:	jb     0x7ffff7f27251 <__memmove_avx_unaligned_erms+337>
<+816>:	neg    rcx
<+819>:	cmp    rdx,rcx
<+822>:	ja     0x7ffff7f2726b <__memmove_avx_unaligned_erms+363>
<+828>:	vmovdqu ymm1,YMMWORD PTR [rsi+0x20]
<+833>:	vmovdqu YMMWORD PTR [rdi],ymm0
<+837>:	vmovdqu YMMWORD PTR [rdi+0x20],ymm1
<+842>:	mov    r8,rdi
<+845>:	and    r8,0x3f
<+849>:	sub    r8,0x40
<+853>:	sub    rsi,r8
<+856>:	sub    rdi,r8
<+859>:	add    rdx,r8
<+862>:	not    ecx
<+864>:	mov    r10,rdx
<+867>:	test   ecx,0xf00
<+873>:	je     0x7ffff7f275f0 <__memmove_avx_unaligned_erms+1264>
<+879>:	shl    r11,0x4
<+883>:	cmp    rdx,r11
<+886>:	jae    0x7ffff7f275f0 <__memmove_avx_unaligned_erms+1264>
<+892>:	and    edx,0x1fff
<+898>:	shr    r10,0xd
<+902>:	cs nop WORD PTR [rax+rax*1+0x0]
<+912>:	mov    ecx,0x20
<+917>:	prefetcht0 BYTE PTR [rsi+0x80]
<+924>:	prefetcht0 BYTE PTR [rsi+0xc0]
<+931>:	prefetcht0 BYTE PTR [rsi+0x100]
<+938>:	prefetcht0 BYTE PTR [rsi+0x140]
<+945>:	prefetcht0 BYTE PTR [rsi+0x1080]
<+952>:	prefetcht0 BYTE PTR [rsi+0x10c0]
<+959>:	prefetcht0 BYTE PTR [rsi+0x1100]
<+966>:	prefetcht0 BYTE PTR [rsi+0x1140]
<+973>:	vmovdqu ymm0,YMMWORD PTR [rsi]
<+977>:	vmovdqu ymm1,YMMWORD PTR [rsi+0x20]
<+982>:	vmovdqu ymm2,YMMWORD PTR [rsi+0x40]
<+987>:	vmovdqu ymm3,YMMWORD PTR [rsi+0x60]
<+992>:	vmovdqu ymm4,YMMWORD PTR [rsi+0x1000]
<+1000>:	vmovdqu ymm5,YMMWORD PTR [rsi+0x1020]
<+1008>:	vmovdqu ymm6,YMMWORD PTR [rsi+0x1040]
<+1016>:	vmovdqu ymm7,YMMWORD PTR [rsi+0x1060]
<+1024>:	sub    rsi,0xffffffffffffff80
<+1028>:	vmovntdq YMMWORD PTR [rdi],ymm0
<+1032>:	vmovntdq YMMWORD PTR [rdi+0x20],ymm1
<+1037>:	vmovntdq YMMWORD PTR [rdi+0x40],ymm2
<+1042>:	vmovntdq YMMWORD PTR [rdi+0x60],ymm3
<+1047>:	vmovntdq YMMWORD PTR [rdi+0x1000],ymm4
<+1055>:	vmovntdq YMMWORD PTR [rdi+0x1020],ymm5
<+1063>:	vmovntdq YMMWORD PTR [rdi+0x1040],ymm6
<+1071>:	vmovntdq YMMWORD PTR [rdi+0x1060],ymm7
<+1079>:	sub    rdi,0xffffffffffffff80
<+1083>:	dec    ecx
<+1085>:	jne    0x7ffff7f27495 <__memmove_avx_unaligned_erms+917>
<+1091>:	add    rdi,0x1000
<+1098>:	add    rsi,0x1000
<+1105>:	dec    r10
<+1108>:	jne    0x7ffff7f27490 <__memmove_avx_unaligned_erms+912>
<+1114>:	sfence
<+1117>:	cmp    edx,0x80
<+1123>:	jbe    0x7ffff7f275ba <__memmove_avx_unaligned_erms+1210>
<+1125>:	prefetcht0 BYTE PTR [rsi+0x80]
<+1132>:	prefetcht0 BYTE PTR [rsi+0xc0]
<+1139>:	prefetcht0 BYTE PTR [rdi+0x80]
<+1146>:	prefetcht0 BYTE PTR [rdi+0xc0]
<+1153>:	vmovdqu ymm0,YMMWORD PTR [rsi]
<+1157>:	vmovdqu ymm1,YMMWORD PTR [rsi+0x20]
<+1162>:	vmovdqu ymm2,YMMWORD PTR [rsi+0x40]
<+1167>:	vmovdqu ymm3,YMMWORD PTR [rsi+0x60]
<+1172>:	sub    rsi,0xffffffffffffff80
<+1176>:	add    edx,0xffffff80
<+1179>:	vmovdqa YMMWORD PTR [rdi],ymm0
<+1183>:	vmovdqa YMMWORD PTR [rdi+0x20],ymm1
<+1188>:	vmovdqa YMMWORD PTR [rdi+0x40],ymm2
<+1193>:	vmovdqa YMMWORD PTR [rdi+0x60],ymm3
<+1198>:	sub    rdi,0xffffffffffffff80
<+1202>:	cmp    edx,0x80
<+1208>:	ja     0x7ffff7f27565 <__memmove_avx_unaligned_erms+1125>
<+1210>:	vmovdqu ymm0,YMMWORD PTR [rsi+rdx*1-0x80]
<+1216>:	vmovdqu ymm1,YMMWORD PTR [rsi+rdx*1-0x60]
<+1222>:	vmovdqu ymm2,YMMWORD PTR [rsi+rdx*1-0x40]
<+1228>:	vmovdqu ymm3,YMMWORD PTR [rsi+rdx*1-0x20]
<+1234>:	vmovdqu YMMWORD PTR [rdi+rdx*1-0x80],ymm0
<+1240>:	vmovdqu YMMWORD PTR [rdi+rdx*1-0x60],ymm1
<+1246>:	vmovdqu YMMWORD PTR [rdi+rdx*1-0x40],ymm2
<+1252>:	vmovdqu YMMWORD PTR [rdi+rdx*1-0x20],ymm3
<+1258>:	vzeroupper
<+1261>:	ret
<+1262>:	xchg   ax,ax
<+1264>:	and    edx,0x3fff
<+1270>:	shr    r10,0xe
<+1274>:	nop    WORD PTR [rax+rax*1+0x0]
<+1280>:	mov    ecx,0x20
<+1285>:	prefetcht0 BYTE PTR [rsi+0x80]
<+1292>:	prefetcht0 BYTE PTR [rsi+0xc0]
<+1299>:	prefetcht0 BYTE PTR [rsi+0x1080]
<+1306>:	prefetcht0 BYTE PTR [rsi+0x10c0]
<+1313>:	prefetcht0 BYTE PTR [rsi+0x2080]
<+1320>:	prefetcht0 BYTE PTR [rsi+0x20c0]
<+1327>:	prefetcht0 BYTE PTR [rsi+0x3080]
<+1334>:	prefetcht0 BYTE PTR [rsi+0x30c0]
<+1341>:	vmovdqu ymm0,YMMWORD PTR [rsi]
<+1345>:	vmovdqu ymm1,YMMWORD PTR [rsi+0x20]
<+1350>:	vmovdqu ymm2,YMMWORD PTR [rsi+0x40]
<+1355>:	vmovdqu ymm3,YMMWORD PTR [rsi+0x60]
<+1360>:	vmovdqu ymm4,YMMWORD PTR [rsi+0x1000]
<+1368>:	vmovdqu ymm5,YMMWORD PTR [rsi+0x1020]
<+1376>:	vmovdqu ymm6,YMMWORD PTR [rsi+0x1040]
<+1384>:	vmovdqu ymm7,YMMWORD PTR [rsi+0x1060]
<+1392>:	vmovdqu ymm8,YMMWORD PTR [rsi+0x2000]
<+1400>:	vmovdqu ymm9,YMMWORD PTR [rsi+0x2020]
<+1408>:	vmovdqu ymm10,YMMWORD PTR [rsi+0x2040]
<+1416>:	vmovdqu ymm11,YMMWORD PTR [rsi+0x2060]
<+1424>:	vmovdqu ymm12,YMMWORD PTR [rsi+0x3000]
<+1432>:	vmovdqu ymm13,YMMWORD PTR [rsi+0x3020]
<+1440>:	vmovdqu ymm14,YMMWORD PTR [rsi+0x3040]
<+1448>:	vmovdqu ymm15,YMMWORD PTR [rsi+0x3060]
<+1456>:	sub    rsi,0xffffffffffffff80
<+1460>:	vmovntdq YMMWORD PTR [rdi],ymm0
<+1464>:	vmovntdq YMMWORD PTR [rdi+0x20],ymm1
<+1469>:	vmovntdq YMMWORD PTR [rdi+0x40],ymm2
<+1474>:	vmovntdq YMMWORD PTR [rdi+0x60],ymm3
<+1479>:	vmovntdq YMMWORD PTR [rdi+0x1000],ymm4
<+1487>:	vmovntdq YMMWORD PTR [rdi+0x1020],ymm5
<+1495>:	vmovntdq YMMWORD PTR [rdi+0x1040],ymm6
<+1503>:	vmovntdq YMMWORD PTR [rdi+0x1060],ymm7
<+1511>:	vmovntdq YMMWORD PTR [rdi+0x2000],ymm8
<+1519>:	vmovntdq YMMWORD PTR [rdi+0x2020],ymm9
<+1527>:	vmovntdq YMMWORD PTR [rdi+0x2040],ymm10
<+1535>:	vmovntdq YMMWORD PTR [rdi+0x2060],ymm11
<+1543>:	vmovntdq YMMWORD PTR [rdi+0x3000],ymm12
<+1551>:	vmovntdq YMMWORD PTR [rdi+0x3020],ymm13
<+1559>:	vmovntdq YMMWORD PTR [rdi+0x3040],ymm14
<+1567>:	vmovntdq YMMWORD PTR [rdi+0x3060],ymm15
<+1575>:	sub    rdi,0xffffffffffffff80
<+1579>:	dec    ecx
<+1581>:	jne    0x7ffff7f27605 <__memmove_avx_unaligned_erms+1285>
<+1587>:	add    rdi,0x3000
<+1594>:	add    rsi,0x3000
<+1601>:	dec    r10
<+1604>:	jne    0x7ffff7f27600 <__memmove_avx_unaligned_erms+1280>
<+1610>:	sfence
<+1613>:	cmp    edx,0x80
<+1619>:	jbe    0x7ffff7f277aa <__memmove_avx_unaligned_erms+1706>
<+1621>:	prefetcht0 BYTE PTR [rsi+0x80]
<+1628>:	prefetcht0 BYTE PTR [rsi+0xc0]
<+1635>:	prefetcht0 BYTE PTR [rdi+0x80]
<+1642>:	prefetcht0 BYTE PTR [rdi+0xc0]
<+1649>:	vmovdqu ymm0,YMMWORD PTR [rsi]
<+1653>:	vmovdqu ymm1,YMMWORD PTR [rsi+0x20]
<+1658>:	vmovdqu ymm2,YMMWORD PTR [rsi+0x40]
<+1663>:	vmovdqu ymm3,YMMWORD PTR [rsi+0x60]
<+1668>:	sub    rsi,0xffffffffffffff80
<+1672>:	add    edx,0xffffff80
<+1675>:	vmovdqa YMMWORD PTR [rdi],ymm0
<+1679>:	vmovdqa YMMWORD PTR [rdi+0x20],ymm1
<+1684>:	vmovdqa YMMWORD PTR [rdi+0x40],ymm2
<+1689>:	vmovdqa YMMWORD PTR [rdi+0x60],ymm3
<+1694>:	sub    rdi,0xffffffffffffff80
<+1698>:	cmp    edx,0x80
<+1704>:	ja     0x7ffff7f27755 <__memmove_avx_unaligned_erms+1621>
<+1706>:	vmovdqu ymm0,YMMWORD PTR [rsi+rdx*1-0x80]
<+1712>:	vmovdqu ymm1,YMMWORD PTR [rsi+rdx*1-0x60]
<+1718>:	vmovdqu ymm2,YMMWORD PTR [rsi+rdx*1-0x40]
<+1724>:	vmovdqu ymm3,YMMWORD PTR [rsi+rdx*1-0x20]
<+1730>:	vmovdqu YMMWORD PTR [rdi+rdx*1-0x80],ymm0
<+1736>:	vmovdqu YMMWORD PTR [rdi+rdx*1-0x60],ymm1
<+1742>:	vmovdqu YMMWORD PTR [rdi+rdx*1-0x40],ymm2
<+1748>:	vmovdqu YMMWORD PTR [rdi+rdx*1-0x20],ymm3
<+1754>:	vzeroupper
<+1757>:	ret
