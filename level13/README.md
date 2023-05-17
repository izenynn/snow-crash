# foothold

Of course it had to be another binary... Okey, let's reverse it.

# exploit

The code is pretty simple, this is the main:
```c
void main(void)
{
  __uid_t _Var1;
  undefined4 uVar2;

  _Var1 = getuid();
  if (_Var1 != 0x1092) {
    _Var1 = getuid();
    printf("UID %d started us but we we expect %d\n",_Var1,0x1092);
    exit(1);
  }
  uVar2 = ft_des("boe]!ai0FB@.:|L6l@A?>qJ}I");
  printf("your token is %s\n",uVar2);
  return;
}
```

It expects the code to be ran by a user with UID 4242 (no one in this machine),
so, the only solution is to copy paste `ft_des()`, and making you own binary to
decipher the token.

This one is probably the easier so far, it's just copy paste the ghidra pseudo
code.

Important, the string is the password of `level14` directly, not of `flag13`.

# alternative path

Other option, that may be the intended path, is attaching gdb to the binary.

So, start:
```bash
gdb ./level13
```

Looking at the pseudo-code above, we see that it saves the return value of
`getuid()` in a variable, and later it uses it to check if we have UID 4242.

So, we can place a breakpoint in the `if()` and change the value so it evaluates
as true.

```bash
$ info file
  Entry point: 0x80483c0
  # ...

$ b *0x80483c0

# I don't like AT&T syntax (this is normally in my .gdbinit)
$ set disassembly-flavor intel

# You can do a .gdbinit like, so you can just run `gdb`:
# file level13
# b *0x80483c0
# set disassembly-flavor intel
# layout asm
# layout regs
# run

# an alternative to `layout asm`:
$ disas main

# We see, in the layout or in the disassembler that the `cmp` is in *main+14
$ b *main+14

# In assembly `step` and `next` does not work as expected, this instructions
# usually skips dozens of ASM instructions because the are part of the same
# line, but we want to go ins by ins, using `stepi` and `nexti` (`si` and `ni`)

# We can also examine the code with `examine` (`x`), and the current $pc
$ x/5i $pc

# Go to the next instruction or put a breakpoint in *mai+14 and continue
$ b *main+14
$ c

# Check registers, our UID is in the eax registers, as expected if you know asm
$ p $eax
# Change it, hehe
$ set $eax=4242

# And finish execution
c
```

There aren't any lines relevant for the `ft_des()` function that returns our
token, so just jump to the desired line!
```bash
$ gdb ./level13
$ b main
$ r

# No need to layout because its gonna be quick
$ disas main
# Breakpoint before getuid() call, after registers are updated
$ b *main+14
$ c
# Jump to the ft_des() call (actually, the line before, that sets the parameter)
$ jump *0x080485cb
# Done!
```

As a side note, if the asm layout corrupts just use `refresh`.

We have the token, this method is a little more fun and faster, but without
reversing... Sad.
