%assign OS_EXIT             1
%assign OS_READ             3
%assign OS_WRITE            4
%assign OS_OPEN             5
%assign OS_CLOSE            6
%assign OS_EXECVE           11
%assign OS_FCNTL            55
%assign OS_DUP2             63
%assign OS_SOCKETCALL       102
%assign OS_POLL             168

%assign STDIN               0
%assign STDOUT              1
%assign STDERR              2

%assign SOCK_OPEN	        1
%assign SOCK_BIND	        2
%assign SOCK_CONNECT	    3
%assign SOCK_LISTEN	        4
%assign SOCK_ACCEPT	        5
%assign SOCK_GETSOCKNAME    6
%assign SOCK_GETPEERNAME	7
%assign SOCK_SOCKETPAIR	    8
%assign SOCK_SEND	        9
%assign SOCK_RECV	        10
%assign SOCK_SENDTO	        11
%assign SOCK_RECVFROM	    12
%assign SOCK_SHUTDOWN	    13
%assign SOCK_SETSOCKOPT	    14
%assign SOCK_GETSOCKOPT	    15
%assign SOCK_SENDMSG	    16
%assign SOCK_RECVMSG	    17
%assign SOCK_ACCEPT4	    18
%assign SOCK_RECVMMSG	    19
%assign SOCK_SENDMMSG	    20

%assign AF_INET             2
%assign SOCK_STREAM         1
;%assign SOCK_DGRAM         0
%assign PROTO_TCP           6
;%assign PROTO_UDP          0

%assign MSG_DONTWAIT        0x40
%assign F_SETFL             0x4
%assign O_NONBLOCK          0x800
%assign POLLIN              0x1



%macro __syscall 1
    mov eax, %1
    int 0x80
%endmacro

%macro os.exit 1
    mov ebx, %1 ;status
    __syscall OS_EXIT
%endmacro

%macro os.read 3
    mov ebx, %1 ;fd
    mov ecx, %2 ;buf
    mov edx, %3 ;count
    __syscall OS_READ
%endmacro

%macro os.write 3
    mov ebx, %1 ;fd
    mov ecx, %2 ;buf
    mov edx, %3 ;count
    __syscall OS_WRITE
%endmacro

%macro os.open 3
    mov ebx, %1 ;path
    mov ecx, %2 ;flags
    mov edx, %3 ;mode
    __syscall OS_OPEN
%endmacro

%macro os.close 1
    mov ebx, %1 ;fd
    __syscall OS_CLOSE
%endmacro

%macro os.sock_open 3
    push %3 ;protocol type
    push %2 ;sock type
    push %1 ;sock domain
    mov ebx, SOCK_OPEN
    mov ecx, esp
    __syscall OS_SOCKETCALL
%endmacro

%macro os.sock_connect 3
    push %3 ;addr len
    push %2 ;ptr to addr struct
    push %1 ;sockfd
    mov ebx, SOCK_CONNECT
    mov ecx, esp
    __syscall OS_SOCKETCALL
%endmacro

%macro os.sock_listen 2
    push %2 ;backlog
    push %1 ;fd
    mov ebx, SOCK_LISTEN
    mov ecx, esp
    __syscall OS_SOCKETCALL
%endmacro

%macro os.sock_bind 3
    push %3 ;addr len
    push %2 ;ptr to addr struct
    push %1 ;fd
    mov ebx, SOCK_BIND
    mov ecx, esp
    __syscall OS_SOCKETCALL
%endmacro

%macro os.sock_accept 3
    push %3 ;addr len
    push %2 ;ptr to addr struct
    push %1 ;fd
    mov ebx, SOCK_ACCEPT
    mov ecx, esp
    __syscall OS_SOCKETCALL
%endmacro

%macro os.sock_send 4
    push %4 ;flags
    push %3 ;len
    push %2 ;buf
    push %1 ;sockfd
    mov ebx, SOCK_SEND
    mov ecx, esp
    __syscall OS_SOCKETCALL
%endmacro

%macro os.sock_recv 4
    push %4 ;flags
    push %3 ;len
    push %2 ;buf
    push %1 ;sockfd
    mov ebx, SOCK_RECV
    mov ecx, esp
    __syscall OS_SOCKETCALL
%endmacro

%macro os.fcntl 3
    mov ebx, %1 ;fd
    mov ecx, %2 ;cmd
    mov edx, %3 ;opt
    __syscall OS_FCNTL
%endmacro

%macro os.poll 3
    mov ebx, %1 ;struct pollfds
    mov ecx, %2 ;nfds
    mov edx, %3 ;timeout in ms
    __syscall OS_POLL
%endmacro

%macro os.dup2 2
    mov ebx, %1 ;dst
    mov ecx, %2 ;src
    __syscall OS_DUP2
%endmacro

%macro os.execve 3
    mov ebx, %1 ;path to cmd
    mov ecx, %2 ;ptr_to_argv
    mov edx, %3 ;ptr_to_envp
    __syscall OS_EXECVE
%endmacro
