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
	@$(OBJCOPY) -I binary -O elf64-aarch64 -B aarch64 --rename-section .data=.initrd,alloc,load,contents,readonly "$(RAMDISK_IMG)" "$(RAMDISK_OBJ)"

  # 直接传递ramdisk.o文件路径，这是最可靠的方式
  RAMDISK_LDFLAGS := -Clink-arg="$(RAMDISK_OBJ)"

  # Update rust flags
  RUSTFLAGS += $(RAMDISK_LDFLAGS)

  # Ensure ramdisk target is built before kernel
  _cargo_build: $(RAMDISK_OBJ)
endif