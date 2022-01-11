PYTHON := python3
TEST_RUNNER := tests/runtest.py
TEST_PARAMS := --deferrable --optional
CACHE_DIR := ./cache
COPTS := --nimcache=$(CACHE_DIR)
BIN_NAME := mal
SRC_DIR := src
NIM_SRCS := $(shell find $(SRC_DIR) -type f -iname "*.nim")

TEST0 := tests/tests/step0_repl.mal
TEST1 := tests/tests/step1_read_print.mal
TEST2 := tests/tests/step2_eval.mal
TEST3 := tests/tests/step3_env.mal
TEST4 := tests/tests/step4_if_fn_do.mal
TEST5 := tests/tests/step5_tco.mal
TEST6 := tests/tests/step6_file.mal
TEST7 := tests/tests/step7_quote.mal

build:
	nimble build $(COPTS) $(nim-build-args)

run: build
	LOGGING=debug PERSIST_HISTORY=true ./$(BIN_NAME)

clean:
	rm -rf $(BIN_NAME) $(CACHE_DIR)

format:
	nimpretty $(NIM_SRCS)

watch:
	echo $(NIM_SRCS)| sed -e 's/ /\n/g' | entr -ccrd make build

watch\:test:
	echo $(NIM_SRCS)| sed -e 's/ /\n/g' | entr -ccrd make test


test: test7

test0: build
	$(PYTHON) $(TEST_RUNNER) $(TEST_PARAMS) $(TEST0) -- ./$(BIN_NAME)

test1: build
	$(PYTHON) $(TEST_RUNNER) $(TEST_PARAMS) $(TEST1) -- ./$(BIN_NAME)

test2: build
	$(PYTHON) $(TEST_RUNNER) $(TEST_PARAMS) $(TEST2) -- ./$(BIN_NAME)

test3: build
	$(PYTHON) $(TEST_RUNNER) $(TEST_PARAMS) $(TEST3) -- ./$(BIN_NAME)

test4: build
	$(PYTHON) $(TEST_RUNNER) $(TEST_PARAMS) $(TEST4) -- ./$(BIN_NAME)

test5: build
	$(PYTHON) $(TEST_RUNNER) $(TEST_PARAMS) $(TEST5) -- ./$(BIN_NAME)

test6: build
	$(PYTHON) $(TEST_RUNNER) $(TEST_PARAMS) $(TEST6) -- ./$(BIN_NAME)


test7: build
	$(PYTHON) $(TEST_RUNNER) $(TEST_PARAMS) $(TEST7) -- ./$(BIN_NAME)

