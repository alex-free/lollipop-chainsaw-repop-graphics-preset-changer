# EzRe v1.0.2 GNUMakefile for Linux/Windows by Alex Free

include variables.mk

COMPILER_FLAGS+=-DVERSION=\"$(VERSION)\"

$(PROGRAM): clean
	mkdir -p $(BUILD_DIR)

# OPTIONAL, not default: Build C libraries to be used by the target executable. To enable this, you must replace `library-file*` with the actual name of the library, and you must set `BUILD_LIB=YES` in `variables.mk`.
ifeq ("$(BUILD_LIB)","YES")
	$(COMPILER) $(COMPILER_FLAGS_LIB) -c library-files-dir/library-file.c -o $(BUILD_DIR)/library-file-object.o
	$(AR) rcs $(BUILD_DIR)/library-file-archive.a $(BUILD_DIR)/library-file-object.o

ifeq ($(strip $(EXECUTABLE_NAME)),)
	$(COMPILER) $(COMPILER_FLAGS) $(SOURCE_FILES) -L./$(BUILD_DIR) -llibrary-file -o $(BUILD_DIR)/$(PROGRAM)
else
	$(COMPILER) $(COMPILER_FLAGS) $(SOURCE_FILES) -L./$(BUILD_DIR) -llibrary-file -o $(BUILD_DIR)/$(EXECUTABLE_NAME)
endif

else # Default: Does not build any C libraries. `BUILD_LIB=NO` in `variables.mk`.

ifeq ($(strip $(EXECUTABLE_NAME)),)
	$(COMPILER) $(COMPILER_FLAGS) $(SOURCE_FILES) -o $(BUILD_DIR)/$(PROGRAM)
else
	$(COMPILER) $(COMPILER_FLAGS) $(SOURCE_FILES) -o $(BUILD_DIR)/$(EXECUTABLE_NAME)
endif

endif

.PHONY: deps-apt
deps-apt:
	sudo apt update
	sudo apt install --yes $(BUILD_DEPENDS_APT)

.PHONY: deps-dnf
deps-dnf:
	sudo dnf update
	sudo dnf -y install  $(BUILD_DEPENDS_DNF)

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)/$(PROGRAM).exe $(BUILD_DIR)/$(PROGRAM) $(BUILD_DIR)/*.o $(BUILD_DIR)/*.a

.PHONY: clean-build
clean-build:
	rm -rf $(BUILD_DIR)

.PHONY: windows-x86_64
windows-x86_64: clean
	make $(PROGRAM) COMPILER=$(WINDOWS_X86_64_COMPILER) EXECUTABLE_NAME='$(PROGRAM).x86_64.exe' AR=$(WINDOWS_X86_64_AR)

.PHONY: release
release:
	rm -rf $(BUILD_DIR)/$(RELEASE_BASE_NAME)-$(VERSION)-$(PLATFORM) $(BUILD_DIR)/$(PROGRAM)-$(VERSION)-$(PLATFORM).zip
	mkdir $(BUILD_DIR)/$(RELEASE_BASE_NAME)-$(VERSION)-$(PLATFORM)
ifeq ($(strip $(WINDOWS_RELEASE)),)
	cp $(BUILD_DIR)/$(EXECUTABLE_NAME) $(BUILD_DIR)/$(PROGRAM)
	cp -r $(BUILD_DIR)/$(PROGRAM) $(RELEASE_FILES) $(BUILD_DIR)/$(RELEASE_BASE_NAME)-$(VERSION)-$(PLATFORM)
else
	cp $(BUILD_DIR)/$(EXECUTABLE_NAME) $(BUILD_DIR)/$(PROGRAM).exe
	cp -r $(BUILD_DIR)/$(PROGRAM).exe $(RELEASE_FILES) $(BUILD_DIR)/$(RELEASE_BASE_NAME)-$(VERSION)-$(PLATFORM)
endif
	chmod -R 777 $(BUILD_DIR)/$(RELEASE_BASE_NAME)-$(VERSION)-$(PLATFORM)
	cd $(BUILD_DIR) && zip -rq $(RELEASE_BASE_NAME)-$(VERSION)-$(PLATFORM).zip $(RELEASE_BASE_NAME)-$(VERSION)-$(PLATFORM)
	rm -rf $(BUILD_DIR)/$(RELEASE_BASE_NAME)-$(VERSION)-$(PLATFORM)

.PHONY: windows-x86_64-release
windows-x86_64-release: windows-x86_64
ifeq ($(strip $(WINDOWS_SPECIFIC_RELEASE_FILES)),)
	make release PLATFORM='$(WINDOWS_X86_64_RELEASE_NAME_SUFFIX)' EXECUTABLE_NAME='$(PROGRAM).x86_64.exe' WINDOWS_RELEASE=true
else
	make release PLATFORM='$(WINDOWS_X86_64_RELEASE_NAME_SUFFIX)' RELEASE_FILES='$(WINDOWS_SPECIFIC_RELEASE_FILES) $(RELEASE_FILES)' EXECUTABLE_NAME='$(PROGRAM).x86_64.exe' WINDOWS_RELEASE=true
endif

.PHONY: all
all:
	make clean-build
	make windows-x86_64-release
	make clean