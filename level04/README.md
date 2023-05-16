# foothold

I already know somethings about the `level04`, in the initial emuration I
discover that this user does not have an apache site, but has a
`/var/www/level04` directory.

Now, I see that it has a `level04.pl` file in the user home.

Looking at the Apache config I enumerated at the start, it's obviusly using
`perl` CGI and running on the port 4747, so let's see what does this script.

# exploit

Well, at first I didn't wanted to belive it, but indeed, this has to be the
easiest command injection I found.

As we can see, it's just a script that prints in the web, the relust of the
command `echo`:
```perl
print `echo $y 2>&1`
```

*And it redirects the stderr wtf.*

So, where does `y` come from? Easy my friend:
```perl
# ...
use CGI qw{param}
print "Content-type: text/html\n\n"
sub x {
    $y = $_[0];
    print `echo $y 2>&1`;
}
x(param("x"));
```

First things first, the first line imports the function `param()` from the CGI
module.

Next it prints the header for the web response, irrelevant.

After that, this code declares a function `x()`, in which it uses `$_[0]`
in a command.

In perl, `$_[0]` is basically the `argv[1]` in C, or `$1` in bash, is the first
argument, so the injection is on the argument passed to the `x()` function.

At the end, the code calls `x()`, with the argument `param("x");`.

So... what could the function `param()` from the CGI module possibly do...

Indeed, it takes the value of a param from te query string.

So... yeah, let's do some `curl` magic:
```bash
curl -v http://localhost:4747?x=paco
```

And it prints `paco`! Magic!

Now the injection, remember that we need to url encode any special characters:
```bash
curl -v 'http://localhost:4747?x=%3Bid'
```

It prints that I'm the `flag04` user, so lets call `getflag` directly:
```bash
curl -v 'http://localhost:4747?x=%3Bgetflag'
```

And I got it, nice!
