+++
title = 'Use nasm preprocessor to write clean x86 asm'
date = 2024-08-12T20:30:37+02:00
draft = false
tags = [ 'asm', 'x86', 'x86_64', 'nasm', 'preprocessor']
toc = true
+++

Writing assembly is a tedious work.

My greatest issues with assembly language programming are the lack of names for local variables, the need to write the same assembly code repetitively (for instance function's prologue an epilogue) and the lack of data structures.
These are three good reasons to learn a preprocessor language when you learn to write assembly and there could be a lot of others reasons like the need to adapt the code to the cpu features, or the need to generate large portions of code (like declaring an array of 1024 bytes filled with ones), etc.

The goal of this post is to introduce you to the nasm preprocessor which is way more powerful than the C preprocessor.

Each time you want to check the preprocessed output of a snippet you can do so by using the -E option of nasm which will cause nasm to pre-process the file and print the output to stdout without actually assembling anything.

> *Disclaimer: This post intends to be a reminder of useful nasm preprocessor functionalities. It is mainly for my personal use and reflects what i judge "useful". If you want an exhaustive view of the nasm preprocessor you can directly read the nasm documentation [here](https://www.nasm.us/xdoc/2.16.03/html/nasmdoc4.html) Moreover some of the examples in this post are shamelessly copied from the nasm documentation. Note that they all were translated to linux-x86_64 asm.*

## Including other files

### Include a source file

Like with the C preprocessor, you can include a source file at the current line by using the %include directive.
You can use it to create a file containing all the macros we will define and include their definition in your future asm source files.
```asm
%include "macros.asm"
```

### Include a binary file

The nasm language contains the incbin directive to include the binary content of an external file in our object file.
If you use incbin in your program it will actually use the macro wrapped around the incbin directive to search the filename in the path and add it to the dependency list.
```asm
incbin  "file.dat"			; include the whole file 
incbin  "file.dat",1024		; skip the first 1024 bytes 
incbin  "file.dat",1024,512	; skip the first 1024, and 
							; actually include at most 512
```

## Defining single-line macros

### Our first directive: %define

The simpler way to define a macro with nasm as with the C-preprocessor is to use the directive %define. It should be very familiar to you if you already used C.

You can define object macros or function macros using this directive.

```asm
; A macro with no parameters
%define ctrl    0x1F &
; A two parameter macro
%define param(a,b) ((a)+(a)*(b)) 

        mov     byte [param(2,ebx)], ctrl 'D'
```

Which will expand to:
```asm
        mov     byte [(2)+(2)*(ebx)], 0x1F & 'D'
```

It can be used to define constants as well as the equ directive, but is way more-powerful.

A notable difference between %define and equ is that %define constants are expanded when invoked, while equ constants are expanded when defined.

For instance:
```asm
; addr will expand to the location of the assembly position
addr 	equ			$ ; ...of this line
%define 	addr	$ ; ...of the line in which the macro is invoked
```

If you want %define content to be expanded on definition **you can use the alternative directive: %xdefine.**

The main difference between %define and #define from the C-processor is that with nasm, macro functions can be overloaded.

```asm
; macro function can be overloaded
%define foo(x) 1+x
%define foo(x, y) 1+x+y
```
However a macro function can't coexist with a macro object of the same name.
```asm
; nasm will produce 'error: macro `foo' defined both with and without parameters [-w+error=pp-macro-def-param-single]'
%define foo bar 
```

A macro argument can be omitted if it is never used.
Which means an overload macro function cannot have zero arguments (A macro defined with empty parenthesis is a sub-case of functions with one unused argument).

As in C, a single-line macro can be undefined using the %undef directive.

### Macro objects types

Macro objects can have one of the four types: numeric, string, tokens and aliases.
Let's examine the two more useful ones: numerics and strings.

We can define macro numerics using the %assign directive.

The assign directive take an argument which has to be a *critical expression* and evaluate to a pure number (it can't be a symbol). The nasm documentation refers to a *critical expression* as:
> an expression whose value is required to be computable in the first pass, and which must therefore depend only on symbols defined before it.

As with %define, a numeric macro can be redefined, which allow us to increment our macro:
```asm
%assign i 1
; here the macro will expand to 1
%assign i i+1
; from now the macro will expand to 2
```

A numeric macro can also be defined using the %strlen directive which will define a macro equals to the length of the expanded parameter if its a string.

We also have a directive to define macro strings: %defstr
```asm
; Both lines are equivalent
%defstr test TEST
%define test 'TEST'
; The following line assign 4 to the length macro
%strlen length test
```

The %defstr directive can be useful with another directive: %!, which allows to read environment variables.
For instance to define a string containing the value of the $PATH variable (at compile time !!):
```asm
%defstr PATH %!PATH
```

### Numeric arguments

You can ensure an argument of a macro is a valid numeric expression by prefixing the name of the parameter with an equal sign.
The argument will be evaluated after its expansion.
```asm

%define raxset(expr) mov rax, expr
	raxset(1 + 5) 	; will expand to mov rax, 1 + 5
	raxset(rdx)		; will expand to mov rax, rdx

%define raxset(=expr) mov rax, expr
	raxset(1 + 5)	; will expand to mov rax, 6
	raxset(rdx)		; will produce error: 'non-constant expression in parameter 0 of macro'
```

### Quoted arguments

You can turn an argument into a quoted string by prefixing it with an ampersand ('&'). It will surround the argument with double-quote, even if it is already a quoted string. If you want to avoid this behavior you can use the double-ampersand prefix.

```asm
%define add_lf(&str) db str, 10, 0
	add_lf(1 + 5)		; will expand to db '1 + 5', 10, 0
	add_lf("1 + 5")		; will expand to db '"1 + 5"', 10, 0
	add_lf('1 + 5')		; will expand to db "'1 + 5'", 10, 0
%define add_lf(&&str) db str, 10, 0
	add_lf(1 + 5)		; will expand to db '1 + 5', 10, 0
	add_lf("1 + 5")		; will expand to db "1 + 5", 10, 0
	add_lf('1 + 5')		; will expand to db '1 + 5', 10, 0
```

## Multi-line macros

### Our lovely %macro and %endmacro couple

Multi-line macro are defined using the %macro directive an have to be closed using a %endmacro directive.
You have to indicate the amount of parameters the macro can take after its name.

Multi-line macros can be use to reduce aggressively the amount of logic repetition in your code.

A useful example, is the definition of the function prologue:
```asm
%macro prolog 1		; The number of parameter is 1
	push rbp
	mov rbp, rsp
	sub rsp, %1 	; %1 refers to the first parameter
%endmacro

myfunc: prolog 0x40
; will expand to:
; 	push rbp
; 	mov rbp, rsp
; 	sub rsp, 0x40
```

A macro can take any amount of parameters which will be accessed via their 1-based index starting from %1, %2, %3 and so on.

%0 is reserved for the number of arguments passed to the macro because as we'll see later, multi-line macros can take a variable amount of parameters.

As single-line macros can be undefined with %undef, multi-line macro can be undefined with the %unmacro directive.

### Macro-local labels

Sometimes you need your multi-line macro to contain a label to perform a jump inside the expansion. Using a local label (a label prefixed by a dot) is not enough as we want to be able to call the macro several times in a function.

You can then use a macro local label which is prefixed by '%%' and will expand to a different symbol for each invocation of the macro.

Let's write a macro which returns when the Z flag is set:
```asm
%macro  retz 0 
        jnz %%skip 	; jump over the ret instruction if the Z flag is not set
        ret         ; returns from the function
    %%skip:         ; macro-local label
%endmacro
```


### Condition codes as macro parameters

As you can enforce a single-line macro parameter to be a numeric expression, you can enforce a multi-line macro parameter to be a condition code.

Referring to a multi-line macro parameter (the first in our example) using %+1 will ensure that it will be a condition code. You can also refer to a condition code using %-1 which will replace the condition code by its negation.

Using this syntax we can now generalize our previous retz macro by taking a condition code as parameter.
```asm
%macro  retc 1 
		j%-1 %%skip	; jump over the ret instruction if the condition code is false
		ret			; returns from the function
	%%skip:			; macro-local label to jump if condition code is false
%endmacro

myfunc:
	test rdi, rdi	; set the status flags according to the content of the rdi register
	retc ne			; returns if rax is null
```

{{< box important >}}
I wouldn't recommend to use the retz and retc macro to make early return as according to the [Intel Optimization Reference Manual](https://cdrdv2.intel.com/v1/dl/getContent/671488) 3.4.1.2 when using static prediction, forward branch are not taken. But early returns are often used as a way to manage errors so we want them the branch to be predicted as taken (skipping the return instruction).

So you can use these macros but remember it will result in branch mispredictions if the return is unlikely.
{{< /box >}}

### Varying amount of parameters

The last parameters of a macro can be declared "greedy" adding a '+' after the parameter count declaration. Which means they will expand to the comma-separated list of all the additional arguments.

Let's define a macro to write to a file on a 64-bit Unix system.
It will take at least two parameters:
- The first will be the file descriptor to which we want to write
- The following parameters will be a list of sequence of bytes to write
```asm
SYS_write equ 1			; sys_write is the syscall n°1

%macro sys_write 2+ 	; The second parameter will be greedy
	jmp %%endstr
%%str:					; we define a macro-local label 
	db %2				; and drop all the parameters from the second one as bytes
%%endstr:						
	mov rax, SYS_write 			; we put the syscall number in rax
	mov rsi, %%str 				; put the adress of the string in rsi
	mov rdx, %%endstr - %%str	; put the size of the string in rdx
	mov rdi, %1 				; put the filehandle in rdx
	syscall
%endmacro
```

The macro can also have optional parameters for which you can provide a default value.<br>
The syntax to indicate that the macro take at least 3 parameters and at most 5, with the 4th and 5th parameters respectively defaulting to eax and [eax+2] is:

```asm
%macro mymacro 3-5 eax, [ebx+2]``
```

Using this knowledge, let's define a macro to exit the program which take an exit code as optional parameter:
```asm
	SYS_exit equ 60 ; sys_exit is the syscall n°60
EXIT_SUCCESS equ 0	; the success error code is 0

%macro sys_exit 0-1 EXIT_SUCCESS	; The macro takes one optional parameter
	mov rax, SYS_exit			; we put the syscall number in rax
	mov rdi, %1					; we put the error code in rdi
	syscall
%endmacro
```

With this two macro defined, our hello-world can be rewritten in a much more readable manner:
```asm
section .text

global _start
_start:
	sys_write 1, "Hello World!", 10, 0
	sys_exit
```

## Condition and loop directives

### Conditional directives

Similarly to the C preprocessor, NASM allows sections of a source file to be assembled only if certain conditions are met. The general syntax of this feature looks like this:

```asm
%if<condition> 
    ; some code which only appears if <condition> is met 
%elif<condition2> 
    ; only appears if <condition> is not met but <condition2> is 
%else 
    ; this appears if neither <condition> nor <condition2> was met 
%endif
```
The inverse forms %ifn and %elifn are also supported.

The %else clause is optional, as is the %elif clause. You can have more than one %elif clause as well.

The variants of the %if directives are:
- %if: the code is assembled if the numerical expression evaluate to non-zero
- %ifdef: the given single-line macro is already defined
- %ifmacro: the given multi-line macro is already defined
- %iftoken: the given tokens exapand to a single token
- %ifctx: the given list of parameters contain the name of the context on top of the stack
- %ifidn: the given two single-line macro expand to the same code
- %idid: the first given token is an identifier
- %ifstr: the first given token is a quoted string
- %ifnum: the first given token is a integer numeric constant
- %ifempty: the expanded parameters does not contain any content at all
- %ifenv: the given environment variable exists

Each has its corresponding %elif, %ifn, and %elifn directives; for example, the equivalents to the %ifdef directive are %elifdef, %ifndef, and %elifndef.

### Our final write macro

An important mechanism in the nasm preprocessor is that all the text contained inside the definition of a multi-line macro is saved and expanded when the macro is used.

This means that we can use conditional directives to perform tests over the macro parameters and generate code depending on this parameters.

For example, our write macro can be extended to take advantage of %ifstr and %ifid in the following fashion:
```asm
SYS_write equ 1			; sys_write is the syscall n°1

; For this version we need at least 2 parameter because we'll test the type of the second one.
%macro sys_write 2-3+ 	; The third parameter will be optional and greedy

		mov edi, %1 			; put the filehandle in edx
  %ifstr %2
	    jmp %%endstr
%%str:				; we define a macro-local label 
    %if %0 == 3		; If there are three parameters
		db %2, %3		; and drop all the parameters from the second one as bytes
	%else
		db %2, %3	; otherwise we drop the second parameter as bytes
	%endif
%%endstr:
		mov rsi, %%str 				; put the adress of the string in esi
		mov edx, %%endstr - %%str	; put the size of the string in edx
  %elifid %2
		mov rsi, %2 				; put the adress of the string in esi
		mov edx, %3				; put the size of the string in edx
  %else
    %error "The second parameter of write should be a string or an identifier"
  %endif

		mov eax, SYS_write 		; we put the syscall number in eax
		syscall
%endmacro
```

Then the write macro can cope with being called in either of the following two ways:

```asm
        sys_write [file], strpointer, length 
        sys_write [file], "hello", 13, 10
```

### %rep directive and loop unrolling

The times prefix can be used to repeat an instruction, but can't be used to repeat multi-line macros as they're expanded before the times prefix. To circumvent this, nasm gives us the %rep and %endrep directive, which repeat the inner code the number of times given as parameter.

We can compute the index of the loop using the %assign directive.
```asm
%assign i 0 
%rep    64 
        inc     word [table+2*i] 
%assign i i+1 
%endrep
```

A loop can be exited using a %exitrep directive (as the break keyword in C).

The %rotate directive moves all parameters of a macro to the left and the first parameter become the last one.
The shift count is passed as a parameter. With a negative count the parameters are rotated to the right.

The %rotate directive can be leveraged with %rep to iterate over the arguments of a multi-line macro:
```asm
%macro multipush 1-* 
	%rep %0 
		push %1 
		%rotate 1 
	%endrep 
%endmacro

%macro  multipop 1-* 
	%rep %0 
		%rotate -1 
		pop     %1 
	%endrep 
%endmacro
```

## Writing control structures using the context stack

Something we may want to write using macros are control structures such as if...elsif...else, for loops, while loops...
We have already been able to write conditional returns using macro-local labels and condition codes as parameters.

However to write control structures, we need to be able to reference some labels defined by other macro calls from our macros.
Luckily, the nasm preprocessor has a mechanism to make this possible: **the context stack**.

The context stack allows to save on a stack some local labels and local single-line macros.
Each local context can be named when it is pushed on the stack using the %push directive

The context on the top of the stack can be restored using the %pop directive which take an optional context name. If a context name is given and it's not the name of the context on top of the stack, nasm will generate an error.

```asm
%push first
; define some context-local
; labels and macros...
%push second
; labels and macro from the first context
; can't be accessed from here
%pop second
; we're back in our first context
%pop first
```

### Context-local labels

Context-local labels can be defined and used with the %$label syntax.

This will allow us to write a simple repeat...until loop:
```asm
%macro repeat 0 
    %push   repeat 
    %$begin: 
%endmacro 

%macro until 1 
        j%-1    %$begin 
    %pop 
	%$end
%endmacro
```

{{< box info >}}
Here we define a backward branch which is expected to be taken. That's what we expect from a loop making this macro well suited for production use.
{{< /box >}}

And use it this way:
```asm
iota_byte:
	mov rcx, rdi 		; rcx = 2nd arg
	repeat
	dec rcx				; decrement rcx
	mov [rsi + rcx], cl ; write cl at rsi + rcx
	test rcx, rcx		; set the status register
	until e				; repeat until rcx == 0
```

We can (and will later on), define all the common kinds of control structures that exist in higher level languages.

### Context-local macros

Context-local single-line macro can be define in just the same way.
```asm
%define %$localmac 3
```

Macro and label from a higher context can both be accessed using %$mylabel for the parent, %$$mylabel for the grandparent and so on...

This allow us to retain information other than labels over multiple macro calls. Using this mechanism we can improve our prolog macro and write its companion the epilog macro:

```asm
%macro prolog 1
	%push func					; push a new context on the stack
	%define %$frame_size %1		; define the context-local macro frame_size
	push rbp
	mov rbp, rsp
	sub rsp, %$frame_size
%endmacro

%macro epilog 0
	%ifnctx func ; test if a prolog macro has been issued and if all the inner contexts have been closed
		%error "The epilog macro shouldn't be call until all the contexts pushed in the local function have been poped"
	%endif
	add rsp, %$frame_size	; use the context-local macro to clear the stack
	pop rbp
	%pop
	ret
%endmacro
```

Now we can use our prolog macro to define the frame size and subtract it from rsp. Then our epilog macro will be able to know the frame size and clean it up by adding it to rsp.

Let's use a simple fibonnacci implementation as example:
{{% columns %}}
```asm
; fibo(rdi: u64)
fibo:
	; prologue
	prolog 0x10
	; test for final case
	test rdi, (~1)
	jz .zero_or_one 	; fallthrough is the likely case
	mov [rbp-0x10], rdi 	; save n on stack
	sub rdi, 1
	call fibo			; rax = fibo(n - 1)
	mov [rbp-0x8], rax	; save fibo(n - 1) on stack
	mov rdi, [rbp-0x10]	; rdi = n
	sub rdi, 2
	call fibo			; rax = fibo(n - 2)
	mov rdx, [rbp-0x8]	; rdx = fibo(n - 1)
	add rax, rdx		; rax = fibo(n - 2) + fibo(n - 1)
	jmp .end			; jump to epilogue
.zero_or_one:
	mov rax, rdi	; return n
.end:
	; epilogue
	epilog
```
<--->
![](./stack.svg)
{{% /columns %}}

### A if..else..endif macro

Using context-local labels, and the context renaming feature we can now define if..else..endif macros to simplify writing of conditions.

To rename the context on top of the context-stack we can use the %repl directive.

```asm
%macro if 1 
    %push if 
    j%-1  %$ifnot 
%endmacro 

%macro else 0 
  %ifctx if 
        %repl   else
        jmp     %$ifend 
        %$ifnot: 
  %else 
        %error  "expected `if' before `else'" 
  %endif 
%endmacro 

%macro endif 0 
  %ifctx if 
        %$ifnot: 
        %pop 
  %elifctx      else 
        %$ifend: 
        %pop 
  %else 
        %error  "expected `if' or `else' before `endif'" 
  %endif 
%endmacro
```

A sample usage of these macros might look like:
```asm
	cmp     ax,bx 
	if ae					; if(ax >= bx)
		cmp    bx,cx 
		if ae 				; if(bx >= cx)
			mov     ax,cx 
		else 
			mov     ax,bx 
		endif 
	else 
		cmp ax,cx
		if ae				; if(ax >= cx)
			mov     ax,cx 
		endif 
	endif
```

{{< box important >}}
Note that according to the common rules of branch prediction the first if branch is expected to be the likely case and the else branch should be the unlikely one. Keep that in mind when using these macros.
{{< /box >}}

## Simplifing references to variables

### Defining structures

We already defined a bunch of macros to simplify system calls. But some system calls take pointers to structured data as arguments.
It is the case for the stat system call for instance.

C structures are very simple. It is basically a collection of named offsets.
nasm preprocessor contains standard macros to define structures and declare instances of structures.

The stat system call has this prototype
```c
int stat(const char *restrict chemin, struct stat *restrict statbuf);
```
And struct stat is defined in /usr/include/asm/stat.h

{{% columns %}}
Using nasm preprocessor:
```asm
struc stat
	st_dev:	 		resq 1
	st_ino:	 		resq 1
	st_mod:	 		resw 1 
	st_nlink:		resw 1 
	st_uid: 		resw 1 
	st_gid: 		resw 1 
	st_rdev:		resq 1
	st_size:		resq 1
	st_blksize:		resq 1
	st_blocks:		resq 1
	st_atime:		resq 1
	st_atime_nsec:	resq 1
	st_mtime:		resq 1
	st_mtime_nsec:	resq 1
	st_ctime:		resq 1
	st_ctim_nsec:	resq 1
	__unused_stat:	resq 2
endstruc
```
<--->
Using C:
```c
struct stat {
    unsigned long  st_dev;
    unsigned long  st_ino;
    unsigned short st_mode;
    unsigned short st_nlink;
    unsigned short st_uid;
    unsigned short st_gid;
    unsigned long  st_rdev;
    unsigned long  st_size;
    unsigned long  st_blksize;
    unsigned long  st_blocks;
    unsigned long  st_atime;
    unsigned long  st_atime_nsec;
    unsigned long  st_mtime;
    unsigned long  st_mtime_nsec;
    unsigned long  st_ctime;
    unsigned long  st_ctime_nsec;
    unsigned long  __unused4;
    unsigned long  __unused5;
};
```
{{% /columns %}}

The struc...endstruc pair of macro create a list of symbols: st_dev, st_ino... And each symbol is located at the relative offset of the member of the structure.

It also define the symbol stat_size, by concatenating the struct name with _size.


An instance of struct stat can be created this way:
```nasm
section .bss
file_stat:
	resb stat_size
```
Or initialized this way:
```asm
section .data
file_stat:
	istruc stat
		at st_dev, dq 0x0
		at st_ino, dq 0x0
		...
	iend
```

And members can be accessed using the [file_stat+st_dev] syntax.
```asm
section .text

global _start
_start:
	sys_stat "/var/log/messages", file_stat
	mov r8, [file_stat + st_dev]
	mov r9, [file_stat + st_ino]
	...
```

### Referencing stack parameters: %arg

Simplifying references to local variables and parameters require giving some information on the structure of the stack.
This is done using the %stacksize directive whose parameter must be one of: flat, flat64, large or small.

As long as after the call of the function rip is on the stack and local variables can be referenced using rbp you can use the flat64 parameter.

On Linux 64-bits, the 6 first arguments are passed using the register. But the others are pushed on the stack in the inverse order they are defined.

nasm gives us another directive %arg to name the adress in the stack of this pushed parameters.
You have to give to %arg the list of these stack-parameters and their size in this format: [name]:[byte|word|dword|qword|tword|oword|yword|zword]

```asm
section .text
; long func(long a, long b, long c, long d, long e, long f, long g, short h);
global func
func:
	%stacksize flat64
	%arg g:qword, h:word
	prolog 0x0

	xor rax, rax
	mov rax, rdi		; 1st param
	mov rax, rsi		; 2nd param
	mov rax, rdx		; 3rd param
	mov rax, rcx		; 4th param
	mov rax, r8			; 5th param
	mov rax, r9  		; 6th param
	mov rax, qword [g]	; 7th param
	xor eax, eax
	mov ax, word [h]	; 8th param

	epilog
```

### Referencing local variables: %local

The nasm preprocessor can also relieve us of the burden of managing local variables' addresses and the frame size.

We can declare local variables using the %local directive in the same way we used the %arg directive.
Before a call to %local, the context-local macro %$localsize has to be defined as a numeric constant. %local will add the summed size of the local parameters to %$localsize.

We can improve our prolog macro so that it can take two optionals arguments:
1. The initial value of %$localsize which will account for the "free space" we want in the stack frame, which is the space left above the local variables declarations.
2. The list of local variables as the %local directive waits for, enclosed in brackets.

Enclosing the parameters in brackets allows to pass as a single parameter comma and colon-separated tokens.

```asm
%macro prolog 0-2
	%push func					; Push a context for the function
%ifn %0 = 0						; If there are arguments
	%ifnum %1					; If the first one is a numeric constant
		%assign %$localsize %1	; Initialize the %$localsize with it
		%ifn %0 = 1				; If there is another parameter
			%local %2			; Pass it to the %local directive
		%endif
	%else
		%assign %$localsize 0	; Otherwise initialize %$localsize to 0
		%local %1				; And pass the first parameter to %local
	%endif
%endif
	push rbp					; Save the base pointer on the stack
	mov rbp, rsp				; Save the stack pointer in the base pointer
	%ifdef %$localsize			; If the %localsize macro is defined
		sub rsp, %$localsize	; Update the stack pointer with its value
	%endif
%endmacro

%macro epilog 0
	%ifnctx func ; test if a prolog macro has been issued and if all the inner contexts have been closed
		%error "The epilog macro shouldn't be call before all the contexts pushed in the local function have been poped"
	%endif
	%ifdef %$localsize			; If the %localsize macro is defined
		add rsp, %$localsize	; use the context-local macro to clear the stack
	%endif
	pop rbp						; Restore the base pointer
	%pop						; Pop the function context
	ret							; Return from the function
%endmacro
```

We can now name our local variables in the fibonacci function defined earlier:

```asm
; fibo(rdi: u64)
fibo:
	; prologue
	%stacksize flat64
	prolog {n:qword, res:qword}
	; test for final case
	test rdi, (~1)
	jz .zero_or_one 	; fallthrough is the likely case
	mov [n], rdi 	; save n on stack
	sub rdi, 1
	call fibo			; rax = fibo(n - 1)
	mov [res], rax	; save fibo(n - 1) on stack
	mov rdi, [n]	; rdi = n
	sub rdi, 2
	call fibo			; rax = fibo(n - 2)
	mov rdx, [res]	; rdx = fibo(n - 1)
	add rax, rdx		; rax = fibo(n - 2) + fibo(n - 1)
	jmp .end			; jump to epilogue
.zero_or_one:
	mov rax, rdi	; return n
.end:
	; epilogue
	epilog
```

## Summary

1. You can include source files using %include and binary files using the incbin macro
2. You can define single-line macros using %define, %assign, %defstr...
3. You can define multi-line macros using %macro...%endmacro. These can take a varying amount of parameters accessed using their index (starting from 1, %0 being the number of parameters)
4. You can use %if..%elif..%else..%endif and their variants to assemble code conditionally
5. You can use %rep..%endrep for loop unrolling and %exitrep to break the loop early
6. You can use %push and %pop to manage the context stack and use the %$identifier syntax to declare context-local labels and macros
7. You can use the %arg directive to name stack parameters and %local to name local variableo

Moreover you earned yourself a set of handful macros to write cleaner assembly!

