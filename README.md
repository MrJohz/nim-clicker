# Nim Clicker!

> Incremental games deserve to break out into the command-line world, right?

This is a cookie-clicker-like-incremental-game-thing-app-whatsit.  I'm not going to offer pre-built binaries because I am a lazy arse.  If you want to, and/or dare, download/install/compile/write the Nimrod binary from [the Nim webiste](http://nim-lang.org/download.html), and run `nimrod c -o:bin/clicker clicker.nim`, or maybe `nim c -o:bin/clicker clicker.nim` if the dev versions are out yet, or you could even install [`nimble`](https://github.com/nimrod-code/nimble), and from there `nake`, and then run `nake build`.  Or I'm sure you could do many other things.

```
$ clicker help
The Clicker Game

Every time you run this program, you get clicks.

Run `clicker -s` to see how many clicks you have.

Run `clicker shop` to find out what you can buy,
and `clicker shop buy <id-name>` to buy the item
with  your clicks.

Run `clicker use` to use the powerups you've bought.
(Note that some powerups are used automatically,
and last for the length of the game.)

Built (badly) with Nim by Johz
```
