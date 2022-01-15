# mal

Mal Lisp intrepretor following the [kanaka/mal](https://github.com/kanaka/mal/blob/master/process/guide.md#step-0-the-repl) guide. Features [linenoise](https://github.com/antirez/linenoise/) integration, macros, tail call optimization, closures, quoting, try/catch, metadata etc. 

## Build/Run



- Build in debug mode - `make build`
- Build in release mode - `make build:release`
- Pass compiler args - `make nim-build-args='--opt:speed' build`
- Clean build cache and the binary - `make clean`
- Run the interpretor - `make run`
- Run with debug logging - `make run:debug`
- Format code with `nimpretty` - `make format`
- Run all tests - `make test`
- Run self hosted tests - `make test:selfhosted`
- Watch targets (requires [`entr`](https://eradman.com/entrproject/)) - `make watch` and `make watch:test`


### Note on test suite

Everything under `tests` directory is copied unmodified from the [kanaka/mal](https://github.com/kanaka/mal/blob/master/process/guide.md#step-0-the-repl) repository.

### License

All the files under `tests` directory is available under the original MPL 2.0 license. Rest everything is under GLP 3.0 or later.
