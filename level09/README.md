# foothold

Here I am... The last level... I will be able to finish snow-crash in a single
day? It seems so, but I'm cheating because pentesting is my hobby and well,
these are entry-level challenges.

No more talk, let's finish.

Again I don't have nothing from `level09`, but in the home directory there is
a `level09` SUID binary, and a `token` file, again!?

Well, no, not again, this time we have read perms over `token`, and its contents
are some weird binary data.

Let's get those `strings`:
```diff
 puts
 __stack_chk_fail
+putchar
+stdout
+fputc
+getenv
+stderr
+ptrace
+fwrite
+open
 __libc_start_main
 GLIBC_2.4
 GLIBC_2.0
 PTRh
 UWVS
 [^_]
+You should not reverse this
+LD_PRELOAD
+Injection Linked lib detected exit..
+/etc/ld.so.preload
+/proc/self/maps
+/proc/self/maps is unaccessible, probably a LD_PRELOAD attempt exit..
+libc
+You need to provied only one arg.
+00000000 00:00 0
+LD_PRELOAD detected through memory maps exit ..
```

Hehe, it's preventing what I thought in the previous level, we can not
preload a different libc! Maybe that was the intended approach in the previus
level? Who knows, I doubt it, but what is clear, is that now it isn't the
approach, let's reverse it:
```c
size_t main(int param_1,int param_2)
{
  char cVar1;
  bool bVar2;
  long lVar3;
  size_t sVar4;
  char *pcVar5;
  int iVar6;
  int iVar7;
  uint uVar8;
  int in_GS_OFFSET;
  byte bVar9;
  uint local_120;
  undefined local_114 [256];
  int local_14;
  
  bVar9 = 0;
  local_14 = *(int *)(in_GS_OFFSET + 0x14);
  bVar2 = false;
  local_120 = 0xffffffff;
  lVar3 = ptrace(PTRACE_TRACEME,0,1,0);
  if (lVar3 < 0) {
    puts("You should not reverse this");
    sVar4 = 1;
  }
  else {
    pcVar5 = getenv("LD_PRELOAD");
    if (pcVar5 == (char *)0x0) {
      iVar6 = open("/etc/ld.so.preload",0);
      if (iVar6 < 1) {
        iVar6 = syscall_open("/proc/self/maps",0);
        if (iVar6 == -1) {
          fwrite("/proc/self/maps is unaccessible, probably a LD_PRELOAD attempt exit..\n",1,0x46,
                 stderr);
          sVar4 = 1;
        }
        else {
          do {
            do {
              while( true ) {
                sVar4 = syscall_gets(local_114,0x100,iVar6);
                if (sVar4 == 0) goto LAB_08048a77;
                iVar7 = isLib(local_114,&DAT_08048c2b);
                if (iVar7 == 0) break;
                bVar2 = true;
              }
            } while (!bVar2);
            iVar7 = isLib(local_114,&DAT_08048c30);
            if (iVar7 != 0) {
              if (param_1 == 2) goto LAB_08048996;
              sVar4 = fwrite("You need to provied only one arg.\n",1,0x22,stderr);
              goto LAB_08048a77;
            }
            iVar7 = afterSubstr(local_114,"00000000 00:00 0");
          } while (iVar7 != 0);
          sVar4 = fwrite("LD_PRELOAD detected through memory maps exit ..\n",1,0x30,stderr);
        }
      }
      else {
        fwrite("Injection Linked lib detected exit..\n",1,0x25,stderr);
        sVar4 = 1;
      }
    }
    else {
      fwrite("Injection Linked lib detected exit..\n",1,0x25,stderr);
      sVar4 = 1;
    }
  }
LAB_08048a77:
  if (local_14 == *(int *)(in_GS_OFFSET + 0x14)) {
    return sVar4;
  }
                    /* WARNING: Subroutine does not return */
  __stack_chk_fail();
LAB_08048996:
  local_120 = local_120 + 1;
  uVar8 = 0xffffffff;
  pcVar5 = *(char **)(param_2 + 4);
  do {
    if (uVar8 == 0) break;
    uVar8 = uVar8 - 1;
    cVar1 = *pcVar5;
    pcVar5 = pcVar5 + (uint)bVar9 * -2 + 1;
  } while (cVar1 != '\0');
  if (~uVar8 - 1 <= local_120) goto code_r0x080489ca;
  putchar((int)*(char *)(local_120 + *(int *)(param_2 + 4)) + local_120);
  goto LAB_08048996;
code_r0x080489ca:
  sVar4 = fputc(10,stdout);
  goto LAB_08048a77;
}

undefined4 isLib(undefined4 param_1,undefined4 param_2)
{
  bool bVar1;
  char *pcVar2;
  undefined4 uVar3;
  int local_10;
  char *local_8;
  
  pcVar2 = (char *)afterSubstr(param_1,param_2);
  if (pcVar2 == (char *)0x0) {
    uVar3 = 0;
  }
  else if (*pcVar2 == '-') {
    bVar1 = false;
    while ((local_8 = pcVar2 + 1, '/' < *local_8 && (*local_8 < ':'))) {
      bVar1 = true;
      pcVar2 = local_8;
    }
    if ((bVar1) && (*local_8 == '.')) {
      bVar1 = false;
      for (local_8 = pcVar2 + 2; ('/' < *local_8 && (*local_8 < ':')); local_8 = local_8 + 1) {
        bVar1 = true;
      }
      if (bVar1) {
        for (local_10 = 0; end.3170[local_10] != '\0'; local_10 = local_10 + 1) {
          if (end.3170[local_10] != local_8[local_10]) {
            return 0;
          }
        }
        uVar3 = 1;
      }
      else {
        uVar3 = 0;
      }
    }
    else {
      uVar3 = 0;
    }
  }
  else {
    uVar3 = 0;
  }
  return uVar3;
}

char * afterSubstr(char *param_1,int param_2)
{
  bool bVar1;
  int local_10;
  char *local_8;
  
  bVar1 = false;
  for (local_8 = param_1; *local_8 != '\0'; local_8 = local_8 + 1) {
    bVar1 = true;
    for (local_10 = 0; (bVar1 && (*(char *)(local_10 + param_2) != '\0')); local_10 = local_10 + 1)
    {
      if (*(char *)(local_10 + param_2) != local_8[local_10]) {
        bVar1 = false;
      }
    }
    if (bVar1) break;
  }
  if (bVar1) {
    local_8 = local_8 + local_10;
  }
  else {
    local_8 = (char *)0x0;
  }
  return local_8;
}
```

Cool right? :D

# exploit

This can seem intimidating if its you first time, don't worry little boy, it's
alright.

So, what does this code do? Basically it prevents the parent from tracing the
process, just try to run `ltrace ./level09 token`, and it's also preventing a
preload of a different linked lib, interesting, but once you know that, the code is
not that intimidating.

It also have a function `syscall_open` and `syscall_gets`, but I don't think
they are important and I don't want to add more lines to that decompiled code.

Look at this section of the code, is the end of
the `main` function, and also the only part that gets executed if you run the
executable as expected with one argument:
```c
LAB_08048a77:
  if (local_14 == *(int *)(in_GS_OFFSET + 0x14)) {
    return sVar4;
  }
                    /* WARNING: Subroutine does not return */
  __stack_chk_fail();
LAB_08048996:
  local_120 = local_120 + 1;
  uVar8 = 0xffffffff;
  pcVar5 = *(char **)(param_2 + 4);
  do {
    if (uVar8 == 0) break;
    uVar8 = uVar8 - 1;
    cVar1 = *pcVar5;
    pcVar5 = pcVar5 + (uint)bVar9 * -2 + 1;
  } while (cVar1 != '\0');
  if (~uVar8 - 1 <= local_120) goto code_r0x080489ca;
  putchar((int)*(char *)(local_120 + *(int *)(param_2 + 4)) + local_120);
  goto LAB_08048996;
code_r0x080489ca:
  sVar4 = fputc(10,stdout);
  goto LAB_08048a77;
}
```

It starts and the tag `LAB_08048996`.

Basically, `local_120` has a value of `0` after that first line, uVar8 has a value
of `-1`, and `pcVar5` is `argv + 4`, why are in a 32 bits machine, so that's
`argv[1]`.

So, it iterates in a `do {} while ()`:
- First it substracts one from `uVar8`: `--uVar8;`.
- Then it get the current char being iterated by doing `cVar1 = *pcVar5;`.
- And it increases `pcVar5` in a weird way: `pcVar5 = pcVar5 + bVar9 * -2 + 1`, its important to notice that `bVar9` is just a `0`, si in reality this is just a `++pcVar5;`.

If it founds the `\0`, it breaks, and prints the char in `argv[1] + local_120`,
that in this first iteration is `0`, so its the first char.

Then we loop, It goes back all the way to the top of the snippet.

It checks some weird stuff I don't care about, and repeat the `do {} while ()`.

We increment `local_120`, so this way when we exit the loop, the char printed
will the `(char *)(argv[1] + local_120) + local120`.

Basically, it prints the current char plus the index, suposse we have the
string `"aaaa"`, it will print `abcd`, let's try it:
```bash
$ ./level09 aaaa
abcd
```

Of course there are a lot more things in the binary, but not really important,
knowing what is important and what no of a binary is an important skill.

So, we can assume `token` was the output of a text passod to this binary, so
we just need to do a little program to reverse it, easy:
```c
#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>

int main(void)
{
	int i;
	int fd;
	int size;
	char buf[96]

	fd = open("/home/user/level09/token", O_RDONLY);
	size = read(fd, buf, sizeof(buf) - 1);
	buf[size] = '\0';

	for (i = 0; i < size; ++i) {
		buf[i] = buf[i] - i; // Substract instead of increasing!
	}

	printf("result: %s\n", buf);

	return 0;
}
```

The last character is weird, I don't know why, but who cares, copy all except
that weirld last character, and that's all, I get the `flag09` user password.
