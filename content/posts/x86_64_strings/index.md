+++
title = 'Write string.h functions using string instructions in asm x86-64'
date = 2025-05-13T04:23:35-03:00
draft = false
tags = [ 'asm', 'x86', 'x86_64', 'nasm', 'instructions']
toc = true
+++

## Introduction

The C standard library offers a bunch of functions (whose declarations can be found in the [string.h](https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/string.h.html) header) to manage NULL-terminated strings and arrays.
These are ones of the most used C functions, often implemented as builtin by the C compiler as they are crucial to the speed of programs.

On the other hand, the x86 architecture contains "string instructions", aimed at implementing operations on strings at the hardware level.
Moreover, the x86 architecture was incrementally [enhanced with SIMD instructions over the years](https://en.wikipedia.org/wiki/X86_SIMD_instruction_listings) which allows processing multiple bytes of data in one instruction.

In this article we'll inspect the implementation of `string.h` of the GNU standard library for x86, and see how it compares with a pure assembly implementation of these functions using string instructions and SIMD and try to explain the choices made by the GNU developers and to help you write better assembly.

## Disassembling a call to memcpy

One of the most popular C functions is `memcpy`.
It copies an array of bytes to another, which is a very common operation and makes its performance particularly important.

There are several ways you can perform this operation using x86 asm.
Let's see how it is implemented by gcc using this simple C program:
```c
#include <string.h>

#define BUF_LEN 1024
char a[BUF_LEN];
char b[BUF_LEN];

int main(void) {
  memcpy(b, a, BUF_LEN);
  return EXIT_SUCCESS;
}
```

We can observe the generated asm [by using godbolt](https://godbolt.org/z/9qKdvM8aE).

Or compile the code using gcc 14.2: `gcc -O1 -g -o string main.c`<br>
And then disassemble the executable using:
```
objdump --source-comment="; " --disassembler-color=extended --disassembler-options=intel --no-show-raw-insn --disassemble=main string
```

You should get this result:
```asm
0000000000401134 <main>:
; 
; int main(int argc, char *argv[]) {
;   memcpy(b, a, BUF_LEN);
  401134:	mov    esi,0x404440
  401139:	mov    edi,0x404040
  40113e:	mov    ecx,0x80
  401143:	rep movs QWORD PTR es:[rdi],QWORD PTR ds:[rsi]
;   return 0;
; }
  401146:	mov    eax,0x0
  40114b:	ret
```

The first surprising thing you notice is that the machine code does not contain any call to the memcpy function.
It has been replaced by 3 `mov` instructions preceding a mysterious `rep movsq` instruction.

`rep movsq` is one of the five string instructions defined in the ["Intel® 64 and IA-32 Architectures Software Developer’s Manual - Volume 1: Basic Architecture 5.1.8"](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html).

So it is time to learn more about these string instructions.

## The string instructions of x86

String instructions perform operations on array elements pointed by `rsi` (source register) and `rdi` (destination register).

| instruction | Description    | Effect on registers    |
|-------------|----------------|------------------------|
| movs        | Move string    | *(rdi++) = *(rsi++)    |
| cmps        | Compare string | cmp *(rsi++), *(rdi++) |
| scas        | Scan string    | cmp rax, *(rdi++)      |
| lods        | Load string    | rax = *(rsi++)         |
| stos        | Store string   | *(rdi++) = rax         |

Each of these instructions must have a suffix (b,w,d,q) indicating the type of elements pointed by rdi and rsi (byte, word, doubleword, quadword).

These instructions may also have a prefix indicating how to repeat themselves.

| prefix      | Description                                                     | Effect on registers                   |
|-------------|-----------------------------------------------------------------|---------------------------------------|
| rep         | Repeat while the ECX register not zero                          | for(; rcx != 0; rcx--)                |
| repe/repz   | Repeat while the ECX register not zero and the ZF flag is set   | for(; rcx != 0 && ZF == true; rcx--)  |
| repne/repnz | Repeat while the ECX register not zero and the ZF flag is clear | for(; rcx != 0 && ZF == false; rcx--) |

The `repe/repz` and `repne/repnz` prefixes are used only with the `cmps` and `scas` instructions (as they are the only ones modifying the RFLAGS register).

### The movs instruction

Now that we have learned more about the string instructions, we can break down the effect of the `rep movsq` instruction:
1. copy the quadword pointed by `rsi` to `rdi`
2. add 8 to `rsi` and `rdi` so that they point onto the next quadword
3. decrement `rcx` and repeat until `rcx == 0`

This is what we would expect memcpy to do except for one thing: bytes are not copied one by one, but in blocks of 8.
Here, as the byte size of our arrays is a multiple of 8, we can copy the source array as an array of quadwords. This will necessitate 8 times fewer operations than copying the array one byte at a time.

Let's change the size of the arrays to 1023 to see how the compiler will react when the array size is not a multiple of 8 anymore:
```asm
0000000000401134 <main>:
; 
; int main(int argc, char *argv[]) {
;   memcpy(b, a, BUF_LEN);
  401134:	mov    esi,0x404440
  401139:	mov    edi,0x404040
  40113e:	mov    ecx,0x7f
  401143:	rep movs QWORD PTR es:[rdi],QWORD PTR ds:[rsi]
  401146:	mov    eax,DWORD PTR [rsi]
  401148:	mov    DWORD PTR [rdi],eax
  40114a:	movzx  eax,WORD PTR [rip+0x36eb]        # 40483c <a+0x3fc>
  401151:	mov    WORD PTR [rip+0x32e4],ax        # 40443c <b+0x3fc>
  401158:	movzx  eax,BYTE PTR [rip+0x36df]        # 40483e <a+0x3fe>
  40115f:	mov    BYTE PTR [rip+0x32d9],al        # 40443e <b+0x3fe>
;   return 0;
; }
  401165:	mov    eax,0x0
  40116a:	ret
```
Instead of replacing the `rep movsq` by the `rep movsb` instruction, gcc preferred to stop the repetition of the `movsq` instruction 8 bytes earlier and add `mov` instructions to copy a doubleword, a word and a byte.

### The cmps instruction

The `cmps` instruction will compare the elements pointed by `rsi` and `rdi` and will set the flag accordingly.
As `cmps` will set the ZF flag, we can use the `repe/repz` and `repne/repnz` prefixes to, respectively, continue until the strings differ or stop when matching characters are encountered.

Let's write a basic `memcmp` function using this instruction:
```asm {hl_lines=["6-7"]}
; int memcmp_cmpsb(rdi: const void s1[.n], rsi: const void s2[.n], rdx: size_t n);
memcmp:
	mov rcx, rdx	; rcx = n
	xor eax, eax	; Set return value to zero
	xor edx, edx    ; rdx = 0
	repe cmpsb		; for(; rcx != 0 and ZF == true; rcx--)
					;	cmp *(rsi++), *(rdi++)
	setb al			; if(ZF == false and CF == true) al = 1
	seta dl			; if(ZF == false and CF == false) bl = 1
	sub eax, edx	; return al - dl
.exit
	ret
```

We use the `repe cmpsb` instruction to iterate over the strings s1 and s2 until two bytes differ.

When we exit the `repe cmpsb` instruction, the RFLAGS register is set according to the last byte comparison. We can then use the `set[cc]` instructions to set bytes al and dl according to the result comparison.

The same way the `memcpy` function copies groups of 8 bytes, we can use the `repe cmpsq` instruction to compare bytes by groups of 8 (or `cmpsd` for groups of 4 bytes on 32-bit architectures).

```nasm {hl_lines=["7-8"]}
; int memcmp_cmpsq_unaligned(rdi: const void s1[.n], rsi: const void s2[.n], rdx: size_t n);
memcmp_cmpsq_unaligned:
	lea rcx, [rdx + 0x7]	; rcx = n
	and rdx, (8 - 1)		; rdx = n % 8
	shr rcx, 3				; rcx = n / 8
	xor eax, eax			; rax = 0
	repe cmpsq				; for(; rcx != 0 and ZF == true; rcx += 8)
							;	cmp *(rsi++), *(rdi++)
    je .exit                ; If no difference was found return
	mov r8, [rdi - 0x8]	    ; Read the last (unaligned) quadword of s1
	mov r9, [rsi - 0x8]	    ; Read the last (unaligned) quadword of s2
    test rcx, rcx           ; if(rcx != 0)
    jnz .cmp                ;    goto .cmp
    shl rdx, 3              ; rdx = 8 * (8 - n % 8)
    jz .cmp                 ; if(rdx == 0) goto .cmp
    bzhi r8, r8, rdx        ; r8 <<= 8 * (8 - n % 8)
    bzhi r9, r9, rdx        ; r9 <<= 8 * (8 - n % 8)
.cmp:
	bswap r8				; Convert r8 to big-endian for lexical comparison
	bswap r9				; Convert r9 to big-endian for lexical comparison
	cmp r8, r9				; Lexical comparison of quadwords
	seta al					; if (r8 > r9) al = 1
	setb cl					; if (r8 < r9) cl = 1
	sub eax, ecx			; return eax - ecx
.exit:
	ret
```

To get the result of the comparison, we need to compare the last two quadwords. However, on little-endian systems, the lowest significant byte will be the first one and we want to compare the byte in lexical order. Hence, the need to convert the quadword to big-endian using the `bswap` instruction.

{{< admonition tip "Zero High Bits Starting with Specified Bit Position" >}}
The instruction `bzhi` is useful when you need to mask out the higher bits of a register.
Here when comparing the last quadword we need to erase all bits in `r8` and `r9` which aren't "valid" (i.e. which are not part of the input arrays).

You can find documentation about this instruction [here](https://www.felixcloutier.com/x86/bzhi).
{{< /admonition >}}

{{< admonition warning >}}
This function should only be used for blocks of memory of size multiple of 8 with 8 bytes alignment.

For production use refer to the Benchmarking section.
{{< /admonition >}}

### The scas instruction

The `scas` instruction will compare the content of `rax` with the element pointed by `rdi` and set the flag accordingly.
We can use it in a similar way to what we did for `cmps` taking advantage of the `repe/repz` and `repne/repnz` prefixes.

Let's write a simple `strlen` function using the `scasb` instruction:

```asm {hl_lines=["4-5"]}
; size_t strlen(rdi: const char *s)
strlen:
	mov rcx, -1
	repnz scasb		; for(; rcx != 0 and ZF == false; rcx--)
					;	cmp rax, *(rdi++)
	not rcx			; before this insn rcx = - (len(rdi) + 2)
	dec rcx			; after this insn rcx = ~(- (len(rdi) + 2)) - 1
					;                     = -(- (len(rdi) + 2)) - 1 - 1
					;                     = len(rdi)
	xchg rax, rcx	; rax = len(rdi)
	ret
```

{{< admonition tip >}}
The instruction sequence used here to calculate the length of a text string is a well-known technique that dates back to the 8086 CPU.
{{< /admonition >}}

{{< admonition warning >}}
Don't use this function for production code as it can only compare bytes one by one.

For production always prefer loop alternative to compare groups of bytes using the largest registers (see the Benchmarking section).
{{< /admonition >}}

### The lods instruction

The lods instruction will load to the `rax` register the element pointed to by `rsi` and increment `rsi` to point to the next element.
As this instruction does nothing else than a move on a register, **it is never used with a prefix** (the value would be overwritten for each repetition).

It can, however, be used to examine a string, for instance to find a character:
```asm {hl_lines=[5]}
; char* strchr_lodsb(rdi: const char* s, rsi: int c)
strchr_lodsb:
    xchg rdi, rsi       ; rdi = c, rsi = s
.loop:
    lodsb               ; al = *(rsi++)
    cmp dil, al         ; if(c == al)
    je .end             ;    goto .end
    test al, al         ; if(al != 0)
    jnz .loop           ;    goto .loop
    xor rax, rax        ; return 0
    ret
.end:
    lea rax, [rsi - 1]  ; return rsi - 1
    ret
```

{{< admonition warning >}}
For production code always prefer to load data using the largest registers (see the Benchmarking section).
{{< /admonition >}}

### The stos instruction

The stos instruction will write the content of the rax register to the element pointed by rdi and increment rdi to point to the next element.

Note that according to the ["Intel® 64 and IA-32 Architectures Software Developer’s Manual - Volume 1: Basic Architecture 7.3.9.2"](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html):
> a REP STOS instruction is the fastest way to initialize a large block of memory.

Actually, this is the way gcc will implement a memset when it knows the size and alignment of the string:
{{% columns %}}
```c
#include <string.h>

#define BUF_LEN 1024

char a[BUF_LEN];

int main(int argc, char *argv[]) {
  memset(a, 1, BUF_LEN);
  return 0;
}
```
<--->
```asm
000000000040115a <main>:
; 
; int main(int argc, char *argv[]) {
;   memset(a, 1, BUF_LEN);
  40115a:	mov    edx,0x404460
  40115f:	mov    ecx,0x80
  401164:	movabs rax,0x101010101010101
  40116e:	mov    rdi,rdx
  401171:	rep stos QWORD PTR es:[rdi],rax
;   return 0;
; }
  401174:	mov    eax,0x0
  401179:	ret
```
{{% /columns %}}

{{< admonition tip >}}
Always use the `rep movsq` instruction to initialize large blocks of memory.

For small blocks of memory use unrolled loop and the largest registers.
{{< /admonition >}}

## Let's turn around

### The direction flag

It wouldn't be as much fun if we couldn't make it backward :smile: 

On x86, the flag register (RFLAGS) has a **direction flag**, `RFFLAGS.DF`, which controls the direction of the string operations.
This flag can be set and cleared respectively using the `std` and `cld` instructions.

```asm
std ; SeT Direction
; Here DF = 1, rdi and rsi are decremented
cld ; CLear Direction
; Here DF = 0, rdi and rsi are incremented
```


Here you have a detailed view of the RFLAGS register:
{{< admonition info "The RFLAGS register" false >}}
On Intel64, the upper 32 bits of the RFLAGS register are reserved and the lower 32-bits are the same as the EFLAGS register of 32-bit architectures.

{{< figure title="The EFLAGS register on Intel64 and IA-32 architectures" src="images/eflags.png" >}}
{{< /admonition >}}

### Saving and restoring RFLAGS

When you write an assembly subroutine using string instructions you should always:
- save the state of the RFLAGS register
- set or clear RFLAGS.DF
- do your work
- restore the RFLAGS register

This way, your subroutine will work independently of the state of the direction flag and won't break other routines relying on this flag.

To do so, you can push RFLAGS to the stack using the `pushfq` instruction and restore it using the `popfq` instruction.

However, the [System V Application Binary Interface for AMD64](https://gitlab.com/x86-psABIs/x86-64-ABI/-/jobs/artifacts/master/raw/x86-64-ABI/abi.pdf?job=build) state that:
> The direction flag DF in the %rFLAGS register must be clear (set to “forward” direction) on function entry and return.

So, if you're writing code targeting the System V ABI, you may assume that the direction flag is clear and ensure that you keep it clear when leaving your functions.

### An example with strrchr

We can code a simple version of strrchr ( which looks for the last occurrence of a character in a string) based on our strchr function by simply setting `rdi = s + len(s) + 1` and by setting the direction flag.

```asm {hl_lines=[11, "16-17", 22]}
; char *strrchr(rdi: const char *s, esi: int c);
strchr:
	push rdi		; push 1st arg on the stack
	push rsi		; push 2nd arg on the stack
	
	; rcx = strlen(rdi) + 1
	call strlen
	mov rcx, rax
	add rcx, 1

	std				; RFLAGS.DF = 1
	pop rax			; rax = c
	pop rdi			; rdi = s
	add rdi, rcx	; rdi = s + len(s) + 1
	xor rdx, rdx 	; rdx = 0
	repne scasb		; for(; rcx != 0 and ZF == false; rcx--)
					;	 cmp al, *(rdi--)
	jne .exit
	mov rdx, rdi	; if(ZF == true)
	sub rdx, 1		;	 rdx = rdi - 1
.exit:
	cld				; RFLAGS.DF = 0
	mov rax, rdx 	; return rdx
	ret
```

We use the System V ABI for our functions, so there is no need to save the RFLAGS register, but we make sure to clear the direction flag before returning from the function.


{{< admonition warning >}}
You should avoid setting the direction flag, especially when using `movs` and `stos` instructions, because, as we'll see in the last part, it may disable a whole class of optimization known as "fast-string operations".
{{< /admonition >}}

## Vectorized string instructions

Vectorized string instructions are quite intricate and should not be used in most cases.

If you're in to discover one of the strangest instructions of x86 you can continue, but if you prefer to watch graphs, you can skip to the benchmarking section.

### Implicit ? Explicit ? Index ? Mask ?

SSE4.2 introduced another set of 4 instructions: The vectorized string instructions.

| instruction | Description                                          |
|-------------|------------------------------------------------------|
| pcmpestri   | Packed Compare Implicit Length Strings, Return Index |
| pcmpistri   | Packed Compare Explicit Length Strings, Return Index |
| pcmpestrm   | Packed Compare Implicit Length Strings, Return Mask  |
| pcmpeistrm  | Packed Compare Explicit Length Strings, Return Mask  |

{{< admonition >}}
Adding a v before any of these instructions makes it VEX.128 encoded and will zero out the upper 128 bits of the ymm registers, which may avoid some performance issues in case you forgot a vzeroupper.
{{< /admonition >}}

A vectorized string instruction takes three parameters:
```asm
pcmpestri xmm1, xmm2/m128, imm8
```
The first and second arguments of the instructions are meant to contain the string fragments to be compared.

The fragments are considered valid until:
- The first null byte for the **"Implicit Length"** versions
- The length contained in `eax` (for `xmm1`) and `edx` (for `xmm2`) for the **"Explicit Length"** versions

The result is:
- The index of the first match, stored in the `ecx` register for the **"Index"** version.
- A mask of bits/bytes/words (depending on imm8), stored in the `xmm0` register for the **"Mask"** version.

Other information is carried out by the RFLAGS register:

| Flag     | Information            			|
|----------|------------------------------------|
| Carry    | Result is non-zero     			|
| Sign     | The first string ends  			|
| Zero     | The second string ends 			|
| Overflow | Least Significant Bit of result    |

The Parity and Adjust flags are reset.

### The imm8 control byte

But this doesn't tell us which comparisons these instructions can perform.
Well, they can perform 4 basic operations:
- **Find characters from a set:** Finds which of the bytes in the second vector operand belong to the set defined by the bytes in the first vector operand, comparing all 256 possible combinations in one operation.
- **Find characters in a range:** Finds which of the bytes in the second vector operand are within the range defined by the first vector operand.
- **Compare strings:** Determine if the two strings are identical.
- **Substring search:** Finds all occurrences of a substring defined by the first vector
operand in the second vector operand.

The operation performed by the vectorized string instruction is controlled by the value of the `imm8` byte:

| imm8      | Description                                                                            |
|-----------|----------------------------------------------------------------------------------------|
| ·······0b | 128-bit sources treated as 16 packed bytes.                                            |
| ·······1b | 128-bit sources treated as 8 packed words.                                             |
| ······0·b | Packed bytes/words are unsigned.                                                       |
| ······1·b | Packed bytes/words are signed.                                                         |
| ····00··b | Mode is equal any.                                                                     |
| ····01··b | Mode is ranges.                                                                        |
| ····10··b | Mode is equal each.                                                                    |
| ····11··b | Mode is equal ordered.                                                                 |
| ···0····b | IntRes1 is unmodified.                                                                 |
| ···1····b | IntRes1 is negated (1’s complement).                                                   |
| ··0·····b | Negation of IntRes1 is for all 16 (8) bits.                                            |
| ··1·····b | Negation of IntRes1 is masked by reg/mem validity.                                     |
| ·0······b | **Index**: Index of the least significant, set, bit is used (regardless of corresponding input element validity).<br>**Mask**: IntRes2 is returned in the least significant bits of XMM0.                                               |
| ·1······b | **Index**: Index of the most significant, set, bit is used (regardless of corresponding input element validity).<br>**Mask**: Each bit of IntRes2 is expanded to byte/word.                                                        |

The MSB of imm8 has no defined effect and should be 0.

This means that if we want to compare xmm1 and xmm2 for byte equality and get the index of the first non-matching byte, we have to set `imm8 = 0b0001'1000`

We can define some macro so you do not have to remind of this:
```nasm
PACKED_UBYTE 			equ	0b00
PACKED_UWORD 			equ	0b01
PACKED_BYTE 			equ	0b10
PACKED_WORD 			equ	0b11
CMP_STR_EQU_ANY 		equ	(0b00 << 2)
CMP_STR_EQU_RANGES 		equ	(0b01 << 2)
CMP_STR_EQU_EACH 		equ	(0b10 << 2)
CMP_STR_EQU_ORDERED		equ	(0b11 << 2)
CMP_STR_INV_ALL			equ	(0b01 << 4)
CMP_STR_INV_VALID_ONLY	equ (0b11 << 4)
CMP_STRI_FIND_LSB_SET	equ (0b00 << 6)
CMP_STRI_FIND_MSB_SET	equ (0b01 << 6)
CMP_STRM_BIT_MASK		equ (0b00 << 6)
CMP_STRM_BYTE_MASK	    equ (0b01 << 6)
```

From these definitions we can create the imm8 flag for a `vpcmpxstrx` instruction with bitwise or.

For instance, a flag for the `vpcmpestri` instruction to get the index of the first differing byte:
```nasm
BYTEWISE_CMP equ (PACKED_UBYTE | CMP_STR_EQU_EACH | CMP_STR_INV_VALID_ONLY | CMP_STRI_FIND_LSB_SET)
```

### A vectorized memcmp version

Now that we know how to use the `vpcmpestri`  instruction and that we defined the imm8 flag to make a bytewise comparison of the content of AVX registers, we can write a version of `memcmp` using the vectorized string instructions.

{{% code file="code/string-instructions/memcmp/memcmp.asm" language="asm" start=219 limit=36 %}}

## Benchmarking our string instructions


### Benchmark 1: memcpy

At the beginning of the previous part, we disassembled a call to memcpy to see that it had been inlined with a `rep movsq` instruction by gcc.

The compiler is able to realize this optimization because the alignment and the size of both arrays are compile-time known.
Let's add an indirection to the `memcpy` call so that the compiler can't rely on this information anymore.


{{% columns %}}
```c
#include <string.h>

#define BUF_LEN 1023

char a[BUF_LEN];
char b[BUF_LEN];

void *copy(void *restrict dest, const void *restrict src, size_t n) {
  return memcpy(dest, src, n);
}

int main(int argc, char *argv[]) {
  copy(b, a, BUF_LEN);
  return 0;
}
```
<--->
```sh 
objdump --source-comment="; " --disassembler-color=extended --disassembler-option=intel-mnemonic --no-show-raw-insn --disassemble=copy string
```
```asm {hl_lines=[10]}
0000000000401126 <copy>:
; #define BUF_LEN 1023
; 
; char a[BUF_LEN];
; char b[BUF_LEN];
; 
; void *copy(void *restrict dest, const void *restrict src, size_t n) {
  401126:	sub    rsp,0x8
;   return memcpy(dest, src, n);
  40112a:	call   401030 <memcpy@plt>
; }
  40112f:	add    rsp,0x8
  401133:	ret
```
{{% /columns %}}

Another situation in which gcc will produce a proper call to the libc memcpy function is when the target architecture has vector extensions. In this situation, the compiler is aware that memcpy implementation will use vector instructions which may be faster than `rep movs`.
You can test it by adding the flag `-march=corei7` to your gcc command to see what code gcc will produce for an architecture with vector extensions (you can see this [in godbolt](https://godbolt.org/#g:!((g:!((g:!((g:!((h:codeEditor,i:(filename:'1',fontScale:18,fontUsePx:'0',j:1,lang:___c,selection:(endColumn:2,endLineNumber:10,positionColumn:2,positionLineNumber:10,selectionStartColumn:2,selectionStartLineNumber:10,startColumn:2,startLineNumber:10),source:'%23include+%3Cstring.h%3E%0A%0A%23define+BUF_LEN+1024%0Achar+a%5BBUF_LEN%5D%3B%0Achar+b%5BBUF_LEN%5D%3B%0A%0Aint+main(void)+%7B%0A++memcpy(b,+a,+BUF_LEN)%3B%0A++return+0%3B%0A%7D'),l:'5',n:'0',o:'C+source+%231',t:'0')),k:57.075553476053145,l:'4',m:50,n:'0',o:'',s:0,t:'0'),(g:!((h:output,i:(editorid:1,fontScale:18,fontUsePx:'0',j:1,wrap:'1'),l:'5',n:'0',o:'Output+of+x86-64+gcc+14.2+(Compiler+%231)',t:'0')),header:(),l:'4',m:50,n:'0',o:'',s:0,t:'0')),k:58.79910913605523,l:'3',n:'0',o:'',t:'0'),(g:!((g:!((h:compiler,i:(compiler:cg142,filters:(b:'0',binary:'1',binaryObject:'1',commentOnly:'0',debugCalls:'1',demangle:'0',directives:'0',execute:'0',intel:'0',libraryCode:'0',trim:'1',verboseDemangling:'0'),flagsViewOpen:'1',fontScale:14,fontUsePx:'0',j:1,lang:___c,libs:!(),options:'-march%3Dcorei7',overrides:!(),selection:(endColumn:1,endLineNumber:1,positionColumn:1,positionLineNumber:1,selectionStartColumn:1,selectionStartLineNumber:1,startColumn:1,startLineNumber:1),source:1),l:'5',n:'0',o:'+x86-64+gcc+14.2+(Editor+%231)',t:'0')),k:46.82444577591372,l:'4',m:60.76707291803545,n:'0',o:'',s:0,t:'0'),(g:!((h:tool,i:(args:'',argsPanelShown:'1',compilerName:'x86-64+clang+13.0.0',editorid:1,fontScale:14,fontUsePx:'0',j:1,monacoEditorHasBeenAutoOpened:'1',monacoEditorOpen:'1',monacoStdin:'1',stdin:'',stdinPanelShown:'1',toolId:clangtidytrunk,wrap:'1'),l:'5',n:'0',o:'clang-tidy+(trunk)+x86-64+gcc+14.2+(Editor+%231,+Compiler+%231)',t:'0')),l:'4',m:39.232927081964554,n:'0',o:'',s:0,t:'0')),k:41.20089086394483,l:'3',n:'0',o:'',t:'0')),l:'2',n:'0',o:'',t:'0')),version:4)).

We can now compare different assembly versions of memcpy to its glibc implementation.

I wrote 8 version of a program copying 4MiB of memory using: an unoptimized for loop, the glibc memcpy function, `rep movsb`, `rep movsq`, the SSE2 extension and the AVX and AVX2 extensions.
I also wrote a backward copy to compare the speed of `rep movsb` when RFLAGS.DF is set.

{{< tabs >}}
{{< tab "generic" >}}
{{% code file="code/string-instructions/memcpy/memcpy.c" language="c" %}}
{{< /tab >}}
{{< tab "movsb" >}}
{{% code file="code/string-instructions/memcpy/memcpy.asm" language="asm" start=11 limit=7 %}}
{{< /tab >}}
{{< tab "movsb reversed" >}}
{{% code file="code/string-instructions/memcpy/memcpy.asm" language="asm" start=19 limit=12 %}}
{{< /tab >}}
{{< tab "movb" >}}
{{% code file="code/string-instructions/memcpy/memcpy.asm" language="asm" start=32 limit=14 %}}
{{< /tab >}}
{{< tab "movsq" >}}
{{% code file="code/string-instructions/memcpy/memcpy.asm" language="asm" start=47 limit=49 %}}
{{< /tab >}}
{{< tab "movq" >}}
{{% code file="code/string-instructions/memcpy/memcpy.asm" language="asm" start=97 limit=23 %}}
{{< /tab >}}
{{< tab "avx" >}}
{{% code file="code/string-instructions/memcpy/memcpy.asm" language="asm" start=121 limit=37 %}}
{{< /tab >}}
{{< tab "avx2" >}}
{{% code file="code/string-instructions/memcpy/memcpy.asm" language="asm" start=159 %}}
{{< /tab >}}
{{< /tabs >}}

{{< admonition >}}
Note that for the "dummy version" i forced the optimization level to -O1.

Otherwise, gcc would replace the call to our custom copy function with a call to memcpy (when -O2) or write a vectorized loop using SSE2 extension (when -O3).
You can [check this in godbolt](https://godbolt.org/#g:!((g:!((g:!((g:!((h:codeEditor,i:(filename:'1',fontScale:18,fontUsePx:'0',j:1,lang:___c,selection:(endColumn:2,endLineNumber:8,positionColumn:2,positionLineNumber:8,selectionStartColumn:2,selectionStartLineNumber:8,startColumn:2,startLineNumber:8),source:'%23include+%3Cstddef.h%3E%0A%0Avoid+*memcpy_dummy(void+*restrict+dst,+const+void+*restrict+src,+size_t+n)+%7B%0A++void+*const+ret+%3D+dst%3B%0A++for+(int+i+%3D+0%3B+i+%3C+n%3B+i%2B%2B)%0A++++*((char+*)dst%2B%2B)+%3D+*((char+*)src%2B%2B)%3B%0A++return+ret%3B%0A%7D'),l:'5',n:'0',o:'C+source+%231',t:'0')),k:57.075553476053145,l:'4',m:50,n:'0',o:'',s:0,t:'0'),(g:!((h:output,i:(editorid:1,fontScale:18,fontUsePx:'0',j:1,wrap:'1'),l:'5',n:'0',o:'Output+of+x86-64+gcc+14.2+(Compiler+%231)',t:'0')),header:(),l:'4',m:50,n:'0',o:'',s:0,t:'0')),k:58.79910913605523,l:'3',n:'0',o:'',t:'0'),(g:!((g:!((h:compiler,i:(compiler:cg142,filters:(b:'0',binary:'1',binaryObject:'1',commentOnly:'0',debugCalls:'1',demangle:'0',directives:'0',execute:'0',intel:'0',libraryCode:'0',trim:'1',verboseDemangling:'0'),flagsViewOpen:'1',fontScale:14,fontUsePx:'0',j:1,lang:___c,libs:!(),options:'-O2',overrides:!(),selection:(endColumn:1,endLineNumber:1,positionColumn:1,positionLineNumber:1,selectionStartColumn:1,selectionStartLineNumber:1,startColumn:1,startLineNumber:1),source:1),l:'5',n:'0',o:'+x86-64+gcc+14.2+(Editor+%231)',t:'0')),k:46.82444577591372,l:'4',m:60.76707291803545,n:'0',o:'',s:0,t:'0'),(g:!((h:tool,i:(args:'',argsPanelShown:'1',compilerName:'x86-64+clang+13.0.0',editorid:1,fontScale:14,fontUsePx:'0',j:1,monacoEditorHasBeenAutoOpened:'1',monacoEditorOpen:'1',monacoStdin:'1',stdin:'',stdinPanelShown:'1',toolId:clangtidytrunk,wrap:'1'),l:'5',n:'0',o:'clang-tidy+(trunk)+x86-64+gcc+14.2+(Editor+%231,+Compiler+%231)',t:'0')),l:'4',m:39.232927081964554,n:'0',o:'',s:0,t:'0')),k:41.20089086394483,l:'3',n:'0',o:'',t:'0')),l:'2',n:'0',o:'',t:'0')),version:4) by changing the level of optimization.

This means that when writing casual C code with -O2 or -O3 level optimization, a simple for loop will often be identical or more efficient than a call to memcpy.
{{< /admonition >}}

Here are the results I got on my "13th Gen Intel(R) Core(TM) i7-1355U (12) @ 5.00 GHz" using the [b63 micro-benchmarking tool](https://github.com/okuvshynov/b63/tree/master):


{{< figure src="images/benchmark-memcpy.svg" >}}

On my hardware, all the implementations are reasonably close, the slowest by far being the backward copy (setting RFLAGS.DF), the for loop and the `movb` version (which copy only one byte at a time), but you may have different results depending on your CPU.

This is an example of string instructions being nearly as fast as copying using the greatest registers of the processor.

According to ["Optimizing subroutines in assembly language"](https://www.agner.org/optimize/):
> REP MOVSD and REP STOSD are quite fast if the repeat count is not too small. The largest word size (DWORD in 32-bit mode, QWORD in 64-bit mode) is preferred. Both source and destination should be aligned by the word size or better. In many cases, however, it is faster to use vector registers. Moving data in the largest available registers is faster than REP MOVSD and REP STOSD in most cases, especially on older processors.

The speed of `rep movs` and `rep stos` relies heavily on fast-string operations, which need certain processor-dependent conditions to be met.

The "Intel® 64 and IA-32 Architectures Software Developer’s Manual - Volume 1: Basic Architecture 7.3.9.3" defines **fast-string operations**:
> To improve performance, more recent processors support modifications to the processor’s operation during the string store operations initiated with the MOVS, MOVSB, STOS, and STOSB instructions. This optimized operation, called fast-string operation, is used when the execution of one of those instructions meets certain initial conditions (see below). Instructions using fast-string operation effectively operate on the string in groups that may include multiple elements of the native data size (byte, word, doubleword, or quadword).

The general conditions for fast-string operations to happen are:
- The count of bytes must be high
- Both source and destination must be aligned (on the size of the greatest registers you have)
- The direction must be forward
- The distance between source and destination must be at least the cache line size
- The memory type for both source and destination must be either write-back or write-combining (you can normally assume the latter condition is met).

### So how does the glibc implement the memcpy function ?

We have two ways to know how the memcpy works underneath. The first one is looking at the source code of the glibc, the second one is to dump the disassembled machine code in gdb.

We can get the code of glibc v.2.40, the GNU implementation of lib c, and verify its signature using these commands:
```sh
wget https://ftp.gnu.org/gnu/glibc/glibc-2.40.tar.xz https://ftp.gnu.org/gnu/glibc/glibc-2.40.tar.xz.sig
gpg --recv-keys 7273542B39962DF7B299931416792B4EA25340F8
gpg --verify glibc-2.40.tar.xz.sig glibc-2.40.tar.xz
tar xvf glibc-2.40.tar.xz
```

You can find the implementation of the memcpy function in the **string/memcpy.c** file:
{{% code file="code/glibc-2.40/string/memcpy.c" language="c" %}}

{{< admonition info >}}
The PAGE_COPY_FWD_MAYBE macro is empty for all architectures except the mach architecture, so you can ignore it.
{{< /admonition >}}

The included **sysdeps/generic/memcopy.h** file contains the definitions of the macro used by memcpy and an explanation of its internals:

```c
/* The strategy of the memory functions is:

     1. Copy bytes until the destination pointer is aligned.

     2. Copy words in unrolled loops.  If the source and destination
     are not aligned in the same way, use word memory operations,
     but shift and merge two read words before writing.

     3. Copy the few remaining bytes.

   This is fast on processors that have at least 10 registers for
   allocation by GCC, and that can access memory at reg+const in one
   instruction.

   I made an "exhaustive" test of this memmove when I wrote it,
   exhaustive in the sense that I tried all alignment and length
   combinations, with and without overlap.  */
```

For i386 (ie x86_32) architectures, the **sysdeps/i386/memcopy.h** macro definitions will replace the generic ones defining the WORD_COPY_FWD and BYTE_COPY_FWD macros in terms of string instructions:
```c {hl_lines="6-9 21-24"}
#undef	BYTE_COPY_FWD
#define BYTE_COPY_FWD(dst_bp, src_bp, nbytes)                               \
  do {                                                                      \
    int __d0;                                                               \
    asm volatile(/* Clear the direction flag, so copying goes forward.  */  \
		 "cld\n"                                                            \
		 /* Copy bytes.  */                                                 \
		 "rep\n"                                                            \
		 "movsb" :                                                          \
		 "=D" (dst_bp), "=S" (src_bp), "=c" (__d0) :                        \
		 "0" (dst_bp), "1" (src_bp), "2" (nbytes) :                         \
		 "memory");                                                         \
  } while (0)

#undef	WORD_COPY_FWD
#define WORD_COPY_FWD(dst_bp, src_bp, nbytes_left, nbytes)                      \
  do                                                                            \
    {                                                                           \
      int __d0;                                                                 \
      asm volatile(/* Clear the direction flag, so copying goes forward.  */    \
		   "cld\n"                                                              \
		   /* Copy longwords.  */                                               \
		   "rep\n"                                                              \
		   "movsl" :                                                            \
 		   "=D" (dst_bp), "=S" (src_bp), "=c" (__d0) :                          \
		   "0" (dst_bp), "1" (src_bp), "2" ((nbytes) / 4) :                     \
		   "memory");                                                           \
      (nbytes_left) = (nbytes) % 4;                                             \
    } while (0)
```

For x86_64, the implementation is much more intricate as it requires to choose a `memcpy` implementation according to the vector extensions available. The **sysdeps/x86_64/multiarch/memcpy.c** file includes the **ifunc-memmove.h** which defines a IFUNC_SELECTOR function which returns a pointer to a function according to the caracteristics of the CPU running the program:

_sysdeps/x86_64/multiarch/memcpy.c_
{{% code file="code/glibc-2.40/sysdeps/x86_64/multiarch/memcpy.c" language="c" options={hl_lines="20-30"} %}}

_sysdeps/x86_64/multiarch/ifunc-memmove.h_
{{% code file="code/glibc-2.40/sysdeps/x86_64/multiarch/ifunc-memmove.h" language="c" %}}

You can learn more about **indirect functions** in glibc [in this blog post](https://jasoncc.github.io/gnu_gcc_glibc/gnu-ifunc.html).
What you need to understand here is that the glibc will be able to determine at runtime what function should be called when calling `memcpy` based on your hardware capabilities.

Let's use gdb to find out how our call to `memcpy` will be resolved at runtime.

Run the following commands in **gdb** to run until the first call to `memcpy`:
```gdb
b main
run
b memcpy
c
disassemble
```

You should get something like this:
{{% code file="code/memcpy-ifunc.asm" language="asm" options={hl_lines=[3,17,18,28,29,35,39,40,45,50,51,56,57]} %}}

Instead of breaking inside the code of the `memcpy` function, the glibc runtime called the `IFUNC_SELECTOR`.
This function will return the pointer that will be used for later calls of the memcpy function.

Let's now hit the `finish` gdb command to see what the selector returns in `rax`.

{{< figure title="Return value of IFUNC_SELECTOR" src="images/gdb-ifunc.png">}}

The `IFUNC_SELECTOR` returned a pointer to `__memmove_avx_unaligned_erms` this function is defined in _sysdeps/x86_64/multiarch/memmove-avx-unaligned-erms.S_ and _sysdeps/x86_64/multiarch/memmove-vec-unaligned-erms.S_ with **handwritten assembly**.

But it's quite difficult to figure out the execution flow while reading this, so let's put a breakpoint on this symbol, hit continue, and run this function step by step.

{{< admonition >}}
The "erms" parts of `__memmove_avx_unaligned_erms` stands for "Enhanced Rep Movsb/Stosb" which is what we called earlier **fast-string operation**.

It is named this way in the ["Intel® 64 and IA-32 Architectures Optimization Reference Manual: Volume 1"](https://cdrdv2-public.intel.com/814198/248966-Optimization-Reference-Manual-V1-050.pdf) section 3.7.6 and correspond to a byte in `cpuid` which indicates that this feature is available.
{{< /admonition >}}

I highlighted the code reached during the execution of the function:

*__memmove_avx_unaligned_erms*
{{% code file="code/__memmove_avx_unaligned_erms.asm" language="asm" options={hl_lines=["1-7","53-54","166-188"]} %}}

*Remember: We are copying 4Mib of data so rdx = 0x400000.*

The `__memmove_avx_unaligned_erms` performs several test over the `rdx` register which contains the size of our buffer (3rd argument for System V ABI).

Here is each test performed and the result of the conditional jump:
| Condition                                             | Taken ?            |
| :---                                                  | :---:              |
| size is greater than 32 bytes                         | :white_check_mark: |
| size is greater than 64 bytes                         | :white_check_mark: |
| size is greater than `__x86_rep_movsb_threshold`        | :white_check_mark: |
| dest doesn't start in src                             | :white_check_mark: |
| size is greater than `__x86_rep_movsb_stop_threshold`   | :x:                |
| LSB(`__x86_string_control`) == 0                        | :x:                |
| dest - src is greater than `2^32-64`                    | :x:                |

:white_check_mark: = taken :x: = not taken

We can check the value of the thresholds and of the "string control" constant.

{{< figure src="images/gdb-memcpy-constants.png" title="Value of the comparison constants in gdb">}}

And after aligning `rsi` and `rdi` on 64 bytes, we call our beloved `rep movsb`. :smile:

But note that this is very dependent on our memory layout:
- with size >= 0x700000, `memcpy` would copy the buffer in blocks of 2^14 bytes using all the ymm registers and prefetching, then terminate to copy by blocks of 128 bytes until the end.
- with 32 < size < 64, it would be a simple 64-byte copy using ymm0 and ymm1
- etc...

We can find an explanation for the `__x86_rep_movsb_threshold` value in [this commit message](https://forge.sourceware.org/glibc/glibc-mirror/commit/6e02b3e9327b7dbb063958d2b124b64fcb4bbe3f):

> In the process of optimizing memcpy for AMD machines, we have found the
> vector move operations are outperforming enhanced REP MOVSB for data
> transfers above the L2 cache size on Zen3 architectures.
> To handle this use case, we are adding an upper bound parameter on
> enhanced REP MOVSB:'__x86_rep_movsb_stop_threshold'.
>
> As per large-bench results, we are configuring this parameter to the
> L2 cache size for AMD machines and applicable from Zen3 architecture
> supporting the ERMS feature.
> For architectures other than AMD, it is the computed value of
> non-temporal threshold parameter.

Note that since this commit _sysdeps/x86/dl-cacheinfo.h_ has been changed and `__x86_rep_movsb_stop_threshold` is equal to `__x86_shared_non_temporal_threshold` for all x86 architectures nowadays.

You can read all the details of the choices made for the `__x86_shared_non_temporal_threshold` tunable in _sysdeps/x86/dl-cacheinfo.h_:
{{< code file="code/glibc-2.40/sysdeps/x86/dl-cacheinfo.h" language="c" start=911 limit=51 >}}

When the block to copy is greater than `__x86_shared_non_temporal_threshold`, the `__memmove_avx_unaligned_erms` implementation uses an unrolled loop of AVX2 registers with prefetching and **non-temporal stores** using the `vmovntdq` (vex mov non-temporal double quadword).

The ["Intel® 64 and IA-32 Architectures Optimization Reference Manual: Volume 1"](https://cdrdv2-public.intel.com/814198/248966-Optimization-Reference-Manual-V1-050.pdf) section 9.6.1 gives hint on when to use non-temporal stores:

> Use non-temporal stores in the cases when the data to be stored is:
> - Write-once (non-temporal).
> - Too large and thus cause cache thrashing.
>
> Non-temporal stores do not invoke a cache line allocation, which means they are not write-allocate. As a result,
> caches are not polluted and no dirty writeback is generated to compete with useful data bandwidth. Without using
> non-temporal stores, bus bandwidth will suffer when caches start to be thrashed because of dirty writebacks.

The memcpy function of the glibc is a piece of code tailored to be the most efficient and adaptable to every hardware and memory layout possible.

### Benchmark 2: memset

As you can see [with godbolt](https://godbolt.org/#g:!((g:!((g:!((g:!((h:codeEditor,i:(filename:'1',fontScale:18,fontUsePx:'0',j:1,lang:___c,selection:(endColumn:11,endLineNumber:6,positionColumn:11,positionLineNumber:6,selectionStartColumn:11,selectionStartLineNumber:6,startColumn:11,startLineNumber:6),source:'%23include+%3Cstring.h%3E%0A%0A%23define+BUF_LEN+(1+%3C%3C+13)%0Achar+a%5BBUF_LEN%5D%3B%0A%0Aint+value%3B%0A%0Aint+main(void)+%7B%0A++memset(a,+value,+BUF_LEN)%3B%0A++return+0%3B%0A%7D'),l:'5',n:'0',o:'C+source+%231',t:'0')),k:57.075553476053145,l:'4',m:50,n:'0',o:'',s:0,t:'0'),(g:!((h:output,i:(editorid:1,fontScale:18,fontUsePx:'0',j:1,wrap:'1'),l:'5',n:'0',o:'Output+of+x86-64+gcc+14.2+(Compiler+%231)',t:'0')),header:(),l:'4',m:50,n:'0',o:'',s:0,t:'0')),k:62.036553524804205,l:'3',n:'0',o:'',t:'0'),(g:!((g:!((h:compiler,i:(compiler:cg142,filters:(b:'0',binary:'1',binaryObject:'1',commentOnly:'0',debugCalls:'1',demangle:'0',directives:'0',execute:'0',intel:'0',libraryCode:'0',trim:'1',verboseDemangling:'0'),flagsViewOpen:'1',fontScale:14,fontUsePx:'0',j:1,lang:___c,libs:!(),options:'-O1',overrides:!(),selection:(endColumn:1,endLineNumber:1,positionColumn:1,positionLineNumber:1,selectionStartColumn:1,selectionStartLineNumber:1,startColumn:1,startLineNumber:1),source:1),l:'5',n:'0',o:'+x86-64+gcc+14.2+(Editor+%231)',t:'0')),k:46.82444577591372,l:'4',m:60.76707291803545,n:'0',o:'',s:0,t:'0'),(g:!((h:tool,i:(args:'',argsPanelShown:'1',compilerName:'x86-64+clang+13.0.0',editorid:1,fontScale:14,fontUsePx:'0',j:1,monacoEditorHasBeenAutoOpened:'1',monacoEditorOpen:'1',monacoStdin:'1',stdin:'',stdinPanelShown:'1',toolId:clangtidytrunk,wrap:'1'),l:'5',n:'0',o:'clang-tidy+(trunk)+x86-64+gcc+14.2+(Editor+%231,+Compiler+%231)',t:'0')),l:'4',m:39.232927081964554,n:'0',o:'',s:0,t:'0')),k:37.96344647519585,l:'3',n:'0',o:'',t:'0')),l:'2',n:'0',o:'',t:'0')),version:4), gcc will inline a call to `memset` using the `rep stosq` instruction under certain circumstances.

This is already a good hint about the efficiency of this instruction.

{{% columns %}}


```c
#include <string.h>

#define BUF_LEN (1 << 13)
char a[BUF_LEN];
int value;

int main(void) {
  memset(a, value, BUF_LEN);
  return 0;
}
```

```sh
gcc -O1 -g -o memset memset.c
```

<--->

```asm
; int main(void) {
;   memset(a, value, BUF_LEN);
  401106:       mov    edi,0x404060
  40110b:       movzx  eax,BYTE PTR [rip+0x2f2e]        # 404040 <value>
  401112:       movabs rdx,0x101010101010101
  40111c:       imul   rax,rdx
  401120:       mov    ecx,0x400
  401125:       rep stos QWORD PTR es:[rdi],rax
;   return 0;
; }
  401128:       mov    eax,0x0
  40112d:       ret
```

{{% /columns%}}

To broadcast the first byte of value in all bytes of the rax register, the compiler puts `0x1010101010101010` in rdx and multiplies rax and rdx.

I wrote a macro to reproduce this:
{{% code file="code/string-instructions/memset/memset.asm" language="asm" start=33 end=40 %}}

Once again, I wrote 6 different versions of the `memset` function: an unoptimized for loop, the glibc `memset` function, `rep stosb`, `rep stosq` and the AVX and AVX2 extensions. 

{{< tabs >}}
{{< tab "generic" >}}
{{% code file="code/string-instructions/memset/memset.c" language="c" %}}
{{< /tab >}}
{{< tab "stosb" >}}
{{% code file="code/string-instructions/memset/memset.asm" language="asm" start=9 limit=9 %}}
{{< /tab >}}
{{< tab "stosb reversed" >}}
{{% code file="code/string-instructions/memset/memset.asm" language="asm" start=20 limit=12 %}}
{{< /tab >}}
{{< tab "movb" >}}
{{% code file="code/string-instructions/memset/memset.asm" language="asm" start=34 limit=12 %}}
{{< /tab >}}
{{< tab "stosq" >}}
{{% code file="code/string-instructions/memset/memset.asm" language="asm" start=56 limit=45 %}}
{{< /tab >}}
{{< tab "movq" >}}
{{% code file="code/string-instructions/memset/memset.asm" language="asm" start=102 limit=16 %}}
{{< /tab >}}
{{< tab "avx" >}}
{{% code file="code/string-instructions/memset/memset.asm" language="asm" start=119 limit=41 %}}
{{< /tab >}}
{{< tab "avx2" >}}
{{% code file="code/string-instructions/memset/memset.asm" language="asm" start=161 %}}
{{< /tab >}}
{{< /tabs >}}

{{< admonition info >}}
Like for the memcpy implementation, without the `__attribute__((optimize("O1")))` gcc would replace the call to our custom function by a call to memset.
{{< /admonition >}}

Here are the results of the benchmarks on my computer:

{{< figure title="Benchmark of memset implementations" src="images/benchmark-memset.svg">}}

We can see that except the _dummy_, _movb_ (very similar implementation) and _stosb_std_ (which is a reversed copy),
all the implementations managed to use the **fast-string operations** and have the save low execution time.

Once again, we can explore the implementation of glibc using gdb. Like memcpy, it is an **indirect function** which, in my case, resolves into `__memset_avx2_unaligned_erms`.

As for `memcpy`, I highlighted the code reached during the execution of my memset for a block of 4MiB.

___memset_avx2_unaligned_erms_

{{% code file="code/__memset_avx2_unaligned_erms.asm" language="asm {hl_lines=[\"1-8\", 19, 20, \"48-54\"]}" %}}
</details>

This is way shorter than the code for `memcpy`, and there is one big difference: there is a threshold for the min value for which we should use `rep stosq`: `__x86_rep_stosb_threshold`, but no threshold for the max value.

{{< admonition tip "Use of rep stosq">}}
`__x86_rep_stosb_threshold` = 0x800 = 8 * 256

This means that for more than 8 copies using ymm registers the memset implementation will use the `rep stosq` instruction.
{{< /admonition >}}

<!-- This is due to the fact that the memset function is comparable to the storing part of the memcpy function. Which means we have no load, hence no interest in prefetching large blocks of memory. -->

### Benchmark 3: strlen

If, like many C developers, you're used to passing around zero-terminated strings, your code may call strlen a bunch of times so this function had better be fast.

We saw a way to write a `strlen` function with the `repne scasb` instruction.
But there are other ways to write a strlen function by using vectorization, either on 64-bit register or using SIMD extensions.

To find a null byte in a quadword we can define a helper macro which takes two parameters:
- A destination register whose byte will have their sign bit set only if the corresponding byte in the source register is null.
- A source register where to find the null bytes.

.
{{% code file="code/string-instructions/find_zero.asm" language="asm" %}}
This macro uses a bit trick [documented here](https://graphics.stanford.edu/~seander/bithacks.html#ZeroInWord)
to find a byte in a quadword.
We will use it in the `strlen_movq` implementation.
We cannot use it to code a `repne scasq` implementation because scasq can only stop on a 64-bit equality.

{{< tabs >}}
{{< tab "generic" >}}
{{% code file="code/string-instructions/strlen/strlen.c" language="c" %}}
{{< /tab >}}
{{< tab "scasb" >}}
{{% code file="code/string-instructions/strlen/strlen.asm" language="asm" start=10 limit=12 %}}
{{< /tab >}}
{{< tab "movb" >}}
{{% code file="code/string-instructions/strlen/strlen.asm" language="asm" start=24 limit=11 %}}
{{< /tab >}}
{{< tab "movq" >}}
{{% code file="code/string-instructions/strlen/strlen.asm" language="asm" start=36 limit=20 %}}
{{< /tab >}}
{{< tab "avx" >}}
{{% code file="code/string-instructions/strlen/strlen.asm" language="asm" start=57 limit=23 %}}
{{< /tab >}}
{{< tab "avx2" >}}
{{% code file="code/string-instructions/strlen/strlen.asm" language="asm" start=81 limit=24 %}}
{{< /tab >}}
{{< tab "sse2" >}}
{{% code file="code/string-instructions/strlen/strlen.asm" language="asm" start=106 %}}
{{< /tab >}}
{{< /tabs >}}

{{< admonition info >}}
Like for the memcpy implementation, without the `__attribute__((optimize("O1")))` gcc would replace the call to our custom function by a call to strlen.
{{< /admonition >}}

Here are the results of the benchmarks on my computer:

{{< figure title="Benchmark of strlen implementations" src="./images/benchmark-strlen.svg">}}

As we can see, the `repne scasb` instruction is by far the worst way to write a strlen function while the standard `strlen` function outperforms every vectorized implementation.

We can again have a look to the glibc implementation of `strlen` for AVX2:

___strlen_avx2_
{{% code file="code/__strlen_avx2.asm" language="asm {hl_lines=[\"1-11\", \"45-92\"]}" %}}

After aligning rdi on 16 bytes, `__strlen_avx2` performs an unrolled loop to find the null byte.
In the loop body, the function loads 4 * 32 = 128 bytes each time, reduces them using the `vpminub` (Vector Packed MIN Unsigned Byte) instruction and compares the result to zero using the `vpcmpeqb` (Vector Packed CoMPare EQual Byte) instruction.

Note that in order to find the null byte position in the register, the `__strlen_avx2` function uses the `tzcnt` (Count Trailing Zeroes) instruction instead of the `bsf` (Bit Scan Forward) instruction.

These two instructions are very similar.<br>
According to the "Intel® 64 and IA-32 Architectures Software Developer’s Manual - Volume 2: Instruction Set Reference 4.3":
> TZCNT counts the number of trailing least significant zero bits in source operand (second operand) and returns the result in destination operand (first operand). TZCNT is an extension of the BSF instruction. The key difference between TZCNT and BSF instruction is that TZCNT provides operand size as output when source operand is zero while in the case of BSF instruction, if source operand is zero, the content of destination operand are undefined. On processors that do not support TZCNT, the instruction byte encoding is executed as BSF.

### Benchmark 4: memcmp

We can benchmark the `rep cmps` instruction by writing several implementations of the `memcmp` function.

This function can also be implemented using `vpcmpestri`.

{{< tabs >}}
{{< tab "generic" >}}
{{% code file="code/string-instructions/memcmp/memcmp.c" language="c" %}}
{{< /tab >}}
{{< tab "cmpsb" >}}
{{% code file="code/string-instructions/memcmp/memcmp.asm" language="asm" start=11 limit=10 %}}
{{< /tab >}}
{{< tab "movb" >}}
{{% code file="code/string-instructions/memcmp/memcmp.asm" language="asm" start=23 limit=18 %}}
{{< /tab >}}
{{< tab "cmpsq_unaligned" >}}
{{% code file="code/string-instructions/memcmp/memcmp.asm" language="asm" start=42 limit=26 %}}
{{< /tab >}}
{{< tab "cmpsq" >}}
{{% code file="code/string-instructions/memcmp/memcmp.asm" language="asm" start=69 limit=39 %}}
{{< /tab >}}
{{< tab "avx" >}}
{{% code file="code/string-instructions/memcmp/memcmp.asm" language="asm" start=109 limit=45 %}}
{{< /tab >}}
{{< tab "avx2" >}}
{{% code file="code/string-instructions/memcmp/memcmp.asm" language="asm" start=155 limit=46 %}}
{{< /tab >}}
{{< tab "vpcmpestri_unaligned" >}}
{{% code file="code/string-instructions/memcmp/memcmp.asm" language="asm" start=219 limit=36 %}}
{{< /tab >}}
{{< tab "vpcmpestri" >}}
{{% code file="code/string-instructions/memcmp/memcmp.asm" language="asm" start=256 %}}
{{< /tab >}}
{{< /tabs >}}

{{< admonition info >}}
Note that even with -O3 the compiler couldn't replace our custom c function by a call to memcmp.

Indeed, `memcmp` only guarantees the value of the sign bit of the return value in the case of different data. But we may be wanting specifically -1, 0 or 1 to be returned, and the compiler can't assume otherwise.
{{< /admonition >}}

<!-- ![Benchmark of memcmp implementations](images/benchmark-memcmp.svg) -->
{{< figure title="Benchmark of memcmp implementations" src="images/benchmark-memcmp.svg" >}}

The `repe cmpsb` instruction is almost as bad as the `repne scasb` instruction. But this time we could give an implementation using `repe cmpsq` which performs almost as well as the vectorized string and AVX extensions on my computer.

{{< admonition tip>}}
When you are in a situation where you could use a `cmpsb` or `cmpsq` instruction, you should always prefer make comparisons using the greatest registers available.
{{< /admonition >}}

Here is the disassembled code of `__memcmp_avx2_movbe`:

___memcmp_avx2_movbe_
{{% code file="code/__memcmp_avx2_movbe.asm" language="asm {hl_lines=[\"1-29\", \"74-89\", \"91-131\"]}" %}}

...aaaand there is no use of the `repe cmps` instruction :disappointed_relieved:

The `_memcmp_avx2_movbe` function only uses an unrolled loop of avx2 instructions.

### Benchmark 5: strchr

I chose the `strchr` function to demonstrate the use of the `lodsb` instruction because we need to make two checks on the read byte, which makes it unsuitable for `scasb`. But as `lodsb` doesn't have side effects nor set the flags, we can't use a repetition prefix, which makes it very similar to a `movb`.

That's why the implementation using `movsb` and `movb` as well as `mosq` and `movq` are factorized in two macros `strchr_byte` and `strchr_quad`.

{{< tabs >}}
{{< tab "generic" >}}
{{% code file="code/string-instructions/strchr/strchr.c" language="c" %}}
{{< /tab >}}
{{< tab "byte" >}}
{{% code file="code/string-instructions/strchr/strchr.asm" language="asm" start=13 limit=27 %}}
{{< /tab >}}
{{< tab "quad" >}}
{{% code file="code/string-instructions/strchr/strchr.asm" language="asm" start=41 limit=46 %}}
{{< /tab >}}
{{< tab "avx" >}}
{{% code file="code/string-instructions/strchr/strchr.asm" language="asm" start=88 limit=51 %}}
{{< /tab >}}
{{< tab "avx2" >}}
{{% code file="code/string-instructions/strchr/strchr.asm" language="asm" start=140 limit=52 %}}
{{< /tab >}}
{{< tab "sse2" >}}
{{% code file="code/string-instructions/strchr/strchr.asm" language="asm" start=193 %}}
{{< /tab >}}
{{< /tabs >}}

{{< admonition >}}
Even with `-O3` gcc did not replace my `strchr` implementation with a call to the standard `strchr`.
It even actually generated a pretty bad implementation (maybe this could be fixed by feeding it a more contrived implementation).
{{< /admonition >}}

The implementation is similar to the `strlen` implementation, especially the 64-bit one. Indeed, we still need to find the end of the string but we also need to find a given byte, and as we know how to find a `0x00` byte in a quadword using the `find_zero` macro, we just need to `xor` the quadword with the byte to nullify all the equal bytes in the quadword (`a XOR a = 0` is equivalent to `a = a`) and then find the `0x00` bytes.

Here are the result of the benchmark on my computer:

{{< figure title="Benchmark of strcnt implementations" src="./images/benchmark-strchr.svg" >}}

The `loads` instruction is always slower than the `mov` alternatives, so... just don't use it.

### Benchmark 6: iota

I wanted to end this benchmark of the string instructions with another benchmark of the `stos` instruction.
We saw that this instruction is quite fast with a `rep` prefix, so let's see how it compares to a `mov` when used in a loop without a prefix:

{{< tabs >}}
{{< tab "generic" >}}
{{% code file="code/string-instructions/iota/iota.c" language="c" %}}
{{< /tab >}}
{{< tab "byte" >}}
{{% code file="code/string-instructions/iota/iota.asm" language="asm" start=29 limit=26 %}}
{{< /tab >}}
{{< tab "quad" >}}
{{% code file="code/string-instructions/iota/iota.asm" language="asm" start=61 limit=25 %}}
{{< /tab >}}
{{< tab "avx" >}}
{{% code file="code/string-instructions/iota/iota.asm" language="asm" start=87 limit=18 %}}
{{< /tab >}}
{{< tab "avx2" >}}
{{% code file="code/string-instructions/iota/iota.asm" language="asm" start=106 %}}
{{< /tab >}}
{{< /tabs >}}

The benchmark result on my computer:

{{< figure title="Benchmark of iota implementations" src="./images/benchmark-iota.svg">}}

As we can see, there is no interest in using the `stos` instruction without a prefix as it will generally perform worse than an equivalent `mov` instruction.	

This corroborates the claim of ["Optimizing subroutines in assembly language"](https://www.agner.org/optimize/):
> String instructions without a repeat prefix are too slow and should be replaced by simpler instructions. The same applies to the LOOP instruction and to JECXZ on some processors.

<!-- TODO: Write the vector string instruction section. -->
<!-- TODO: Write instruction encoding section. -->

## Conclusion

We've seen a lot in this article. Now what should you remember from all of this to write better assembly code ?

Here are some general guidelines you can keep in mind when using string instructions:
- You should use `rep stosq` to initialize large blocks of memory.
- You should use `rep movsq` to copy large blocks of memory (more than 512 bytes) which fit in your cache (~7Mib), for larger blocks of memory you should use prefetching mechanisms, AVX extensions, unrolled loop and non-temporal-stores.
- Do not use string instructions without repeat prefixes as they will generally be slower than their classical alternatives.
- Do not use `scas`, `cmps` and `lods` as you can always come up with more efficient (AVX) versions.

String instructions are very portable instructions as they're present on all x86 processors (back to the 8086).
However, most of the time they tend to perform slower than the alternatives using the largest available registers.
Therefore, except for `rep stosq` and `rep movsq` you shouldn't use them unless you're optimizing for size.
