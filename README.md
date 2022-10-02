## 入门

**1.** 使用git包
```yml
dependencies:
  dart_generic_lib:
    git:
      url: https://github.com/ismanong/dart_generic_lib.git
# or
dependencies:
  dart_generic_lib:
    git:
      url: https://github.com/ismanong/dart_generic_lib.git
      ref: main
      path: packages/dart_generic_lib
```

**2.** 使用本地包
```yml
dependencies:
  dart_generic_lib:
    path: ../dart_generic_lib/
```
```yml
dependencies:
  dart_generic_lib:
    path: D:/_my/flutter_all_platform/packages/dart_generic_lib/
```
