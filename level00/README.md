# foothold

Use the `../resources/owned-files.sh` script to find the files owned by `flag00`

# exploit

I doubt this project will have any bruteforce, and the text seems pretty
readable so it will probably be something like rot13.

Let's try to discover the cipher
[index of coincidence](https://www.dcode.fr/index-coincidence)
[cipher identifier](https://www.dcode.fr/cipher-identifier)

The cipher identifier doesn't output anything interesting, but the IoC is
similar to the english one, so it may be some shifted text.

[CyberChef](https://gchq.github.io/CyberChef/#recipe=Magic(5,true,false,'')&input=Y2RpaWRkd3Bnc3d0Z3Q)

CyberChef magic doesnt output anything interesting either.

Tried rot13 (failed):
[Rot13](https://gchq.github.io/CyberChef/#recipe=ROT13_Brute_Force(true,true,false,100,0,true,'')&input=Y2RpaWRkd3Bnc3d0Z3Q)

Tried xor (just in case)(failed):
[Xor](https://gchq.github.io/CyberChef/#recipe=XOR_Brute_Force(1,100,0,'Standard',false,true,false,'')&input=Y2RpaWRkd3Bnc3d0Z3Q)

Tried rot47 (failed):
[Rot47](https://gchq.github.io/CyberChef/#recipe=ROT47_Brute_Force(100,0,true,'')&input=Y2RpaWRkd3Bnc3d0Z3Q)

I can't use CyberChef... Time to go back to dcode, so I tried all the ciphers
the "cipher identifier" suggested... and bingo!!! As I though the letters where
just sifted:

[Cipher Disk](https://www.dcode.fr/cipher-disk)

So and the IoC suggested, is just a monoalphabetic substitution, the caesar
cipher would also had work for decripting this, that was the next step following
the monoalphabetic way.
