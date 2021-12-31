PYTHON := python3
TEST_RUNNER := tests/runtest.py
TEST_PARAMS := --deferrable --optional
BIN_NAME := mal

TEST0 := tests/tests/step0_repl.mal

build:
	nimble build $(nim-build-args)

run: build
	./$(BIN_NAME)

clean:
	rm -rf $(BIN_NAME)

test0: build
	$(PYTHON) $(TEST_RUNNER) $(TEST_PARAMS) $(TEST0) -- ./$(BIN_NAME)

