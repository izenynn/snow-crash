# foothold

Yey! I already have info for this level from the initial enumeration.

I know there is a process running: `lua /home/user/level11/level11.lua`, I
forgot to note which process it was, but probably is a `flag11` process.

And we of course have this file on the `level11` home, and we can read it, so
let's check.

there is a `hash(pass)` function that runs
`io.popen("echo"..pass.." | sha1sum", "r")`. Seems like command injection.

That function is called by the main loop, wich asks for a password, and then
it hashes it with this function, and sends us a "Gz you dumb" on success.

Reading the strings it sends, I already know this is the service running on
the port 5151, and that must be what the the process executing this script is
doing.

And I just notice that the port is running is at the top of the script... (u.u)

I suposse the password must be also the `flag11` user password, so let's get
started, this one is pretty easy also.

# exploit

So, yeah, that `pass` seems strange... can we inject code somehow? good question
my friend.

This is the typical injection before pipe, we just need to pass the hash the
code is expecting (`f05d1d066fb246efe0c6f7d095f909a7a0cf34a0`), but then
the command will look like this:
```bash
echo f05d1d066fb246efe0c6f7d095f909a7a0cf34a0 | sha1sum
```

We need to end the echo command, and silence the sha1sum commannd.

And because we are ending the first echo command, we need to make sure we put
something before that pipe so it does not produce a syntax error:
```
echo f05d1d066fb246efe0c6f7d095f909a7a0cf34a0; > /dev/null echo paco | sha1sum
```

So, our payload is:
```bash
f05d1d066fb246efe0c6f7d095f909a7a0cf34a0; > /dev/null echo paco
```

Okey playtime over, from the begginig it was obvious this is not going anywhere,
just look at the script, here's the real payload, I don't need to explain it,
right?
```bash
paco; getflag > /tmp/flag; > /dev/null echo paco
```

And there we go, we have the flag, no `su flag11` needed, `\(>.<)/`

This one was really easy.
