.PHONY: all run lake

all: run

LEAN_SYSROOT ?= $(shell lean --print-prefix)

# Lean libraries in topologically sorted order (i.e., dependent comes before dependency)
DEP_LEAN_LIBS := Mathlib Qq ProofWidgets Aesop Std
LEAN_LIBS := RFFID $(DEP_LEAN_LIBS)

# Link C binary against Lake package dynamic library

LAKE_LIBS := $(addsuffix :shared, $(LEAN_LIBS))
LD_LIBS := $(addprefix -l, $(LEAN_LIBS))
LIB_DIRS := build/lib $(addsuffix /build/lib, $(addprefix lake-packages/, $(DEP_LEAN_LIBS)))
LD_LIB_DIRS := $(addprefix -L, $(LIB_DIRS))

COMMA=,
LINK_PATHS := $(addprefix -Wl$(COMMA)-rpath$(COMMA)$(PWD)/, $(LIB_DIRS))

lake:
	lake build $(LAKE_LIBS)

ifneq ($(OS),Windows_NT)
# Add shared library paths to loader path (no Windows equivalent)
  LINK_FLAGS=-Wl,-rpath,$(LEAN_SYSROOT)/lib/lean -Wl,-rpath,$(LINK_PATHS)
endif

main: main.c lake
# Add library paths for Lake package and for Lean itself
	cc -o $@ $< -I $(LEAN_SYSROOT)/include -L $(LEAN_SYSROOT)/lib/lean $(LD_LIB_DIRS) $(LD_LIBS) -lleanshared $(LINK_FLAGS)

run: main
ifeq ($(OS),Windows_NT)
# Add shared library path to loader path dynamically (`lean`'s directory is already in `PATH`)
	PATH=$(subst $(eval),:,$(LIB_DIRS)):$(PATH) ./main
else
	./main
endif
