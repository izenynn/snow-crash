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
