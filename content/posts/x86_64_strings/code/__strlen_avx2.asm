<+0>:	endbr64
<+4>:	mov    eax,edi
<+6>:	mov    rdx,rdi
<+9>:	vpxor  xmm0,xmm0,xmm0
<+13>:	and    eax,0xfff
<+18>:	cmp    eax,0xfe0
<+23>:	ja     0x7ffff7f29f90 <__strlen_avx2+336>
<+29>:	vpcmpeqb ymm1,ymm0,YMMWORD PTR [rdi]
<+33>:	vpmovmskb eax,ymm1
<+37>:	test   eax,eax
<+39>:	je     0x7ffff7f29ec0 <__strlen_avx2+128>
<+41>:	tzcnt  eax,eax
<+45>:	vzeroupper
<+48>:	ret
<+49>:	data16 cs nop WORD PTR [rax+rax*1+0x0]
<+60>:	nop    DWORD PTR [rax+0x0]
<+64>:	tzcnt  eax,eax
<+68>:	sub    edi,edx
<+70>:	inc    edi
<+72>:	add    eax,edi
<+74>:	vzeroupper
<+77>:	ret
<+78>:	xchg   ax,ax
<+80>:	tzcnt  eax,eax
<+84>:	sub    edi,edx
<+86>:	add    edi,0x21
<+89>:	add    eax,edi
<+91>:	vzeroupper
<+94>:	ret
<+95>:	nop
<+96>:	tzcnt  eax,eax
<+100>:	sub    edi,edx
<+102>:	add    edi,0x41
<+105>:	add    eax,edi
<+107>:	vzeroupper
<+110>:	ret
<+111>:	nop
<+112>:	tzcnt  eax,eax
<+116>:	sub    edi,edx
<+118>:	add    edi,0x61
<+121>:	add    eax,edi
<+123>:	vzeroupper
<+126>:	ret
<+127>:	nop
<+128>:	or     rdi,0x1f
<+132>:	vpcmpeqb ymm1,ymm0,YMMWORD PTR [rdi+0x1]
<+137>:	vpmovmskb eax,ymm1
<+141>:	test   eax,eax
<+143>:	jne    0x7ffff7f29e80 <__strlen_avx2+64>
<+145>:	vpcmpeqb ymm1,ymm0,YMMWORD PTR [rdi+0x21]
<+150>:	vpmovmskb eax,ymm1
<+154>:	test   eax,eax
<+156>:	jne    0x7ffff7f29e90 <__strlen_avx2+80>
<+158>:	vpcmpeqb ymm1,ymm0,YMMWORD PTR [rdi+0x41]
<+163>:	vpmovmskb eax,ymm1
<+167>:	test   eax,eax
<+169>:	jne    0x7ffff7f29ea0 <__strlen_avx2+96>
<+171>:	vpcmpeqb ymm1,ymm0,YMMWORD PTR [rdi+0x61]
<+176>:	vpmovmskb eax,ymm1
<+180>:	test   eax,eax
<+182>:	jne    0x7ffff7f29eb0 <__strlen_avx2+112>
<+184>:	inc    rdi
<+187>:	or     rdi,0x7f
<+191>:	nop
<+192>:	vmovdqa ymm1,YMMWORD PTR [rdi+0x1]
<+197>:	vpminub ymm2,ymm1,YMMWORD PTR [rdi+0x21]
<+202>:	vmovdqa ymm3,YMMWORD PTR [rdi+0x41]
<+207>:	vpminub ymm4,ymm3,YMMWORD PTR [rdi+0x61]
<+212>:	vpminub ymm5,ymm4,ymm2
<+216>:	vpcmpeqb ymm5,ymm0,ymm5
<+220>:	vpmovmskb ecx,ymm5
<+224>:	sub    rdi,0xffffffffffffff80
<+228>:	test   ecx,ecx
<+230>:	je     0x7ffff7f29f00 <__strlen_avx2+192>
<+232>:	vpcmpeqb ymm1,ymm0,ymm1
<+236>:	vpmovmskb eax,ymm1
<+240>:	sub    rdi,rdx
<+243>:	test   eax,eax
<+245>:	jne    0x7ffff7f29f70 <__strlen_avx2+304>
<+247>:	vpcmpeqb ymm2,ymm0,ymm2
<+251>:	vpmovmskb eax,ymm2
<+255>:	test   eax,eax
<+257>:	jne    0x7ffff7f29f80 <__strlen_avx2+320>
<+259>:	vpcmpeqb ymm3,ymm0,ymm3
<+263>:	vpmovmskb eax,ymm3
<+267>:	shl    rcx,0x20
<+271>:	or     rax,rcx
<+274>:	tzcnt  rax,rax
<+279>:	sub    rdi,0x3f
<+283>:	add    rax,rdi
<+286>:	vzeroupper
<+289>:	ret
<+290>:	data16 cs nop WORD PTR [rax+rax*1+0x0]
<+301>:	nop    DWORD PTR [rax]
<+304>:	tzcnt  eax,eax
<+308>:	sub    rdi,0x7f
<+312>:	add    rax,rdi
<+315>:	vzeroupper
<+318>:	ret
<+319>:	nop
<+320>:	tzcnt  eax,eax
<+324>:	sub    rdi,0x5f
<+328>:	add    rax,rdi
<+331>:	vzeroupper
<+334>:	ret
<+335>:	nop
<+336>:	or     rdi,0x1f
<+340>:	vpcmpeqb ymm1,ymm0,YMMWORD PTR [rdi-0x1f]
<+345>:	vpmovmskb eax,ymm1
<+349>:	sarx   eax,eax,edx
<+354>:	test   eax,eax
<+356>:	je     0x7ffff7f29ec4 <__strlen_avx2+132>
<+362>:	tzcnt  eax,eax
<+366>:	vzeroupper
<+369>:	ret
