
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 section .data
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

MAX_PWD_SIZE        equ 9
MAX_PWD_IDX         equ 3
PASSWORD_CHECK      db 0, 0, 0, 0, 0, 3, 3, 0, 0

password            times MAX_PWD_SIZE      db 0
password_charset                            db 0, 1, 2, 3
pwdgen_idx          times MAX_PWD_SIZE      db 0

msg                 times MAX_PWD_SIZE+3    db 0

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 section .bss
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 section .text
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

global _start

;---------------------------------------------------------------------------
_start:
;---------------------------------------------------------------------------

    call check_passwords
    ; call check_one_password

;---------------------------------------------------------------------------
exit:
;---------------------------------------------------------------------------
    mov rdi, rax
    mov rax, 60 ; syscall exit
    syscall

;============================================================================
;  FUNCTIONS
;============================================================================

;---------------------------------------------------------------------------
 check_one_password:
;---------------------------------------------------------------------------

    push rcx 
    push rsi
    push rdi

    mov rcx, MAX_PWD_SIZE
    lea rsi, [PASSWORD_CHECK]
    lea rdi, [password]
    rep movsb

    pop rdi
    pop rsi
    pop rcx

    call check_password

    ret

;---------------------------------------------------------------------------
 check_passwords:
;---------------------------------------------------------------------------
    ; generates and check all combinations
    xor r15, r15 ; nb of combinations

.start:
    lea rdx, [MAX_PWD_SIZE - 1] 

.loop:
    inc r15
    call generate_password
    call check_password
    or rax, rax
    je .found_password

.continue:
    inc byte[pwdgen_idx+rdx]
    cmp byte[pwdgen_idx+rdx], MAX_PWD_IDX
    je .inc_unit2
    jmp .loop

.inc_unit2:
    sub rdx, 1
    cmp rdx, -1 ; all combinaisons generated ?
    je .end_loop
    inc byte[pwdgen_idx+rdx]
    cmp byte[pwdgen_idx+rdx], MAX_PWD_IDX
    ja .inc_unit2

    lea rax, [rdx + 1]
.loop_unit2:
    mov byte [pwdgen_idx+rax], 0
    inc al
    cmp al, MAX_PWD_SIZE
    jne .loop_unit2

    jmp .start

.found_password:
    call print_password
    jmp .continue

.end_loop:
    ret

;---------------------------------------------------------------------------
 generate_password:
;---------------------------------------------------------------------------

    push rax
    push rbx
    push rcx 
    push rsi
    push rdi

    mov rcx, MAX_PWD_SIZE
    lea rsi, [pwdgen_idx]
    lea rdi, [password]
.loop:
    lodsb
    mov bl, byte [password_charset+rax]
    mov al, bl
    stosb
    loop .loop

    pop rdi
    pop rsi
    pop rcx
    pop rbx
    pop rax

    ret

;---------------------------------------------------------------------------
 check_password:
;---------------------------------------------------------------------------

    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9

    ; al ah bh bl ch cl dh dl r8b
    ;  a  b  c  
    lea rsi, [password]

.check1:
    mov al, byte [rsi]
    mov cl, al
    mov al, byte [rsi+1]
    add al, cl
    mov cl, al
    mov al, byte [rsi+2]
    add al, cl
    mov cl, al
    mov al, byte [rsi+3]
    add al, cl
    and al, 3
    mov cl, al
    mov al, byte [rsi+4]
    and al, 3
    cmp al, cl
    jne .password_not_ok

.check2:
    mov al, byte [rsi+5]
    xor al, 3
    mov cl, al
    and al, 1
    mov bl, al
    mov al, byte [rsi]
    and al, 1
    add al, bl
    mov bl, al
    mov al, byte [rsi]
    shr al, 1
    and al, 1
    add al, bl
    and al, 1
    jne .password_not_ok

.check3:
    mov al, cl
    shr al, 1
    and al, 1
    mov bl, al
    mov al, byte [rsi+1]
    and al, 1
    add al, bl
    mov bl, al
    mov al, byte [rsi+1]
    shr al, 1
    and al, 1
    add al, bl
    and al, 1
    jne .password_not_ok

.check4:
    mov al, byte [rsi+6]
    xor al, 3
    mov cl, al
    and al, 1
    mov bl, al
    mov al, byte [rsi+2]
    and al, 1
    add al, bl
    mov bl, al
    mov al, byte [rsi+2]
    shr al, 1
    and al, 1
    add al, bl
    and al, 1
    jne .password_not_ok

.check5:
    mov al, cl
    shr al, 1
    and al, 1
    mov bl, al
    mov al, byte [rsi+3]
    and al, 1
    add al, bl
    mov bl, al
    mov al, byte [rsi+3]
    shr al, 1
    and al, 1
    add al, bl
    and al, 1
    jne .password_not_ok

    mov rdx, 0
    mov cl, 0
.check6:
    mov al, byte [rsi+rdx]
    inc rdx
    add al, cl
    mov cl, al
    mov r8, rdx
    and r8, 8
    jz .check6
    mov al, cl
    and al, 3
    mov cl, al
    mov al, byte [rsi+rdx]
    and al, 3
    cmp al, cl
    jne .password_not_ok

.password_ok:
    mov rax, 0
    jmp .end

.password_not_ok:
    mov rax, 1

.end:
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

;---------------------------------------------------------------------------
 print_password:
;---------------------------------------------------------------------------

    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    push r15

    mov rcx, MAX_PWD_SIZE
    lea rsi, [password]
    lea rdi, [msg]
.loop:
    lodsb
    cmp al,0
    jne .case1
    mov al, 0x4A    ; 'J'
    jmp .continue
.case1:
    cmp al,1
    jne .case2
    mov al, 0x54    ; 'T'
    jmp .continue
.case2:
    cmp al,2
    jne .case3
    mov al, 0x42    ; 'B'
    jmp .continue
.case3:
    cmp al,3
    mov al, 0x44    ; 'D'
.continue:
    stosb
    loop .loop

    mov byte [msg + MAX_PWD_SIZE], 0x0A

    mov rdi, rax
    mov rax, 1                      ; syscall write
    mov rdi, 1                      ; file descriptor (sysout)
    lea rsi, [msg]                  ; buffer to print
    mov rdx, MAX_PWD_SIZE+1         ; buffer len
    syscall

    pop r15
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax

    ret