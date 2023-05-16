# foothold

That `/etc/passswd` was weird and now that I'm on level 01, time to
check it again.

# exploit

[Hash identifier](https://www.tunnelsup.com/hash-analyzer/) says it could be DES or 3DES.

Let's try to bruteforce it, first, on the Mac host I'm using:
```bash
brew install hashcat
```

Why hashcat you may ask, well, `john` is for weaklings that can't use `hashcat`.

The hash mode for DES is `1500`, that's the traditional Unix DES

The attack mode will be `0` and I will supply the `rockyou.txt` dic, for a CTF
this is all it takes for a password (usually).

If it is not in `rockyou.txt`, then the intended path is not bruteforce.

Okey so I'm in the cluster Mac so I will ssh to my PC for running hashcat:

Start the attack...:
```bash
wget https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt
hashcat -a 0 -m 1500 "42hDRfypTqqnw" rockyou.txt
```

After a while...

Bingo! Password cracked!

That was fast, the password for `flag01` is:
```raw
42hDRfypTqqnw:abcdefg
```
