<+0>:	endbr64
<+4>:	vmovd  xmm0,esi
<+8>:	mov    rax,rdi
<+11>:	cmp    rdx,0x20
<+15>:	jb     0x7ffff7f27be0 <__memset_avx2_unaligned_erms+224>
<+21>:	vpbroadcastb ymm0,xmm0
<+26>:	cmp    rdx,0x40
<+30>:	ja     0x7ffff7f27b40 <__memset_avx2_unaligned_erms+64>
<+32>:	vmovdqu YMMWORD PTR [rdi],ymm0
<+36>:	vmovdqu YMMWORD PTR [rdi+rdx*1-0x20],ymm0
<+42>:	vzeroupper
<+45>:	ret
<+46>:	xchg   ax,ax
<+48>:	vmovdqu YMMWORD PTR [rdi-0x40],ymm0
<+53>:	vmovdqu YMMWORD PTR [rdi-0x20],ymm0
<+58>:	vzeroupper
<+61>:	ret
<+62>:	xchg   ax,ax
<+64>:	cmp    rdx,QWORD PTR [rip+0x796c9]        # 0x7ffff7fa1210 <__x86_rep_stosb_threshold>
<+71>:	ja     0x7ffff7f27bc0 <__memset_avx2_unaligned_erms+192>
<+73>:	vmovdqu YMMWORD PTR [rdi],ymm0
<+77>:	vmovdqu YMMWORD PTR [rdi+0x20],ymm0
<+82>:	add    rdi,rdx
<+85>:	cmp    rdx,0x80
<+92>:	jbe    0x7ffff7f27b30 <__memset_avx2_unaligned_erms+48>
<+94>:	vmovdqu YMMWORD PTR [rax+0x40],ymm0
<+99>:	vmovdqu YMMWORD PTR [rax+0x60],ymm0
<+104>:	add    rdi,0xffffffffffffff80
<+108>:	cmp    rdx,0x100
<+115>:	jbe    0x7ffff7f27ba0 <__memset_avx2_unaligned_erms+160>
<+117>:	lea    rdx,[rax+0x80]
<+124>:	and    rdx,0xffffffffffffffe0
<+128>:	vmovdqa YMMWORD PTR [rdx],ymm0
<+132>:	vmovdqa YMMWORD PTR [rdx+0x20],ymm0
<+137>:	vmovdqa YMMWORD PTR [rdx+0x40],ymm0
<+142>:	vmovdqa YMMWORD PTR [rdx+0x60],ymm0
<+147>:	sub    rdx,0xffffffffffffff80
<+151>:	cmp    rdx,rdi
<+154>:	jb     0x7ffff7f27b80 <__memset_avx2_unaligned_erms+128>
<+156>:	nop    DWORD PTR [rax+0x0]
<+160>:	vmovdqu YMMWORD PTR [rdi],ymm0
<+164>:	vmovdqu YMMWORD PTR [rdi+0x20],ymm0
<+169>:	vmovdqu YMMWORD PTR [rdi+0x40],ymm0
<+174>:	vmovdqu YMMWORD PTR [rdi+0x60],ymm0
<+179>:	vzeroupper
<+182>:	ret
<+183>:	nop    WORD PTR [rax+rax*1+0x0]
<+192>:	movzx  eax,sil
<+196>:	mov    rcx,rdx
<+199>:	mov    rdx,rdi
<+202>:	rep stos BYTE PTR es:[rdi],al
<+204>:	mov    rax,rdx
<+207>:	vzeroupper
<+210>:	ret
<+211>:	data16 cs nop WORD PTR [rax+rax*1+0x0]
<+222>:	xchg   ax,ax
<+224>:	vpbroadcastb xmm0,xmm0
<+229>:	cmp    edx,0x10
<+232>:	jge    0x7ffff7f27c00 <__memset_avx2_unaligned_erms+256>
<+234>:	cmp    edx,0x8
<+237>:	jge    0x7ffff7f27c10 <__memset_avx2_unaligned_erms+272>
<+239>:	cmp    edx,0x4
<+242>:	jge    0x7ffff7f27c20 <__memset_avx2_unaligned_erms+288>
<+244>:	cmp    edx,0x1
<+247>:	jg     0x7ffff7f27c30 <__memset_avx2_unaligned_erms+304>
<+249>:	jl     0x7ffff7f27bfe <__memset_avx2_unaligned_erms+254>
<+251>:	mov    BYTE PTR [rdi],sil
<+254>:	ret
<+255>:	nop
<+256>:	vmovdqu XMMWORD PTR [rdi],xmm0
<+260>:	vmovdqu XMMWORD PTR [rdi+rdx*1-0x10],xmm0
<+266>:	ret
<+267>:	nop    DWORD PTR [rax+rax*1+0x0]
<+272>:	vmovq  QWORD PTR [rdi],xmm0
<+276>:	vmovq  QWORD PTR [rdi+rdx*1-0x8],xmm0
<+282>:	ret
<+283>:	nop    DWORD PTR [rax+rax*1+0x0]
<+288>:	vmovd  DWORD PTR [rdi],xmm0
<+292>:	vmovd  DWORD PTR [rdi+rdx*1-0x4],xmm0
<+298>:	ret
<+299>:	nop    DWORD PTR [rax+rax*1+0x0]
<+304>:	mov    BYTE PTR [rdi],sil
<+307>:	mov    BYTE PTR [rdi+0x1],sil
<+311>:	mov    BYTE PTR [rdi+rdx*1-0x1],sil
<+316>:	ret
