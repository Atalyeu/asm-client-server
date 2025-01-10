# asm-client-server

This project is a final assignment for my 11th-grade Bagrut. It demonstrates a socket-based client-server application written in Assembly (x86_32) with some integration of C. The application allows for basic communication over a network using sockets.

### Features:
- **Client-Server Communication**: Establishes a connection between a client and a server.
- **Socket Operations**: Includes creating sockets, connecting, sending, and receiving data.
- **Error Handling**: Implements error handling for issues like failed connections and read errors.

### Prerequisites:
To build and run this project, you'll need:
- A **Linux** environment.
- **NASM** (Netwide Assembler) installed for assembly code.
- **GCC** (GNU Compiler Collection) or **G++** (GNU C++ Compiler) for linking C code and compiling.
  
### How to Build and Run:

### 1. **Clone the Repository** (or download the source code):
   ```bash
   git clone <repository-url>
   cd asm-client-server
```

#### Step 2: Install Dependencies (if necessary)
Install the necessary tools on your system. On Ubuntu/Debian-based systems:
```bash
sudo apt-get install gcc nasm g++
```

#### Step 3: Build the Project
Use `make` to compile the client and server:


#### Step 4: Run the Client and Server
1. Open a terminal and run the server:
```bash
make run-server
make run-client
```


#### Step 5: Clean Up (optional)
After running the program, you can clean up the build files to free up space:
```bash
make clean
```
