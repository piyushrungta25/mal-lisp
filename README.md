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

### Note on test suite

The test suite and runner is copied unmodified from the [kanaka/mal](https://github.com/kanaka/mal/blob/master/process/guide.md#step-0-the-repl) repository.

### License

All the files under `tests` directory is available under the original MPL 2.0 license. Rest everything is under GLP 3.0 or later.
