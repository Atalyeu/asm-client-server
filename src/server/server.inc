DEFAULT rel

; Buffer and Network Configuration
%define BUFFER_SIZE       1000          ; Maximum size for input buffer
%define PORT              5000          ; Port number for the server
%define MAX_CONNECTIONS   2             ; Maximum number of connections allowed

; External References
EXTERN puts
EXTERN calloc
EXTERN free
EXTERN memset
EXTERN socket
EXTERN htons
EXTERN bind
EXTERN listen
EXTERN accept
EXTERN close
EXTERN time
EXTERN ctime
EXTERN strlen
EXTERN snprintf
EXTERN printf
EXTERN write
EXTERN getpeername
EXTERN inet_ntoa
EXTERN pthread_create
EXTERN pthread_detach
EXTERN fgets
EXTERN strcat
EXTERN read
EXTERN fputs
EXTERN stdin
EXTERN stdout


