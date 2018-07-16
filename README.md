memory management simulator 2k18
===
my goal for this is to make a lisp interpreter that's as close to the metal as possible. going to experiment with using closures to manage memory instead of something akin to `alloc()` or `free()`. instead, imagine using a function that was like `(with-alloc *bytes* (...))`. for now though, it just prints text on the screen

make sure nasm, ld, and qemu are installed. make sure you've got KVM/hypervisor support and that you're on an x86-64 CPU made in the past 10 years. then, run:
```
make
make run
```
