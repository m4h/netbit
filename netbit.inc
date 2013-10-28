%assign DATALEN     1024
%assign NULL        0x0
%assign DISABLED    0x0
%assign ENABLED     0x1
%assign LF          0xa

%macro push_sockaddr_in 4
    push BYTE   %1  ;padding
    push DWORD  %2  ;ip
    push WORD   %3  ;port
    push WORD   %4  ;domain
%endmacro

%macro push_pollfd 2
    push DWORD %1 ;events
    push DWORD %2 ;fd
%endmacro
