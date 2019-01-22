An Example Chat Application in Pure
---

This repo contains a simple chat application from [purehs.org](http://purehs.org/tut/introduction).

First run
---

Either clone this repo with `--recurse-submodules`, or run `git submodule update --init --recursive` in this directory after cloning to make sure `pure-platform` is checked out. 

First, run `./deps/pure-platform/try-pure` at least once. This will install `nix` and build the pure ecosystem if necessary.

> NOTE: Pure requires a custom `ghcjs-base`, so the first run of `try-pure` will be very, very slow. Subsequent builds will take advantage of `nix` memoization. Consider becoming acquainted with Pure at [purehs.org](http://purehs.org) while `try-pure` runs.

Developing
---

> These two development servers avoid the need to re-enter a nix shell for every build. This can greatly speed up build times compared to `nix-build`.

To run a backend development server that will:

- watch frontend and shared Haskell and Cabal files for changes
- rebuild and restart the server when necessary
- restart the server 

```bash
$ ./ghc npm run dev:backend
```

To run a frontend development server that will:

- serve your application at `localhost:8080` 
- watch frontend and shared Haskell and Cabal files for changes
- rebuild the application when necessary
- inject newly-built applications into any connected browsers:

```bash
$ ./ghcjs npm install
$ ./ghcjs npm run dev:frontend
```

> NOTE: If you don't browse to localhost:8080 and change the browser sync configurations to not synchronize clicks/inputs, you will see duplicated messages.

The web server configuration is at `dist/site/bs-config.js`.

To run `ghcid` or similar:

```bash
$ ./ghc ghcid -c "cabal new-repl {backend|shared|frontend}"
```

Production
---

`nix-build`
---

Nix can be used for creating deterministic, production-ready build products. You can use the `nix-build` command to build all or parts of your multi-package project with Nix.

- Build everything

  ```bash
  $ nix-build
    {.. build output omitted ..}
  $ tree result
  result
  ├── ghc
  │   ├── backend -> /nix/store/{..}-backend-0.1.0.0
  │   ├── frontend -> /nix/store/{..}-frontend-0.1.0.0
  │   └── shared -> /nix/store/{..}-shared-0.1.0.0
  └── ghcjs
      ├── frontend -> /nix/store/{..}-frontend-0.1.0.0
      └── shared -> /nix/store/{..}-shared-0.1.0.0

  7 directories, 0 files
  ```

- Build the backend only

  ```bash
  $ nix-build -o backend-result -A ghc.backend
  ```

- Build the frontend only

  ```bash
  $ nix-build -o frontend-result -A ghcjs.frontend
  ```

About
---

This repo is based on [pure-project-skeleton](https://github.com/grumply/pure-project-skeleton) which is based on [Will Fancher's](https://github.com/elvishjerricco) [reflex-project-skeleton](https://github.com/elvishjerricco/reflex-project-skeleton).
