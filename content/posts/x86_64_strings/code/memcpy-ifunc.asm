<+0>:	endbr64
<+4>:	mov    rcx,QWORD PTR [rip+0x13b0f5]     # 0x7ffff7fa0eb0
<+11>:	lea    rax,[rip+0x769e]        			# 0x7ffff7e6d460 <__memmove_erms>
<+18>:	mov    edx,DWORD PTR [rcx+0x1c4]
<+24>:	test   dh,0x90
<+27>:	jne    0x7ffff7e65e41 <memcpy@@GLIBC_2.14+145>
<+29>:	mov    esi,DWORD PTR [rcx+0xb8]
<+35>:	test   esi,0x10000
<+41>:	jne    0x7ffff7e65e48 <memcpy@@GLIBC_2.14+152>
<+43>:	test   dh,0x2
<+46>:	je     0x7ffff7e65e20 <memcpy@@GLIBC_2.14+112>
<+48>:	test   esi,esi
<+50>:	js     0x7ffff7e65e88 <memcpy@@GLIBC_2.14+216>
<+56>:	test   esi,0x800
<+62>:	je     0x7ffff7e65e10 <memcpy@@GLIBC_2.14+96>
<+64>:	and    esi,0x200
<+70>:	lea    rdx,[rip+0xc9d43]        # 0x7ffff7f2fb40 <__memmove_avx_unaligned_erms_rtm>
<+77>:	lea    rax,[rip+0xc9cac]        # 0x7ffff7f2fab0 <__memmove_avx_unaligned_rtm>
<+84>:	cmovne rax,rdx
<+88>:	ret
<+89>:	nop    DWORD PTR [rax+0x0]
<+96>:	test   dh,0x8
<+99>:	je     0x7ffff7e65ea8 <memcpy@@GLIBC_2.14+248>
<+105>:	nop    DWORD PTR [rax+0x0]
<+112>:	test   BYTE PTR [rcx+0x9d],0x2
<+119>:	jne    0x7ffff7e65e78 <memcpy@@GLIBC_2.14+200>
<+121>:	and    esi,0x200
<+127>:	lea    rax,[rip+0x774a]        # 0x7ffff7e6d580 <__memmove_sse2_unaligned_erms>
<+134>:	lea    rdx,[rip+0x76b3]        # 0x7ffff7e6d4f0 <memcpy@GLIBC_2.2.5>
<+141>:	cmove  rax,rdx
<+145>:	ret
<+146>:	nop    WORD PTR [rax+rax*1+0x0]
<+152>:	test   dh,0x20
<+155>:	jne    0x7ffff7e65ddb <memcpy@@GLIBC_2.14+43>
<+157>:	lea    rax,[rip+0xdc23c]        # 0x7ffff7f42090 <__memmove_avx512_no_vzeroupper>
<+164>:	test   esi,esi
<+166>:	jns    0x7ffff7e65e41 <memcpy@@GLIBC_2.14+145>
<+168>:	and    esi,0x200
<+174>:	lea    rdx,[rip+0xda19b]        # 0x7ffff7f40000 <__memmove_avx512_unaligned_erms>
<+181>:	lea    rax,[rip+0xda104]        # 0x7ffff7f3ff70 <__memmove_avx512_unaligned>
<+188>:	cmovne rax,rdx
<+192>:	ret
<+193>:	nop    DWORD PTR [rax+0x0]
<+200>:	and    edx,0x20
<+203>:	lea    rax,[rip+0xdcc3e]        # 0x7ffff7f42ac0 <__memmove_ssse3>
<+210>:	jne    0x7ffff7e65e29 <memcpy@@GLIBC_2.14+121>
<+212>:	ret
<+213>:	nop    DWORD PTR [rax]
<+216>:	and    esi,0x200
<+222>:	lea    rdx,[rip+0xd112b]        # 0x7ffff7f36fc0 <__memmove_evex_unaligned_erms>
<+229>:	lea    rax,[rip+0xd1094]        # 0x7ffff7f36f30 <__memmove_evex_unaligned>
<+236>:	cmovne rax,rdx
<+240>:	ret
<+241>:	nop    DWORD PTR [rax+0x0]
<+248>:	and    esi,0x200
<+254>:	lea    rdx,[rip+0xc124b]        # 0x7ffff7f27100 <__memmove_avx_unaligned_erms>
<+261>:	lea    rax,[rip+0xc11b4]        # 0x7ffff7f27070 <__memmove_avx_unaligned>
<+268>:	cmovne rax,rdx
<+272>:	ret
