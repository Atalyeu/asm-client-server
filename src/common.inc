; Socket and Network Constants

; Socket Types
SOCK_STREAM   equ 1        ; TCP connection
SOCK_DGRAM    equ 2        ; UDP connectionless

; Address Families
AF_INET       equ 2        ; IPv4
AF_INET6      equ 10       ; IPv6


INADDR_ANY    equ 0x00000000
INADDR_BROADCAST equ 0xffffffff 
INADDR_LOOPBACK equ 0x7f000001 

struc sockaddr
    .sa_family:    resw 1    
    .sa_date:      resb 16
endstruc

struc sockaddr_in
    .sin_family:   resw 1    ; Family type (AF_INET)
    .sin_port:     resw 1    ; Port number (network byte order)
    .sin_addr:     resd 1    ; IP address (in network byte order)
    resb 8         ; Padding for alignment
endstruc
