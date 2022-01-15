.ONESHELL:

ROOT_DIR := $(shell git rev-parse --show-toplevel)
PYTHON := python3
TEST_RUNNER := $(ROOT_DIR)/tests/runtest.py
TEST_PARAMS := --deferrable --optional
CACHE_DIR := $(ROOT_DIR)/cache
COPTS := --nimcache=$(CACHE_DIR)
BIN_NAME := $(ROOT_DIR)/mal
SRC_DIR := $(ROOT_DIR)/src
NIM_SRCS := $(shell find $(SRC_DIR) -type f -iname "*.nim")
MAL_IMPL_DIR := $(ROOT_DIR)/tests/mal
RUN_TEST_CMD := $(PYTHON) $(TEST_RUNNER) $(TEST_PARAMS)
TESTS_DIR := $(ROOT_DIR)/tests/tests

STEP_FILE_0 := step0_repl.mal
STEP_FILE_1 := step1_read_print.mal
STEP_FILE_2 := step2_eval.mal
STEP_FILE_3 := step3_env.mal
STEP_FILE_4 := step4_if_fn_do.mal
STEP_FILE_5 := step5_tco.mal
STEP_FILE_6 := step6_file.mal
STEP_FILE_7 := step7_quote.mal
STEP_FILE_8 := step8_macros.mal
STEP_FILE_9 := step9_try.mal
STEP_FILE_A := stepA_mal.mal


build:
	cd $(ROOT_DIR)
	nimble build $(COPTS) $(nim-build-args)

run: build
	LOGGING=debug PERSIST_HISTORY=true $(BIN_NAME)

clean:
	rm -rf $(BIN_NAME) $(CACHE_DIR)

format:
	nimpretty $(NIM_SRCS)

watch:
	echo $(NIM_SRCS)| sed -e 's/ /\n/g' | entr -ccrd make build

watch\:test:
	echo $(NIM_SRCS)| sed -e 's/ /\n/g' | entr -ccrd make test


test: build
	cd $(TESTS_DIR)
	$(RUN_TEST_CMD) $(STEP_FILE_0) -- $(BIN_NAME)
	$(RUN_TEST_CMD) $(STEP_FILE_1) -- $(BIN_NAME)
	$(RUN_TEST_CMD) $(STEP_FILE_2) -- $(BIN_NAME)
	$(RUN_TEST_CMD) $(STEP_FILE_3) -- $(BIN_NAME)
	$(RUN_TEST_CMD) $(STEP_FILE_4) -- $(BIN_NAME)
	$(RUN_TEST_CMD) $(STEP_FILE_5) -- $(BIN_NAME)
	$(RUN_TEST_CMD) $(STEP_FILE_6) -- $(BIN_NAME)
	$(RUN_TEST_CMD) $(STEP_FILE_7) -- $(BIN_NAME)
	$(RUN_TEST_CMD) $(STEP_FILE_8) -- $(BIN_NAME)
	$(RUN_TEST_CMD) $(STEP_FILE_9) -- $(BIN_NAME)
	$(RUN_TEST_CMD) $(STEP_FILE_A) -- $(BIN_NAME)


test\:selfhosted: build
	cd $(MAL_IMPL_DIR)
	$(RUN_TEST_CMD) "$(TESTS_DIR)/$(STEP_FILE_0)" -- $(BIN_NAME) $(MAL_IMPL_DIR)/$(STEP_FILE_0)
	$(RUN_TEST_CMD) "$(TESTS_DIR)/$(STEP_FILE_1)" -- $(BIN_NAME) $(MAL_IMPL_DIR)/$(STEP_FILE_1)
	$(RUN_TEST_CMD) "$(TESTS_DIR)/$(STEP_FILE_2)" -- $(BIN_NAME) $(MAL_IMPL_DIR)/$(STEP_FILE_2)
	$(RUN_TEST_CMD) "$(TESTS_DIR)/$(STEP_FILE_3)" -- $(BIN_NAME) $(MAL_IMPL_DIR)/$(STEP_FILE_3)
	$(RUN_TEST_CMD) "$(TESTS_DIR)/$(STEP_FILE_4)" -- $(BIN_NAME) $(MAL_IMPL_DIR)/$(STEP_FILE_4)
	$(RUN_TEST_CMD) "$(TESTS_DIR)/$(STEP_FILE_6)" -- $(BIN_NAME) $(MAL_IMPL_DIR)/$(STEP_FILE_6)
	$(RUN_TEST_CMD) "$(TESTS_DIR)/$(STEP_FILE_7)" -- $(BIN_NAME) $(MAL_IMPL_DIR)/$(STEP_FILE_7)
	$(RUN_TEST_CMD) "$(TESTS_DIR)/$(STEP_FILE_8)" -- $(BIN_NAME) $(MAL_IMPL_DIR)/$(STEP_FILE_8)
	$(RUN_TEST_CMD) "$(TESTS_DIR)/$(STEP_FILE_9)" -- $(BIN_NAME) $(MAL_IMPL_DIR)/$(STEP_FILE_9)
	$(RUN_TEST_CMD) "$(TESTS_DIR)/$(STEP_FILE_A)" -- $(BIN_NAME) $(MAL_IMPL_DIR)/$(STEP_FILE_A)

