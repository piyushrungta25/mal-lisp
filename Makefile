PYTHON := python3
TEST_RUNNER := tests/runtest.py
TEST_PARAMS := --deferrable --optional
CACHE_DIR := ./cache
COPTS := --nimcache=$(CACHE_DIR)
BIN_NAME := mal
SRC_DIR := src
NIM_SRCS := $(shell find $(SRC_DIR) -type f -iname "*.nim")


TEST0 := tests/tests/step0_repl.mal

build:
	nimble build $(COPTS) $(nim-build-args)

run: build
	./$(BIN_NAME)

clean:
	rm -rf $(BIN_NAME) $(CACHE_DIR)

format:
	nimpretty $(NIM_SRCS)

watch:
	echo $(NIM_SRCS)| sed -e 's/ /\n/g' | entr -crd make build

test: test0

test0: build
	$(PYTHON) $(TEST_RUNNER) $(TEST_PARAMS) $(TEST0) -- ./$(BIN_NAME)

