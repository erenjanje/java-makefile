# Constants and Logic
TRUE := T
FALSE :=
NOT = $(if $1,$(FALSE),$(TRUE))
EMPTY :=
BACKSLASH := \$(EMPTY)
QUOTE := "

# Helper functions
rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))
makewithdirext=$(patsubst $2%$3,$4%$5,$1)
makeclass=$(call makewithdirext,$1,$(SRCDIR),$(SRC_EXTENSION),$(BUILDDIR),$(CLASS_EXTENSION))
map=$(foreach e,$2,$(call $1,$e))

# OS-specific variables and functions
ifeq ($(OS),Windows_NT)

IS_WINDOWS := $(TRUE)
MKDIR = $(if $1,if not exist $(QUOTE)$1$(QUOTE) mkdir $(QUOTE)$1$(QUOTE))
REMOVE = $(if $1,del /Q "$(call backslashize,$1)")
ECHO = $(if $1,echo $1,echo.)
TOUCH = type nul >>"$(call backslashize,$1)" & copy "$(call backslashize,$1)" +,, >nul
EXEC_EXTENSION := .jar
backslashize = $(subst /,$(BACKSLASH),$1)

else

IS_WINDOWS := $(FALSE)
MKDIR = $(if $1,mkdir -p "$1")
REMOVE = $(if $1,rm -rf "$1")
ECHO = echo "$1"
TOUCH = touch $1
EXEC_EXTENSION := .jar
backslashize = $1

endif

# Programs
COMPILER := javac
EMPTY_ECHO := echo ""
RUNNER :=

# Extensions
SRC_EXTENSION := .java
CLASS_EXTENSION := .class

# Directories
SRCDIR :=
BUILDDIR := build/
BINDIR := bin/

# Output Options
MAIN_CLASS := app.test.test
JARNAME := main
ARGS := 

# Files
SRCS := $(call rwildcard,$(SRCDIR),*$(SRC_EXTENSION))
DIRS := $(sort $(dir $(SRCS)))
OBJECT_DIRS := $(DIRS:$(SRCDIR)%=$(CLASSDIR)%)
EXECUTABLE := $(BINDIR)$(JARNAME).jar

# Compiler options
DEBUG := $(TRUE)

# Processed files
CLASSES = $(call rwildcard,$(BUILDDIR),*$(CLASS_EXTENSION))
COMPILED_CLASSES := $(call map,makeclass,$(SRCS))

run: $(EXECUTABLE)
	@$(call ECHO,RUNNING $(EXECNAME))
	@$(call ECHO,===================)
	@$(call ECHO,)
	@java -jar $(EXECUTABLE) $(ARGS)
.PHONY: run

$(EXECUTABLE): $(COMPILED_CLASSES)
	@$(call ECHO,LINKING $(EXECNAME))
	@cd $(BUILDDIR) && jar -c -e $(MAIN_CLASS) -f ../$(EXECUTABLE) $(patsubst $(BUILDDIR)%,%,$(CLASSES))

build: $(EXECUTABLE)
.PHONY: build

all: build
.PHONY: all

clean:
	@echo RM $(CLASSES)
	@$(foreach o,$(CLASSES),$(call REMOVE,$o))
.PHONY: clean

$(BUILDDIR)%.class: $(SRCDIR)%.java
	@$(call ECHO,COMPILE $<)
	@$(COMPILER) -d $(BUILDDIR) $<

debug:
	@$(call ECHO,$(SRCS))
.PHONY: debug
