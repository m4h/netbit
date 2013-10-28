;   Auth    :   Tom Lime
;   Date    :   07/10/2013
;   Purp    :   study
;   Updt    :   29/10/2013
;   Info    :   Compile $ nasm -felf32 src.asm -o obj.o && ld -melf_i386 obj.o -o elf_exec

%include    "netbit.inc"
%include    "os_linux.inc"


[section .data]
    usage_msg       db  "[USAGE]: [OPTIONS] IP PORT",LF
                    db  0x9,"-l  start listening on PORT",LF
                    db  0x9,"-e  execute shell and transfer control to a socket",LF,NULL
    usage_len       equ $-usage_msg
    shell           db  "/bin/sh",NULL
    opt_list        db  DISABLED
    opt_exec        db  DISABLED
    sockaddr        dd  NULL
    sockport        dw  NULL


[section .bss]
    sockfd          resd 1
    databuf         resb DATALEN


[section .text]
global _start

_start:

    pop     ecx                         ;get parameters count passed
    pop     edx                         ;pop out cmd name
    dec     ecx                         ;disregard cmd name
    cmp     ecx, 2                      ;at least 2 args should be given (cmd ip port)
    jl      usage

    .args:
        pop edx                         ;point to arg
        cmp edx, NULL                   ;jmp to init if no args left
        je .init
        cmp BYTE [edx], '-'             ;parse option started with '-'
        je .l
        cmp BYTE [sockaddr], NULL       ;treat first option not started with '-' as IP address
        je .addr
        cmp BYTE [sockport], NULL       ;treat second option not started with '-' as PORT
        je .port

    .addr:
        push ecx                        ;save argc
        mov esi, edx                    ;load pointer to arg
        lea edi, [sockaddr]             ;load address of [sockaddr] to edi
        mov ecx, 4                      ;number of cycles we need to parse ip in this format '127.0.0.1'
        .next:
            call str2long               ;return BYTE in ebx (as IP addr consists of four BYTES)
            mov [edi], bl               ;place returned BYTE in DWORD
            inc edi                     ;increase address by one BYTE
            loop .next
        pop ecx                         ;restore argc
        jmp .args

    .port:
        mov esi, edx                    ;load pointer to arg
        call str2long                   ;return WORD in ebx (as PORT consists of one WORD)
        xchg bl, bh                     ;swich low register value and high register value (trick to convert port to network order)
        mov [sockport], ebx             ;save PORT to [sockport] variable
        jmp .args

    .l:
        mov ax, [edx+1]                 ;load WORD pointed by [edx+1] to ax
        cmp al, 'l'                     ;check lower register value
        jne .e
        cmp ah, NULL                    ;check if lower register not followed by some character except NULL
        jne usage                       ;in this case option was specified incorrectly
        mov BYTE [opt_list], ENABLED    ;otherwise turn flag on
        jmp .args

    .e:
        mov ax, [edx+1]
        cmp al, 'e'
        jne usage
        cmp ah, NULL
        jne usage
        mov BYTE [opt_exec], ENABLED
        jmp .args

    .init:
        cmp BYTE [sockaddr], NULL                           ;check if IP was passed as arg
        je usage
        cmp BYTE [sockport], NULL                           ;check if PORT was passed as arg
        je usage
        os.sock_open AF_INET, SOCK_STREAM, PROTO_TCP        ;open socket, result returned in eax
        mov DWORD [sockfd], eax
        ;check if success

        os.fcntl STDIN, F_SETFL, O_NONBLOCK                 ;we need non-blocking mode for async session
        os.fcntl DWORD [sockfd], F_SETFL, O_NONBLOCK

        cmp BYTE [opt_list], ENABLED
        je arg_listen
        jmp arg_connect


arg_connect:
    push_sockaddr_in NULL, [sockaddr], [sockport], AF_INET
    mov ebp, esp
    ;check if success
    os.sock_connect DWORD [sockfd], ebp, 16
    call run


arg_exec:
    os.dup2 [sockfd], STDIN
    os.dup2 [sockfd], STDOUT
    os.dup2 [sockfd], STDERR
    os.execve shell, NULL, NULL
    ret


arg_listen:
    push_sockaddr_in NULL, NULL, [sockport], AF_INET
    mov ebp, esp
    ;check if success
    os.sock_bind DWORD [sockfd], ebp, 16

    ;check if success
    os.sock_listen DWORD [sockfd], 1

    push_pollfd POLLIN, [sockfd]
    mov ebp, esp
    os.poll ebp, 1, -1

    ;check if success
    os.sock_accept DWORD [sockfd], NULL, NULL
    mov [sockfd], eax
    call run


run:
    cmp BYTE [opt_exec], ENABLED
    je arg_exec

    xor eax, eax
    xor ebx, ebx

    push_pollfd POLLIN, [sockfd]
    push_pollfd POLLIN, STDIN
    mov ebp, esp
    ;pass struct to poll for two fds; wait 2**32ms
    os.poll ebp, 2, -1

    ;exit if poll returned error
    cmp eax, NULL
    jle .end

    os.read STDIN, databuf, DATALEN-1
    ;determine if data from STDIN is received
    mov ebx, DWORD [sockfd]
    cmp eax, NULL
    jg .write

    os.sock_recv DWORD [sockfd], databuf, DATALEN-1, NULL
    ;determine if data from socket is received
    mov ebx, STDOUT
    cmp eax, NULL
    jg .write

    ;exit if os.sock_recv returned an error
    jle .end

    jmp run

    .write:
        os.write ebx, databuf, eax
        jmp run

    .end:
        os.close DWORD [sockfd]
        os.exit ebx


usage:
    os.write STDERR, usage_msg, usage_len
    os.exit 1


str2long:
    ;esi point to string
    ;ebx return value
    xor eax, eax
    xor ebx, ebx
    .next:
        lodsb
        sub al, '0'
        jb .ret
        add ebx, ebx
        lea ebx, [ebx+ebx*4]
        add ebx, eax
        jmp .next
    .ret:
        ret
