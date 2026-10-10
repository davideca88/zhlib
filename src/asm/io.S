#include <macros.h>

#define TAB         wspaces(%rip)
#define LINEFEED    wspaces + 1(%rip)
#define SPACE       wspaces + 2(%rip)

.section .data

/* wspaces - reserved escaping chars */
wspaces: .byte '\t', '\n', ' '

.section .bss

.section .text

.global __exit
.global string_length
.global print_string
.global print_char
.global print_newline
.global print_uint
.global print_int
.global read_char
.global read_word
.global parse_uint
.global parse_int
.global string_equals
.global string_copy

/**
 * exit - Exits the process
 *
 * @exit_code: exit code
 */
__exit:
    mov         $0x3c,      %rax
    syscall

/**
 * string_length - Returns the length of a null terminated string
 *
 * @str: string buffer
 *
 * Return: length of @str
 */
string_length:
    xor         %rax,       %rax
    mov         (%rdi),     %r9b
.L_string_length_loop0:
    cmp         $NULL,      %r9b
    je          .L_string_length_eloop0
    inc         %rax
    mov         (%rdi, %rax),  %r9b
    jmp         .L_string_length_loop0
.L_string_length_eloop0:
    ret
/**
 * print_string - Prints a string to stdout
 *
 * @str: string to be printed
 */
print_string:
    mov         %rdi,       %r8
    mov         $0x01,      %rax
    mov         $STDOUT,    %rdi
    mov         %r8,        %rsi
    mov         $0x01,      %rdx
.L_print_string_loop0:
    cmpb        $NULL,      (%rsi)
    je          .L_print_string_eloop0
    syscall
    mov         $0x01,      %rax
    inc         %rsi
    jmp         .L_print_string_loop0
.L_print_string_eloop0:
    ret

/**
 * print_char - Prints a char (u8) to stdout
 *
 * @ch: char to be printed
 */
 print_char:
    sub     $0x10,          %rsp
    mov     %dil,           (%rsp)
    mov     $0x01,          %rax
    mov     $STDOUT,        %rdi
    mov     %rsp,           %rsi
    mov     $0x01,          %rdx
    syscall
    add     $0x10,          %rsp
    ret

/**
 * print_newline - Prints a '\n'
 */
print_newline:
    mov     LINEFEED,       %dil
    call    print_char
    ret
/**
 * print_uint - Prints an u64 to stdout
 *
 * @no: u64 to be printed
 */
print_uint:
    push    %rbp
    mov     %rsp,           %rbp
    sub     $0x20,          %rsp
    mov     %rdi,           %rax
    mov     $0x0a,          %r8
    xor     %rdx,           %rdx
    div     %r8
    xor     %r9,            %r9
    movb    $NULL,          -1(%rbp, %r9)
    dec     %r9
    jmp     1f
.L_print_uint_loop0:
    cmp     $0x00,          %rax
    jne     1f
    cmp     $0x00,          %rdx
    je      .L_print_uint_eloop0
1:
    add     $'0',           %rdx
    mov     %dl,            -1(%rbp, %r9)
    dec     %r9
    xor     %rdx,           %rdx
    div     %r8
    jmp     .L_print_uint_loop0
.L_print_uint_eloop0:
    lea     (%rbp, %r9),   %rdi
    call    print_string
    add     $0x20,          %rsp
    pop     %rbp
    ret

/**
 * print_int - Prints a i64 to stdout
 *
 * @no: i64 to be printed
 */
 print_int:
    cmp     $0x00,          %rdi
    jge     1f
    push    %rdi
    mov     $'-',           %rdi
    call    print_char
    pop     %rdi
    neg     %rdi
1:
    call    print_uint
    ret


/**
 * read_char - Reads a char (u8) from stdin
 *
 * Return: char read
 */
read_char:
    sub     $0x01,          %rsp
    xor     %rax,           %rax
    mov     $STDIN,         %rdi
    mov     %rsp,           %rsi
    mov     $0x01,          %rdx
    syscall
    mov     (%rsp),         %al
    add     $0x01,          %rsp
    ret

/**
 * read_word - Reads a word (u8[]) from stdin to buf. Skips white spaces
 *
 * @buf: buffer to store the read word
 * @buf_size: size of the buffer
 *
 * Return: @buf address if the word fits on @buf, 0 otherwise
 */
 read_word:
    mov     %rsi,           %r8
    xor     %r9,            %r9
    mov     %rdi,           %r10
    dec     %r8
.L_read_word_loop0:
    cmp     %r8,            %r9
    jg      .L_read_word_err0
    call    read_char
    cmp     SPACE,          %al
    je      .L_read_word_eloop0
    cmp     LINEFEED,       %al
    je      .L_read_word_eloop0
    cmp     TAB,            %al
    je      .L_read_word_eloop0
    mov     %al,            (%r10, %r9)
    inc     %r9
    jmp     .L_read_word_loop0
.L_read_word_eloop0:
    movb    $NULL,          (%r10, %r9)
    dec     %r9
    mov     %r10,           %rax
    ret
.L_read_word_err0:
    xor     %rax,           %rax
    ret

/**
 * parse_uint - Parses an u64 from a string and returns the string char count
 *              and the u64 on %rdx:%rax
 *
 * @str: input number string
 *
 * Return: input string char count on upper 64 bits
 *         and integer parsed on lower 64 bits
 */
parse_uint:
    push    %r12
    mov     $0x0a,          %r12
    mov     $0x01,          %rsi
    xor     %r8,            %r8
    xor     %r9,            %r9
    xor     %r10,           %r10
.L_parse_uint_loop0:
    cmpb    $NULL,          (%rdi, %r10)
    je      .L_parse_uint_eloop0
    cmpb    $0x30,          (%rdi, %r10)
    jl      .L_parse_uint_err
    cmpb    $0x39,          (%rdi, %r10)
    jg      .L_parse_uint_err
    mov     (%rdi, %r10),   %r8b
    sub     $0x30,          %r8b
    mov     %r9,            %rax
    mul     %r12
    add     %r8,            %rax
    mov     %rax,           %r9
    inc     %r10
    jmp     .L_parse_uint_loop0
.L_parse_uint_eloop0:
    pop     %r12
    mov     %r9,            %rax
    mov     %r10,           %rdx
    ret
.L_parse_uint_err:
    pop     %r12
    mov     $-0x01,         %rax
    ret

/**
 * parse_int - Parses an i64 from a string and returns the string char count
 *              and the i64 on %rdx:%rax
 *
 * @str: input number string
 * Return: input string char count on upper 64 bits
 *         and integer parsed on lower 64 bits
 */
parse_int:
    sub     $0x20,          %rsp
    movb    $0x01,          1(%rsp)
    cmpb    $'-',           (%rdi)
    jne     .L_parse_int_non_negative
.L_parse_int_negative:
    movb    $-0x01,         1(%rsp)
    inc     %rdi
.L_parse_int_non_negative:
    call    parse_uint
    cmp     $-0x01,         %rax
    je      .L_parse_int_err
    cmpb    $-0x01,         1(%rsp)
    jne     1f
    neg     %rax
    inc     %rdx
1:
.L_parse_int_err:
    add $0x20,              %rsp
    ret
/**
 * string_equals - Returns 1 if strings are equals, returns 0 otherwise
 *
 * @str0: input string 0
 * @str1: input string 1
 *
 * Return: 1 if string are equals, 0 otherwise
 */
string_equals:
    xor     %r8,            %r8
    xor     %rax,           %rax
    mov     (%rdi, %r8),    %r9b
.L_string_equals_loop0:
    cmp     (%rsi, %r8),    %r9b
    jne     .L_string_equals_not_equals
    cmp     $NULL,          %r9b
    je      .L_string_equals_equals
    inc     %r8
    mov     (%rdi, %r8),    %r9b
    jmp     .L_string_equals_loop0
.L_string_equals_equals:
    inc     %rax
.L_string_equals_not_equals:
    ret

/**
 * string_copy - Copies @str to @buf
 *
 * @str: input string
 * @buf: buffer
 * @buf_size: buffer size
 *
 * Return: @buf address if @str fits on @buf, 0 otherwise
 */
 string_copy:
    xor     %r8,            %r8
    dec     %rdx
.L_string_copy_loop0:
    cmpb    $NULL,          (%rdi, %r8)
    je      .L_string_copy_eloop0
    cmp     %r8,            %rdx
    jle     .L_string_copy_err
    mov     (%rdi, %r8),    %r9b
    mov     %r9b,           (%rsi, %r8)
    inc     %r8
    jmp     .L_string_copy_loop0
.L_string_copy_eloop0:
    movb    $NULL,          (%rsi, %r8)
    mov     %rsi,           %rax
    ret
.L_string_copy_err:
//   + 2xor     %rax,           %rax
//   +  +  +  + 2222ret
     xor    %rax,           %rax
     ret
