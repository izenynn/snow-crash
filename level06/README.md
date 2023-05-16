# foothold

I didn't know nothing abouth this user before hand, so let's see what it has to
offer... (o.O)

Oh, the home directory is full of stuff, a `level06` suid binary, and a
`level06.php` file... mmmmmm

In one of the previous levels I went crazy and reversed the binary, bet seeing
that this levels are clearly for people with 0 knowledge of cybersecurity,
I'm pretty sure a simple `strings` will do the trick.

And yeah, here's the `strings` output:
```raw
/usr/bin/php
/home/user/level06/level06.php
```

A SUID binary that executes the `level06.php` scripts... seems fun!

# exploit

And the `.php` is not well formated so it's difficuld to read, first let format
it.

```php
#!/usr/bin/php
<?php

function y($m) {
    $m = preg_replace("/\./", " x ", $m);
    $m = preg_replace("/@/", " y", $m);
    return $m;
}

function x($y, $z) {
    $a = file_get_contents($y);
    $a = preg_replace("/(\[x (.*)\])/e", "y(\"\\2\")", $a);
    $a = preg_replace("/\[/", "(", $a);
    $a = preg_replace("/\]/", ")", $a);
    return $a;
}

$r = x($argv[1], $argv[2]); print $r;

?>
```

Much better, it is just doing some `preg_replace()`, this function performs a
regular expression seach and replace, pretty easy right?

At the end we can see it calls the `x()` function with the first and second
parameters, but the second one is never used.

The first one is passed to `file_get_contents()`, so basically, this code is
opening the file we pass as parameter, and performing replaces of its content.

Since it is executing as the `flag06` user, I tried opening his `.bashrc` file:
```bash
./level06 /home/flag/flag06/.bashrc
```

And I noticed something at the end:
```raw
# ...
if ( -f /etc/bash_completion ) && ! shopt -oq posix; then
    . /etc/bash_completion
fi
alias='su -c "cd;/bin/bash"'
cat /home/flag/flag06/README.txt
cd
```

That `cat` seems **sus**.

```raw
level06@SnowCrash:~$ ./level06 /home/flag/flag06/README.txt
Don't forget to launch getflag !
```

But it was just a prank, thanks for the recordatory...

I will need to read the code, what a same, but it stills seems pretty obvious.

The first line is using a `/e`, that's the foothold, we can exploit that.

*Note preg_replace is deprecated since php 5.5 and removed since 7.0, but the machine is running 5.3 (php -v)*

The `e` modifier on the first `preg_replace` line allows us to use PHP
functions within the replace parameter (the second argument).

```bah
$a = preg_replace("/(\[x (.*)\])/e", "y(\"\\2\")", $a);
```

That second argument is the return value of the funcion `y()`, passsing the
second group as parameter `\\2`, let me try to explain this...

`\\2` (or `\2`, the first backslash is to escape the second) represents the
second captured group from the regular expression pattern `(\[x (.*)\])`.

Let's break it down:

- The regular expression pattern `(\[x (.*)\])` matches a specific pattern enclosed in square brackets `[x ...]`.
- Within the pattern, `(.*)` captures any characters that follow after the space following `[x`.
- The captured parts of the pattern are referred to as groups. In this case, there are two groups: the entire matched pattern is the first group, and the content captured by `(.*)` is the second group.

In the replacement code `"y(\"\\2\")"`, `\\2` refers to the content captured by
the second group. It is then used as an argument in a function call to `y()`.

This implies that the captured content is passed as a parameter to the `y()`
function.

So, in this scenario, the `preg_replace()` function replaces all occurrences of
the pattern `\[x ...]` with the result of the `y()` function called with the
content captured by `(.*)` as an argument.

So, if we do a file with the following format:
```raw
file.txt:
[x patata]
```

`\\2` will be
```raw
\\2:
patata
```


This means that when you do `"y(\"\\2\")"`, PHP will evaluate this as a call
to the `y()` function with the second captured group from the regex `(.*)`
as the argument.

Now, if the `$a` variable contains a string like `[x {some_code}]`,
`{some_code}` will be passed into the `y()` function.

The function `y()` will replace the "`.`" with "` x `", and the `@` with "` y`",
we must be remember that, maybe its important.

The next lines of the function `x()`, will just replace the `[` and `]` with
parentheses `(` and `)` respectively, does not seem important.

Let's make some poc:
```bash
echo -n '[x $z]' > /dev/shm/payload
./level06 /dev/shm/payload 'foo'
```

Cool, we are passin `$z` to `y()`, so the second argument gets printend back,
now we just neet to play with the second parameter, but we can't just do:
```bash
./level06 /dev/shm/payload 'system("getflag")'
```

Because or second parameter, is between quotes, and treated as a string:
`y(\"\\2\")`

How sad is that? Let's bypass those quotes.

In php you can only call variables inside a string, like we are doing now, this
what we are executing with the `[x $z]` payload:
```php
y("$z")
```

And its working, but we want to inject code, inside the quotes... I'm a little
lost in php, it's been a whole common core since I left pentesting, let's go
visit my [good old friend hacktricks php tricks](https://book.hacktricks.xyz/network-services-pentesting/pentesting-web/php-tricks-esp#code-execution)

Hacktricks says there are three ways of executing code in php:
```raw
system("ls");
`ls`;
shell_exec("ls");
```

We can also take advantage of php complex curly syntax to execute a function
like this:
```raw
echo -n '[x {${phpinfo()}}]' > /dev/shm/payload
./level06 /dev/shm/payload
```

We can take advantage on that and call `system()`, using single quotes because
we are inside double quotes:
```bash
echo -n '[x {${system('getflag')}}]' > /dev/shm/payload
./level06 /dev/shm/payload
```

PHP undefined variables go brrrrrrrrrrrrrrrrrrr.

We could also use the backtick, which is identical to `shell_exec()`, maybe useful.

use `${}` to inject a command, and let's you forget about the quotes hell:
```bash
echo -n '[x ${`getflag`}]' > /dev/shm/payload
./level06 /dev/shm/payload
```

So that's all, another flag.

This one was tricky, not gonna lie, but seeing error outputs as explotables is
a crucial skill in pentesting (like forcing an error in a web serv to output
the traceback).
