%include "common.inc"
%include "client.inc"

EXTERN stdin_listener

; Data Segment
SECTION .rodata
    size1:          dd _sockaddr_in_size
    error1:         db "Error: inet_pton", 0
    error2:         db "Error: Connection failed", 0
    error3:         db "Read error", 0
    ip_address:     db "127.0.0.1", 0
    format1:        db "Connected to server %s", 10, 0

SECTION .data
    socket_fd:          dd 0
    stdin_buffer_ptr:   dq 0
    send_buffer_ptr:    dq 0
    receive_buffer_ptr: dq 0
    server_address:     times _sockaddr_in_size db 0

GLOBAL stdin_buffer_ptr
GLOBAL send_buffer_ptr

; Code Segment
SECTION .text

GLOBAL main
main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32

    ; Initialize variables
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

    mov     rdi, server_address
    mov     rsi, 0
    mov     rdx, _sockaddr_in_size
    call    memset

    ; Handle user input in a separate thread
    lea     rdi, [rbp - 0]
    mov     rsi, 0
    mov     rdx, stdin_listener
    mov     rcx, socket_fd
    call    pthread_create
    mov     rdi, rax
    call    pthread_detach

    ; Create socket
    mov     rdi, _AF_INET
    mov     rsi, _SOCK_STREAM
    mov     rdx, 0
    call    socket
    mov     DWORD [socket_fd], eax

    ; Configure server(remote) address
    mov     WORD [server_address + _sockaddr_in.sin_family], _AF_INET
    mov     rdi, SERVER_PORT
    call    htons
    mov     WORD [server_address + _sockaddr_in.sin_port], ax
    mov     DWORD [server_address + _sockaddr_in.sin_addr], _INADDR_ANY

    mov     rdi, _AF_INET
    mov     rsi, ip_address
    mov     rdx, server_address + _sockaddr_in.sin_addr
    call    inet_pton
    cmp     rax, 0
    jg      .inet_pton_continue

.inet_pton_error:
    push    ax
    mov     rdi, error1
    call    puts
    jmp     .exit

.inet_pton_continue:
    ; Connect to the socket
    mov     edi, DWORD [socket_fd]
    mov     rsi, server_address
    mov     edx, _sockaddr_in_size
    call    connect
    cmp     rax, 0
    jge     .connect_continue

.connect_error:
    push    ax
    mov     rdi, error2
    call    puts
    jmp     .exit

.connect_continue:
    ; Resolve the IP address of the connection
    mov     edi, DWORD [socket_fd]
    lea     rsi, [rbp - 16]
    mov     rdx, size1
    call    getpeername
    mov     rdi, [rbp - (16 - _sockaddr_in.sin_addr)]
    call    inet_ntoa
    mov     rdi, format1
    mov     rsi, rax
    mov     rax, 0
    call    printf

    ; Read the socket and write to the receive buffer
.buffer_loop:
    mov     edi, DWORD [socket_fd]
    mov     rsi, QWORD [receive_buffer_ptr]
    mov     rdx, BUFFER_SIZE - 1
    call    read
    cdqe
    cmp     rax, 0
    jle     .buffer_exit
    mov     rbx, [receive_buffer_ptr]
    mov     BYTE [rbx + rax], 0
    mov     rdi, QWORD [receive_buffer_ptr]
    mov     rsi, QWORD [stdout]
    call    fputs
    cmp     eax, -1
    jne     .fputs_continue

.fputs_error:
    mov     rdi, error2
    call    puts

.fputs_continue:
    jmp     .buffer_loop

.buffer_exit:
    cmp     rax, 0
    jge     .read_continue

.read_error:
    push    1
    mov     rdi, error3
    call    puts
    jmp     .exit

.read_continue:
    push    BYTE 0

.exit:
    mov     rdi, QWORD [stdin_buffer_ptr]
    call    free
    mov     rdi, QWORD [send_buffer_ptr]
    call    free
    mov     rdi, QWORD [receive_buffer_ptr]
    call    free
    pop     di
    add     rsp, 32
    pop     rbp
    mov     rax, 60
    syscall
