### Configurable ###
SERVER  := server
CLIENT  := client

### Directories ###
SRC_DIR        := src
BIN_DIR        := bin
SERVER_DIR     := $(BIN_DIR)/$(SERVER)
CLIENT_DIR     := $(BIN_DIR)/$(CLIENT)

### Toolchain ###
CC      := gcc
AS      := nasm
LINKER  := g++

### Flags ###
CFLAGS  := -Wall
ASFLAGS := -f elf64 -i $(SRC_DIR)
ASFLAGS += -F dwarf -g
LINK_FLAGS := -no-pie -pthread

### Main ###
.DEFAULT_GOAL := all

.PHONY: all setup clean run-server run-client

all: setup $(SERVER) $(CLIENT)

# Setup Directories
setup:
	@mkdir -p $(SERVER_DIR) $(CLIENT_DIR)

# Clean Targets
clean: clean-server clean-client

clean-server:
	rm -rf $(SERVER_DIR)/*.o $(SERVER_DIR)/*.so $(SERVER_DIR)/*.elf

clean-client:
	rm -rf $(CLIENT_DIR)/*.o $(CLIENT_DIR)/*.so $(CLIENT_DIR)/*.elf

# Run Targets
run-server:
	./$(SERVER_DIR)/$(SERVER).elf

run-client:
	./$(CLIENT_DIR)/$(CLIENT).elf

### Server Target ###
SERVER_SOURCES := $(wildcard $(SRC_DIR)/$(SERVER)/*.asm)
SERVER_TARGETS := $(addprefix $(SERVER_DIR)/, $(addsuffix .o, $(basename $(notdir $(SERVER_SOURCES))))))

$(SERVER): $(SERVER_TARGETS) $(SERVER_SOURCES)
	$(LINKER) $(LINK_FLAGS) $(SERVER_TARGETS) -o $(SERVER_DIR)/$@.elf

### Client Target ###
CLIENT_SOURCES := $(wildcard $(SRC_DIR)/$(CLIENT)/*.asm)
CLIENT_TARGETS := $(addprefix $(CLIENT_DIR)/, $(addsuffix .o, $(basename $(notdir $(CLIENT_SOURCES))))))

$(CLIENT): $(CLIENT_TARGETS) $(CLIENT_SOURCES)
	$(LINKER) $(LINK_FLAGS) $(CLIENT_TARGETS) -o $(CLIENT_DIR)/$@.elf

### Rules for Compilation ###
$(SERVER_DIR)/%.o: $(SRC_DIR)/$(SERVER)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(SERVER_DIR)/%.o: $(SRC_DIR)/$(SERVER)/%.asm
	$(AS) $(ASFLAGS) $< -o $@

$(CLIENT_DIR)/%.o: $(SRC_DIR)/$(CLIENT)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(CLIENT_DIR)/%.o: $(SRC_DIR)/$(CLIENT)/%.asm
	$(AS) $(ASFLAGS) $< -o $@
