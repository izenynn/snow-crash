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
