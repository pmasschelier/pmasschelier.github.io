<+0>:	endbr64
<+4>:	cmp    rdx,0x20
<+8>:	jb     0x7ffff7f26c80 <__memcmp_avx2_movbe+736>
<+14>:	vmovdqu ymm1,YMMWORD PTR [rsi]
<+18>:	vpcmpeqb ymm1,ymm1,YMMWORD PTR [rdi]
<+22>:	vpmovmskb eax,ymm1
<+26>:	inc    eax
<+28>:	jne    0x7ffff7f26a80 <__memcmp_avx2_movbe+224>
<+34>:	cmp    rdx,0x40
<+38>:	jbe    0x7ffff7f26c04 <__memcmp_avx2_movbe+612>
<+44>:	vmovdqu ymm2,YMMWORD PTR [rsi+0x20]
<+49>:	vpcmpeqb ymm2,ymm2,YMMWORD PTR [rdi+0x20]
<+54>:	vpmovmskb eax,ymm2
<+58>:	inc    eax
<+60>:	jne    0x7ffff7f26aa0 <__memcmp_avx2_movbe+256>
<+66>:	cmp    rdx,0x80
<+73>:	jbe    0x7ffff7f26bf0 <__memcmp_avx2_movbe+592>
<+79>:	vmovdqu ymm3,YMMWORD PTR [rsi+0x40]
<+84>:	vpcmpeqb ymm3,ymm3,YMMWORD PTR [rdi+0x40]
<+89>:	vpmovmskb eax,ymm3
<+93>:	inc    eax
<+95>:	jne    0x7ffff7f26ac0 <__memcmp_avx2_movbe+288>
<+101>:	vmovdqu ymm4,YMMWORD PTR [rsi+0x60]
<+106>:	vpcmpeqb ymm4,ymm4,YMMWORD PTR [rdi+0x60]
<+111>:	vpmovmskb ecx,ymm4
<+115>:	inc    ecx
<+117>:	jne    0x7ffff7f26afb <__memcmp_avx2_movbe+347>
<+123>:	cmp    rdx,0x100
<+130>:	ja     0x7ffff7f26b10 <__memcmp_avx2_movbe+368>
<+136>:	vmovdqu ymm1,YMMWORD PTR [rsi+rdx*1-0x80]
<+142>:	vmovdqu ymm2,YMMWORD PTR [rsi+rdx*1-0x60]
<+148>:	lea    rdi,[rdi+rdx*1-0x80]
<+153>:	lea    rsi,[rsi+rdx*1-0x80]
<+158>:	vpcmpeqb ymm1,ymm1,YMMWORD PTR [rdi]
<+162>:	vpcmpeqb ymm2,ymm2,YMMWORD PTR [rdi+0x20]
<+167>:	vmovdqu ymm3,YMMWORD PTR [rsi+0x40]
<+172>:	vpcmpeqb ymm3,ymm3,YMMWORD PTR [rdi+0x40]
<+177>:	vmovdqu ymm4,YMMWORD PTR [rsi+0x60]
<+182>:	vpcmpeqb ymm4,ymm4,YMMWORD PTR [rdi+0x60]
<+187>:	vpand  ymm5,ymm2,ymm1
<+191>:	vpand  ymm6,ymm4,ymm3
<+195>:	vpand  ymm7,ymm6,ymm5
<+199>:	vpmovmskb ecx,ymm7
<+203>:	inc    ecx
<+205>:	jne    0x7ffff7f26ae3 <__memcmp_avx2_movbe+323>
<+207>:	vzeroupper
<+210>:	ret
<+211>:	data16 cs nop WORD PTR [rax+rax*1+0x0]
<+222>:	xchg   ax,ax
<+224>:	tzcnt  eax,eax
<+228>:	movzx  ecx,BYTE PTR [rsi+rax*1]
<+232>:	movzx  eax,BYTE PTR [rdi+rax*1]
<+236>:	sub    eax,ecx
<+238>:	vzeroupper
<+241>:	ret
<+242>:	data16 cs nop WORD PTR [rax+rax*1+0x0]
<+253>:	nop    DWORD PTR [rax]
<+256>:	tzcnt  eax,eax
<+260>:	movzx  ecx,BYTE PTR [rsi+rax*1+0x20]
<+265>:	movzx  eax,BYTE PTR [rdi+rax*1+0x20]
<+270>:	sub    eax,ecx
<+272>:	vzeroupper
<+275>:	ret
<+276>:	data16 cs nop WORD PTR [rax+rax*1+0x0]
<+287>:	nop
<+288>:	tzcnt  eax,eax
<+292>:	movzx  ecx,BYTE PTR [rsi+rax*1+0x40]
<+297>:	movzx  eax,BYTE PTR [rdi+rax*1+0x40]
<+302>:	sub    eax,ecx
<+304>:	vzeroupper
<+307>:	ret
<+308>:	data16 cs nop WORD PTR [rax+rax*1+0x0]
<+319>:	nop
<+320>:	add    rsi,rdi
<+323>:	vpmovmskb eax,ymm1
<+327>:	inc    eax
<+329>:	jne    0x7ffff7f26a80 <__memcmp_avx2_movbe+224>
<+331>:	vpmovmskb eax,ymm2
<+335>:	inc    eax
<+337>:	jne    0x7ffff7f26aa0 <__memcmp_avx2_movbe+256>
<+339>:	vpmovmskb eax,ymm3
<+343>:	inc    eax
<+345>:	jne    0x7ffff7f26ac0 <__memcmp_avx2_movbe+288>
<+347>:	tzcnt  ecx,ecx
<+351>:	movzx  eax,BYTE PTR [rdi+rcx*1+0x60]
<+356>:	movzx  ecx,BYTE PTR [rsi+rcx*1+0x60]
<+361>:	sub    eax,ecx
<+363>:	vzeroupper
<+366>:	ret
<+367>:	nop
<+368>:	lea    rdx,[rdi+rdx*1-0x80]
<+373>:	sub    rsi,rdi
<+376>:	and    rdi,0xffffffffffffffe0
<+380>:	sub    rdi,0xffffffffffffff80
<+384>:	vmovdqu ymm1,YMMWORD PTR [rsi+rdi*1]
<+389>:	vpcmpeqb ymm1,ymm1,YMMWORD PTR [rdi]
<+393>:	vmovdqu ymm2,YMMWORD PTR [rsi+rdi*1+0x20]
<+399>:	vpcmpeqb ymm2,ymm2,YMMWORD PTR [rdi+0x20]
<+404>:	vmovdqu ymm3,YMMWORD PTR [rsi+rdi*1+0x40]
<+410>:	vpcmpeqb ymm3,ymm3,YMMWORD PTR [rdi+0x40]
<+415>:	vmovdqu ymm4,YMMWORD PTR [rsi+rdi*1+0x60]
<+421>:	vpcmpeqb ymm4,ymm4,YMMWORD PTR [rdi+0x60]
<+426>:	vpand  ymm5,ymm2,ymm1
<+430>:	vpand  ymm6,ymm4,ymm3
<+434>:	vpand  ymm7,ymm6,ymm5
<+438>:	vpmovmskb ecx,ymm7
<+442>:	inc    ecx
<+444>:	jne    0x7ffff7f26ae0 <__memcmp_avx2_movbe+320>
<+446>:	sub    rdi,0xffffffffffffff80
<+450>:	cmp    rdi,rdx
<+453>:	jb     0x7ffff7f26b20 <__memcmp_avx2_movbe+384>
<+455>:	sub    rdi,rdx
<+458>:	cmp    edi,0x60
<+461>:	jae    0x7ffff7f26bd0 <__memcmp_avx2_movbe+560>
<+463>:	vmovdqu ymm3,YMMWORD PTR [rsi+rdx*1+0x40]
<+469>:	cmp    edi,0x40
<+472>:	jae    0x7ffff7f26bc0 <__memcmp_avx2_movbe+544>
<+474>:	vmovdqu ymm1,YMMWORD PTR [rsi+rdx*1]
<+479>:	vpcmpeqb ymm1,ymm1,YMMWORD PTR [rdx]
<+483>:	vmovdqu ymm2,YMMWORD PTR [rsi+rdx*1+0x20]
<+489>:	vpcmpeqb ymm2,ymm2,YMMWORD PTR [rdx+0x20]
<+494>:	vpcmpeqb ymm3,ymm3,YMMWORD PTR [rdx+0x40]
<+499>:	vmovdqu ymm4,YMMWORD PTR [rsi+rdx*1+0x60]
<+505>:	vpcmpeqb ymm4,ymm4,YMMWORD PTR [rdx+0x60]
<+510>:	vpand  ymm5,ymm2,ymm1
<+514>:	vpand  ymm6,ymm4,ymm3
<+518>:	vpand  ymm7,ymm6,ymm5
<+522>:	vpmovmskb ecx,ymm7
<+526>:	mov    rdi,rdx
<+529>:	inc    ecx
<+531>:	jne    0x7ffff7f26ae0 <__memcmp_avx2_movbe+320>
<+537>:	vzeroupper
<+540>:	ret
<+541>:	nop    DWORD PTR [rax]
<+544>:	vpcmpeqb ymm3,ymm3,YMMWORD PTR [rdx+0x40]
<+549>:	vpmovmskb eax,ymm3
<+553>:	inc    eax
<+555>:	jne    0x7ffff7f26c20 <__memcmp_avx2_movbe+640>
<+557>:	nop    DWORD PTR [rax]
<+560>:	vmovdqu ymm4,YMMWORD PTR [rsi+rdx*1+0x60]
<+566>:	vpcmpeqb ymm4,ymm4,YMMWORD PTR [rdx+0x60]
<+571>:	vpmovmskb eax,ymm4
<+575>:	inc    eax
<+577>:	jne    0x7ffff7f26c24 <__memcmp_avx2_movbe+644>
<+579>:	vzeroupper
<+582>:	ret
<+583>:	nop    WORD PTR [rax+rax*1+0x0]
<+592>:	vmovdqu ymm1,YMMWORD PTR [rsi+rdx*1-0x40]
<+598>:	vpcmpeqb ymm1,ymm1,YMMWORD PTR [rdi+rdx*1-0x40]
<+604>:	vpmovmskb eax,ymm1
<+608>:	inc    eax
<+610>:	jne    0x7ffff7f26c40 <__memcmp_avx2_movbe+672>
<+612>:	vmovdqu ymm1,YMMWORD PTR [rsi+rdx*1-0x20]
<+618>:	vpcmpeqb ymm1,ymm1,YMMWORD PTR [rdi+rdx*1-0x20]
<+624>:	vpmovmskb eax,ymm1
<+628>:	inc    eax
<+630>:	jne    0x7ffff7f26c60 <__memcmp_avx2_movbe+704>
<+632>:	vzeroupper
<+635>:	ret
<+636>:	nop    DWORD PTR [rax+0x0]
<+640>:	sub    rdx,0x20
<+644>:	tzcnt  eax,eax
<+648>:	add    rax,rdx
<+651>:	movzx  ecx,BYTE PTR [rsi+rax*1+0x60]
<+656>:	movzx  eax,BYTE PTR [rax+0x60]
<+660>:	sub    eax,ecx
<+662>:	vzeroupper
<+665>:	ret
<+666>:	nop    WORD PTR [rax+rax*1+0x0]
<+672>:	tzcnt  eax,eax
<+676>:	add    eax,edx
<+678>:	movzx  ecx,BYTE PTR [rsi+rax*1-0x40]
<+683>:	movzx  eax,BYTE PTR [rdi+rax*1-0x40]
<+688>:	sub    eax,ecx
<+690>:	vzeroupper
<+693>:	ret
<+694>:	cs nop WORD PTR [rax+rax*1+0x0]
<+704>:	tzcnt  eax,eax
<+708>:	add    eax,edx
<+710>:	movzx  ecx,BYTE PTR [rsi+rax*1-0x20]
<+715>:	movzx  eax,BYTE PTR [rdi+rax*1-0x20]
<+720>:	sub    eax,ecx
<+722>:	vzeroupper
<+725>:	ret
<+726>:	cs nop WORD PTR [rax+rax*1+0x0]
<+736>:	cmp    edx,0x1
<+739>:	jbe    0x7ffff7f26d00 <__memcmp_avx2_movbe+864>
<+741>:	mov    eax,edi
<+743>:	or     eax,esi
<+745>:	and    eax,0xfff
<+750>:	cmp    eax,0xfe0
<+755>:	jg     0x7ffff7f26cc0 <__memcmp_avx2_movbe+800>
<+757>:	vmovdqu ymm2,YMMWORD PTR [rsi]
<+761>:	vpcmpeqb ymm2,ymm2,YMMWORD PTR [rdi]
<+765>:	vpmovmskb eax,ymm2
<+769>:	inc    eax
<+771>:	bzhi   edx,eax,edx
<+776>:	jne    0x7ffff7f26a80 <__memcmp_avx2_movbe+224>
<+782>:	xor    eax,eax
<+784>:	vzeroupper
<+787>:	ret
<+788>:	data16 cs nop WORD PTR [rax+rax*1+0x0]
<+799>:	nop
<+800>:	cmp    edx,0x10
<+803>:	jae    0x7ffff7f26d43 <__memcmp_avx2_movbe+931>
<+805>:	cmp    edx,0x8
<+808>:	jae    0x7ffff7f26d20 <__memcmp_avx2_movbe+896>
<+810>:	cmp    edx,0x4
<+813>:	jb     0x7ffff7f26d80 <__memcmp_avx2_movbe+992>
<+819>:	movbe  eax,DWORD PTR [rdi]
<+823>:	movbe  ecx,DWORD PTR [rsi]
<+827>:	shl    rax,0x20
<+831>:	shl    rcx,0x20
<+835>:	movbe  edi,DWORD PTR [rdi+rdx*1-0x4]
<+841>:	movbe  esi,DWORD PTR [rsi+rdx*1-0x4]
<+847>:	or     rax,rdi
<+850>:	or     rcx,rsi
<+853>:	sub    rax,rcx
<+856>:	jne    0x7ffff7f26d10 <__memcmp_avx2_movbe+880>
<+858>:	ret
<+859>:	nop    DWORD PTR [rax+rax*1+0x0]
<+864>:	jb     0x7ffff7f26d16 <__memcmp_avx2_movbe+886>
<+866>:	movzx  ecx,BYTE PTR [rsi]
<+869>:	movzx  eax,BYTE PTR [rdi]
<+872>:	sub    eax,ecx
<+874>:	ret
<+875>:	nop    DWORD PTR [rax+rax*1+0x0]
<+880>:	sbb    eax,eax
<+882>:	or     eax,0x1
<+885>:	ret
<+886>:	xor    eax,eax
<+888>:	ret
<+889>:	nop    DWORD PTR [rax+0x0]
<+896>:	movbe  rax,QWORD PTR [rdi]
<+901>:	movbe  rcx,QWORD PTR [rsi]
<+906>:	sub    rax,rcx
<+909>:	jne    0x7ffff7f26d10 <__memcmp_avx2_movbe+880>
<+911>:	movbe  rax,QWORD PTR [rdi+rdx*1-0x8]
<+918>:	movbe  rcx,QWORD PTR [rsi+rdx*1-0x8]
<+925>:	sub    rax,rcx
<+928>:	jne    0x7ffff7f26d10 <__memcmp_avx2_movbe+880>
<+930>:	ret
<+931>:	vmovdqu xmm2,XMMWORD PTR [rsi]
<+935>:	vpcmpeqb xmm2,xmm2,XMMWORD PTR [rdi]
<+939>:	vpmovmskb eax,xmm2
<+943>:	sub    eax,0xffff
<+948>:	jne    0x7ffff7f26a80 <__memcmp_avx2_movbe+224>
<+954>:	vmovdqu xmm2,XMMWORD PTR [rsi+rdx*1-0x10]
<+960>:	lea    rdi,[rdi+rdx*1-0x10]
<+965>:	lea    rsi,[rsi+rdx*1-0x10]
<+970>:	vpcmpeqb xmm2,xmm2,XMMWORD PTR [rdi]
<+974>:	vpmovmskb eax,xmm2
<+978>:	sub    eax,0xffff
<+983>:	jne    0x7ffff7f26a80 <__memcmp_avx2_movbe+224>
<+989>:	ret
<+990>:	xchg   ax,ax
<+992>:	movzx  eax,WORD PTR [rdi]
<+995>:	movzx  ecx,WORD PTR [rsi]
<+998>:	bswap  eax
<+1000>:	bswap  ecx
<+1002>:	shr    eax,1
<+1004>:	shr    ecx,1
<+1006>:	movzx  edi,BYTE PTR [rdi+rdx*1-0x1]
<+1011>:	movzx  esi,BYTE PTR [rsi+rdx*1-0x1]
<+1016>:	or     eax,edi
<+1018>:	or     ecx,esi
<+1020>:	sub    eax,ecx
<+1022>:	ret
