# foothold

I don't info from this user, there's nothing on home, finally, more enum needs
to be done.

And there is nothing, no foothold, everything is empty, like the cluster right
now (6am).

But, here it comes, a soft light:
```bash
$ file `which getflag`
/bin/getflag: ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.24, BuildID[sha1]=0x3fcebc416e32d2b675c7ea7585328122caf0f15d, not stripped
```

getflag, has debug symbols...

It's time...

# exploit

Reversing the `getflag` binary we see there are a bunch of encrypted strings
for each User ID, `flag14` is the `3014`.

Here it is:
```bah
else {
  if (_Var6 != 3014) goto LAB_08048e06;
  pcVar4 = (char *)ft_des("g <t61:|4_|!@IF.-62FH&G~DCK/Ekrvvdwz?v|");
  fputs(pcVar4,__stream);
}
```

Okey, lets copy pastde the `ft_des` function, shall we?

Pretty easy, I don't know if this is the intended way, since the binary has
debug symbols maybe that was the intended way? attaching gdb to it? But if that
was the intended way, why the `ft_des` function will be that easy to copy paste?

But thinking about it, does not make sense that both level13 and level14 can be
just copy pasted, so maybe copy paste is not the intended way?

Anyway, just compile and run the binary.

I could have just done that for everyuser right? I highly doubt that's the
intended way...

But being honest, attaching gdb and just jumping changing eax to the desired
values, is even more easier than copy pasting the decrypt function, and you use
the debugger for level13 and level14, both, although level14 changes a bit
because you will need to play with the eax, but nothing difficult.

# alternative path

Using `gdb` we can also bypass this binary all the way to the `ft_des()` call,
it's a little trickier than `level13`, but it's still easy.

The main difference is that we need to bypass `ptrace(PTRACE_TRACEME, ...)`,
a little old anti-debugger trick.

But it's easy, in fact, there are multiple methods:
- `nop` the call with something like:
    - `set write`
    - `set {unsigned int}$pc = 0x90909090`
    - `set {unsigned char}($pc+4) = 0x90`
    - `set write off`
- alternative for patching:
    - `set {unsigned int}0x40911f = 0x90909090`
    - `set {unsigned char}0x409123 = 0x90`
- manipulate `$pc`:
    - `set $pc+=5` or more explicit `set $pc=$pc+5`
    - `jump *$pc+5`
- change return value of ptrace: `set $eax=0`

In the `level13` I explained a lot about gdb, so now I'm gonna skip the basics:
```bash
$ gdb `wich getflag`

# layout asm, layout regs, disassembly-flavor, etc.
$ b main
$ r

# This is the ptrace call, 4 arguments, we'll jump all of them
# lVar2 = ptrace(PTRACE_TRACEME,0,1,0);

# The assembly code sets eax to 0, prepares the parameters, and does a `test`
# to check if eax is 0, if so, it jumps to main+98

# Move before the code that calls ptrace
$ b *main+67
$ c

# Skip ptrace call and set eax to 0, so program thinks is not being tracked
# Check the difference in bytes of the `call` instruction and the next one
$ x/5i $pc

# That's the `call` opcode size, let's skip those 5 bytes hehe
$ set $pc=$pc+5

# Set the next breakpoint after getuid()
$ b *main+444
$ c

# Check registers, our UID is in the eax registers, as expected if you know asm
$ p $eax
# Change it, hehe
$ set $eax=3014

# And finish execution
c
```

And there's the flag, easy alternative method right?
