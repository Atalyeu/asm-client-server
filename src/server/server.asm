%include "common.inc"
%include "server.inc"

EXTERN stdin_listener

; Data Section
SECTION .rodata
size1:          dd _sockaddr_in_size
error1:         db "Error binding",0
message1:       db "Listening",0
format1:        db "Client %s connected",10,0

; BSS Section
SECTION .bss
listen_fd:      resd 1
connection_fd:  resd 1
stdin_buffer_ptr: resq 1
send_buffer_ptr:  resq 1
receive_buffer_ptr: resq 1
server_address:  resb _sockaddr_in_size

GLOBAL stdin_buffer_ptr
GLOBAL send_buffer_ptr

; Code Section
SECTION .text

GLOBAL main
main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32

    ; Initialize buffers
    mov     rdi, BUFFER_SIZE
    mov     rsi, 1
    call    calloc
    mov     QWORD [stdin_buffer_ptr], rax

    mov     rdi, BUFFER_SIZE
    mov     rsi, 1
    call    calloc
    mov     QWORD [send_buffer_ptr], rax

    mov     rdi, BUFFER_SIZE
    mov     rsi, 1
    call    calloc
    mov     QWORD [receive_buffer_ptr], rax

    ; Zero out server address
    mov     rdi, server_address
    mov     rsi, 0
    mov     rdx, _sockaddr_in_size
    call    memset

    ; Handle user input in a separate thread
    lea     rdi, [rbp - 0]
    mov     rsi, 0
    mov     rdx, stdin_listener
    mov     rcx, connection_fd
    call    pthread_create
    mov     rdi, rax
    call    pthread_detach

    ; Create socket
    mov     rdi, _AF_INET
    mov     rsi, _SOCK_STREAM
    mov     rdx, 0
    call    socket
    mov     DWORD [listen_fd], eax

    ; Configure server address
    mov     WORD [server_address + _sockaddr_in.sin_family], _AF_INET
    mov     rdi, PORT
    call    htons
    mov     WORD [server_address + _sockaddr_in.sin_port], ax
    mov     DWORD [server_address + _sockaddr_in.sin_addr], _INADDR_ANY

    ; Bind the socket to the address
    mov     edi, DWORD [listen_fd]
    mov     rsi, server_address
    mov     rdx, _sockaddr_in_size
    call    bind
    cmp     eax, 0
    jge     .bind_continue

    ; Error binding
    .bind_error:
        mov     rdi, error1
        call    puts
        jmp     .exit

    .bind_continue:
    ; Listen for incoming connections
    mov     edi, DWORD [listen_fd]
    mov     rsi, MAX_CONNECTIONS
    call    listen
    mov     rdi, message1
    call    puts

    ; Connection handling loop
    .connect_loop:
        ; Accept a connection
        mov     edi, DWORD [listen_fd]
        mov     rsi, 0
        mov     rdx, 0
        call    accept
        mov     DWORD [connection_fd], eax

        ; Resolve IP address of the client
        mov     edi, eax
        lea     rsi, [rbp - 16]
        mov     rdx, size1
        call    getpeername
        mov     rdi, [rbp - (16 - _sockaddr_in.sin_addr)]
        call    inet_ntoa
        mov     rdi, format1
        mov     rsi, rax
        call    printf

        ; Read data from client
        .read_client:
            mov     rdi, QWORD [connection_fd]
            mov     rsi, QWORD [receive_buffer_ptr]
            mov     rdx, BUFFER_SIZE - 1
            call    read
            cmp     rax, 0
            jle     .read_client
            mov     rbx, QWORD [receive_buffer_ptr]
            mov     BYTE [rbx + rax], 0
            mov     rdi, QWORD [receive_buffer_ptr]
            mov     rsi, QWORD [stdout]
            call    fputs
            jmp     .read_client

    .read_client_end:
        ; Close connection and repeat
        mov     edi, DWORD [connection_fd]
        call    close
        jmp     .connect_loop

    .exit:
        ; Free allocated memory
        mov     rdi, QWORD [stdin_buffer_ptr]
        call    free
        mov     rdi, QWORD [send_buffer_ptr]
        call    free
        mov     rdi, QWORD [receive_buffer_ptr]
        call    free

        add     rsp, 32
        pop     rbp
        mov     rax, 60
        syscall
