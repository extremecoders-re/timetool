# Time Tool
Synchronize Windows Time from a timeapi over HTTP. Useful when NTP traffic is blocked and builtin Windows time sync can't be used.

### Dependencies

```
nimble install winim
```

### Building

```
nim -d:ssl -d:release --opt:size compile timetool.nim
```

When not using `httpclient`, `ssl` support can be omitted
```
nim -d:release --opt:size compile timetool.nim
```

### Notes

Running the executable as Administrator is necessary to set the system clock on Windows.
