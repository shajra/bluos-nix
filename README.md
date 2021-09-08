- [About this project](#sec-1)
- [Nix setup](#sec-2)
  - [Nix package manager setup](#sec-2-1)
- [Installation](#sec-3)
- [Usage](#sec-4)
- [Release](#sec-5)
- [License](#sec-6)
- [Contribution](#sec-7)

[![img](https://github.com/shajra/bluos-nix/workflows/CI/badge.svg)](https://github.com/shajra/bluos-nix/actions)

# About this project<a id="sec-1"></a>

This project provides a [Nix package manager](https://nixos.org/nix) expression to repackage the proprietary [BluOS Controller](https://bluos.net) for Linux. BluOS is software for managing digital/streaming music bundled with various music streamers and amplifiers.

The "main" branch provides the latest release of 3.14.1 of the controller. See "maint/\*" branches for older versions.

This project is unofficial. The official distribution is only for Windows, Macs, and mobile devices. However, it turns out that it's implemented as an [Electron](https://electronjs.org) application, which lends to portability, in this case enabled by some relatively light patching.

This project is only tested against Linux and does not work on MacOS. Use the official BluOS distributions for MacOS or any other platform.

Projects such as this one have been birthed by [a post on the official BluOS support forum](https://support1.bluesound.com/hc/en-us/community/posts/360033533054-BluOS-controller-app-on-Linux). There's a few projects that do what this project does, but without Nix. Here's a comparison with two of them:

| Project                                                       | Dependencies                                   | Outputs        |
|------------------------------------------------------------- |---------------------------------------------- |-------------- |
| [dave92082/bs-patch](https://github.com/dave92082/bs-patch)   | Go+NodeJS/NPM+P7ZIP                            | Snap, AppImage |
| [frafra/bs-bashpatch](https://github.com/frafra/bs-bashpatch) | Go+P7ZIP+NodeJS/NPM+Lynx+… or Podman or Docker | AppImage       |
| This project                                                  | Nix package manager                            | Nix package    |

Nix is a package manager we can use to both build and install the controller. NixOS is a distribution that uses this package manager, but we can install Nix on any Linux distribution. Nix can install with not worry of conflict alongside other package managers such as APT, Yum, Pacman, etc.

A primary motivation to use Nix is to reduce build dependencies. This is not dissimilar from the optional usage of Podman or Docker of `bs-bashpatch`, but Nix offers an architecture for reproducible builds well above what Podman or Docker can accomplish. If you're new to Nix, see [the provided documentation on Nix](doc/nix.md) for more on what it is, and how to get set up with it for this project.

Ultimately, we're trading off complexity. You take on the complexity of installing the Nix package manager (or running NixOS). After that projects like this can more easily build applications without you having to worry about having the right software installed and configured. All you need is Nix.

# Nix setup<a id="sec-2"></a>

To use Nix at all, you first need to have it on your system.

## Nix package manager setup<a id="sec-2-1"></a>

> **<span class="underline">NOTE:</span>** You don't need this step if you're running NixOS, which comes with Nix baked in.

If you don't already have Nix, [the official installation script](https://nixos.org/learn.html) should work on a variety of UNIX-like operating systems:

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

After installation, you may have to exit your terminal session and log back in to have environment variables configured to put Nix executables on your `PATH`.

The `--daemon` switch installs Nix in the recommended multi-user mode. This requires the script to run commands with `sudo`. The script fairly verbosely reports everything it does and touches. If you later want to uninstall Nix, you can run the installation script again, and it will tell you what to do to get back to a clean state.

The Nix manual describes [other methods of installing Nix](https://nixos.org/nix/manual/#chap-installation) that may suit you more.

# Installation<a id="sec-3"></a>

Once you have Nix available as a package manager, you can then run the following to install the BluOS controller:

```sh
nix-env --install --file .
```

    installing 'bluos-controller'

You should then see the controller installed at `~/.nix-profile/bin/bluos-controller`. For convenience, configure your shell to put `~/.nix-profile/bin` on your `PATH`.

# Usage<a id="sec-4"></a>

We generally start the controller with no arguments:

```sh
bluos-controller
```

Sometimes it gets a little stuck. If this happens, try hitting `ctrl-r` to reset the application. You can also type `Alt` to see the Electron menu (auto-hidden by default).

The controller is wrapped by `daemon` as a convenience for job control. This way you can have confidence that only one instance is running at a time. Also, you don't have to deal with backgrounding processes or redirecting standard output/error.

You can call the controller with `--help` or `--help-daemon` for more details:

```sh
bluos-controller --help
```

    USAGE: bluos-controller
        [OPTIONS]... [start | start-nodaemon | stop | toggle] [-- DAEMON_ARGS...]
    
    DESCRIPTION:
    
        Runs the BluOS Controller, ensuring that there's only
        one instance running using a PID file.  This is done
        with the 'daemon' program.
    
        You can give a start or stop command.  Otherwise, start
        is assumed.  If you give both commands, the last one has
        precedence.
    
    OPTIONS:
    
        -h --help            print this help message
        -H --help-daemon     print this help message

# Release<a id="sec-5"></a>

The "main" branch of the repository on GitHub has the latest released version of this code. There is currently no commitment to either forward or backward compatibility.

The "maint/\*" branches have older versions of BluOS controller. There might be a motivation to run with an older version intentionally, despite the nagging to upgrade.

"user/shajra" branches are personal branches that may be force-pushed to. The "main" branch should not experience force-pushes and is recommended for general use.

# License<a id="sec-6"></a>

This is repackaging of proprietary software. It is safe to assume that BluOS controls the terms for all copying, modification, and distribution. The copyright is entirely theirs. To my knowledge, there is no license for usage.

Obviously, BluOS wants people to download their official software for use. But it's not clear to what degree they support unofficial repackaging. They could request projects like this to cease and desist. But the more likely scenario is that they are happy to have a community help out with something they don't have time for.

An additional benefit to them is not having to support Linux officially. If any of these repackaging projects has a problem, the burden of fixing it falls on the packager, and not on BluOS. That extends to damages and liabilities as well. But don't worry about that too much. The patching this project does is small, and it's ultimately just a music management application that talks a little over the network.

# Contribution<a id="sec-7"></a>

Feel free to file issues and submit pull requests with GitHub.
