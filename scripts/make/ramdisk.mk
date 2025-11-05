# Ramdisk handling

# Default disk image path
RAMDISK_IMG ?= $(CURDIR)/disk.img
RAMDISK_OBJ ?= $(TARGET_DIR)/$(TARGET)/$(MODE)/ramdisk.o

# Check if driver-ramdisk feature is enabled
HAS_RAMDISK := $(filter driver-ramdisk,$(FEATURES))

ifeq ($(HAS_RAMDISK),driver-ramdisk)
  # Convert disk image to object file with dedicated section
  $(RAMDISK_OBJ): $(RAMDISK_IMG)
	@printf "    $(GREEN_C)Generating$(END_C) ramdisk object file\n"
	@mkdir -p $(dir $(RAMDISK_OBJ))
	@$(OBJCOPY) -I binary -O elf64-littleaarch64 -B aarch64 --rename-section .data=.initrd,alloc,load,contents,readonly "$(RAMDISK_IMG)" "$(RAMDISK_OBJ)"

  # Update rust flags
  RUSTFLAGS += -C link-arg=--whole-archive -C link-arg=$(RAMDISK_OBJ) -C link-arg=--no-whole-archive

  # 确保ramdisk.o被显式添加到链接过程中
  ifeq ($(APP_TYPE), rust)
    rust_elf_deps += $(RAMDISK_OBJ)
  endif

  # Ensure ramdisk target is built before kernel
  _cargo_build: $(RAMDISK_OBJ)
endif