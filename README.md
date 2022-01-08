# mal

Mal implementation following the [kanaka/mal](https://github.com/kanaka/mal/blob/master/process/guide.md#step-0-the-repl) guide.

## Build/Run

To build in debug mode
```
make build
```
compiler args can be set by passing the `nim-build-args` argument to make, for eg.
```
make nim-build-args='-d:release' build
```

To run the intrepretor
```
make run
```
or
```
make nim-build-args='-d:release' run
```

To run test for step N

```
make nim-build-args='-d:release' testN
```

Format the code with `nimpretty`
```
make format
```

To evalauate sample scripts
```
make build && ./mal sample/factorial.mal 1 2 3 4 5 6
```
The above should print something like `"(1 2 6 24 120 720)"`

Use watch target `watch` and `watch:test` to run build or test on file change respectively. Requires [`entr`](https://eradman.com/entrproject/) to be installed.

Set `LOGGING` environment to enable logging. Possible values - `debug`, `all`. Eg. `LOGGING=debug make run`

### Note on test suite

The test suite and runner is copied unmodified from the [kanaka/mal](https://github.com/kanaka/mal/blob/master/process/guide.md#step-0-the-repl) repository.

### License

All the files under `tests` directory is available under the original MPL 2.0 license. Rest everything is under GLP 3.0 or later.
