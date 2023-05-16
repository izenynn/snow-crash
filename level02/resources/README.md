# foothold

There is a `level02.pcap` file in the user home, easy.

# exploit

I downloaded whireshark, luckily for me because I'm on 42 Mac,
it runs without installing, by clicking the icon on the `.dmg` file.

Give read perms to the `.pcap` file and load it.

The capture is pretty small, luckily for us, I won't be spending time finding
the relevant packages.


I found a package asking for `password:`

So I guess whatever the other ip answered, is the password:
```raw
"ft_wandr"
0x7F
0x7F
0x7F
"NDRel"
0x7F
"L0L"
0x0D
```

So yeah, but is a little weird, this is experience talking here, I instantly
recogniced that `7f`, that's the backspace! so these are probably keystrokes!

Let's redo the input:
```bash
# "ft_wandr"
ft_wandr

# 3 deletes
ft_wa

# "NDRel"
ft_waNDRel

# 1 delete
ft_waNDRe

# "L0L"
ft_waNDReL0L

# Carriage return (enter key)
# This just sends the password, I guess
```

So the resulting password is:
```raw
ft_waNDReL0L
```

And bingo! that was the `flag02` password
