# nix-config
Nix configuration for macOS systems

# Prerequisites

- clone doom emacs -> .emacs.d
``` shell
git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.emacs.d
~/.emacs.d/bin/doom install
```

- homebrew (managed by nix-darwin)
``` shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

A working install of [nix](https://nixos.org/download.html) + [nix-darwin](https://github.com/LnL7/nix-darwin) (if on macOS)
``` shell
# install nix
curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
nix-env -iA nixpkgs.nixUnstable  # Get flakes

# install nix-darwin
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer
```

# Activate using flakes

``` shell
# NixOS
make rebuild-switch

# MacOS
make darwin-switch
```


