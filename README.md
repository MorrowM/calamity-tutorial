# Calmity Tutorial

This repository contains the source for my [Calamity](https://hackage.haskell.org/package/calamity) tutorial over at https://www.morrowm.com/posts/2021-04-29-calamity.html

## Pre-requisites

This project requires the GHC 9.2 compiler and the Cabal build tool. See the [Haskell downloads page](https://www.haskell.org/downloads/) for up-to-date information on how to aquire those.

**Make sure to replace the `"<your token here>"` string in `Main.hs` with your bot's secret token! You can obtain one through the [Discord Developer Portal](https://discord.com/developers). Also a reminder: the token is secret, treat it like you'd treat a password!**

## Building and Running

Run the following command to build the project. Note that the first build will take a while, Calamity has a pretty heavy dependency footprint. Subsequent builds should be significantly faster.

```sh
$ cabal build
```

And to run:

```sh
$ cabal run
```

Note that `cabal run` will build and run, so you don't need to run `cabal build` every time.

To open a GHCi session in the context of the project:

```sh
$ cabal repl
```