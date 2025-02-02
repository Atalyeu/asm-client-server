%include "common.inc"
%include "client.inc"

EXTERN stdin_buffer_ptr
EXTERN send_buffer_ptr

; Data Segment
SECTION .rodata
format1:  db "%.24s: ", 0         

SECTION .data
ticks:     dq 0                    

GLOBAL ticks

; Code Segment
SECTION .text

GLOBAL stdin_listener
stdin_listener:
    push    rbp                      
    mov     rbp, rsp                 
    sub     rsp, 16 

    mov     QWORD [rbp - 8], rdi     

.handle_input:
    mov     rdi, QWORD [stdin_buffer_ptr]
    mov     rsi, BUFFER_SIZE              
    mov     rdx, QWORD [stdin]            
    call    fgets                         

    cmp     rax, 0                        
    je      .handle_input                 

    mov     rdi, 0                        
    call    time                          
    mov     QWORD [ticks], rax           
    mov     rdi, ticks                    
    call    ctime                         

    mov     rdi, QWORD [send_buffer_ptr]  
    mov     rsi, BUFFER_SIZE              
    mov     rdx, format1                  
    mov     rcx, rax  
	xor 	rax, rax                                         
    call    snprintf                      

    mov     rdi, QWORD [send_buffer_ptr] 
    mov     rsi, QWORD [stdin_buffer_ptr]
    call    strcat                       

    mov     rbx, QWORD [rbp - 8]          
    mov     edi, DWORD [rbx]              
    cmp     edi, 0                        
    je      .handle_input                

    mov     rsi, QWORD [send_buffer_ptr]  
    mov     rdx, BUFFER_SIZE             
    call    write                         

    
    jmp     .handle_input

    
    add     rsp, 16                      
    pop     rbp                          
    mov     rax, 0                       
    ret                                  
