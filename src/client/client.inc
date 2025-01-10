DEFAULT  rel

; Buffer and Network Configuration
%define BUFFER_SIZE      1000   ; Maximum size for input buffe
%define SERVER_PORT      5000   ; Port number for the server

; External References
EXTERN   socket
EXTERN   bind
EXTERN   listen
EXTERN   accept
EXTERN   connect
EXTERN   htons
EXTERN   inet_pton
EXTERN   getpeername
EXTERN   inet_ntoa
EXTERN   close
EXTERN   calloc
EXTERN   free
EXTERN   memset
EXTERN   strlen
EXTERN   snprintf
EXTERN   strcat
EXTERN   fgets
EXTERN   read
EXTERN   write
EXTERN   fputs
EXTERN   time
EXTERN   ctime
EXTERN   pthread_create
EXTERN   pthread_detach
EXTERN   puts
EXTERN   printf
EXTERN   stdin
EXTERN   stdout
