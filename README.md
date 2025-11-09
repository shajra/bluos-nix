- [About this project](#sec-1)
- [Building, packaging, and distributing with Nix](#sec-2)
- [Usage](#sec-3)
- [Release](#sec-4)
- [License](#sec-5)
- [Contribution](#sec-6)

[![img](https://github.com/shajra/bluos-nix/workflows/CI/badge.svg)](https://github.com/shajra/bluos-nix/actions)

[![img](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Fgarnix.io%2Fapi%2Fbadges%2Fshajra%2Fbluos-nix%3Fbranch%3Dmain)](https://garnix.io/repo/shajra/bluos-nix)

# About this project<a id="sec-1"></a>

This project provides a [Nix package manager](https://nixos.org/nix) expression to repackage the proprietary [BluOS Controller](https://bluos.net) for Linux and Macs. BluOS is software for managing digital/streaming music bundled with various music streamers and amplifiers.

The "main" branch provides the latest release of 4.12.1 of the controller.

This project is unofficial. The official distribution is only for Windows, Macs, and mobile devices. However, it turns out that it's implemented as an [Electron](https://electronjs.org) application, which lends to portability. The Linux packaging has some light patching. The Mac packaging has no patching, and is merely redistribution through Nix.

This project is only tested against both Linux and MacOS. Use the official BluOS distributions for Windows.

# Building, packaging, and distributing with Nix<a id="sec-2"></a>

Projects such as this one have been birthed by [a post on the official BluOS support forum](https://support1.bluesound.com/hc/en-us/community/posts/360033533054-BluOS-controller-app-on-Linux). A few projects do what this project does but without Nix. Here's a comparison of three of them:

| Project                                                                                                     | Dependencies                                   | Outputs        |
|----------------------------------------------------------------------------------------------------------- |---------------------------------------------- |-------------- |
| [dave92082/bs-patch](https://github.com/dave92082/bs-patch)                                                 | Go+NodeJS/NPM+P7ZIP                            | Snap, AppImage |
| [frafra/bs-bashpatch](https://github.com/frafra/bs-bashpatch)                                               | Go+P7ZIP+NodeJS/NPM+Lynx+… or Podman or Docker | AppImage       |
| [fabrice.aeschbacher/bluos-controller-linux](https://gitlab.com/fabrice.aeschbacher/bluos-controller-linux) | P7ZIP+NodeJS/NPM+…                             | AppImage       |
| This project                                                                                                | Nix package manager                            | Nix package    |

Nix is a package manager we can use to both build and install the controller. NixOS is a distribution that uses this package manager, but we can install Nix on any Linux distribution. Nix, by design, installs packages without conflicts with other package managers such as APT, Yum, Pacman, etc.

A primary motivation to use Nix is to reduce build dependencies. This approach is not dissimilar from the optional usage of Podman or Docker of `bs-bashpatch`, but Nix offers an architecture for reproducible builds well above what Podman or Docker can accomplish. If you're new to Nix, this project bundles a few guides to get you started:

-   [Introduction to Nix and motivations to use it](doc/nix-introduction.md)
-   [Nix installation and configuration guide](doc/nix-installation.md)
-   [Nix end user guide](doc/nix-usage-flakes.md)
-   [Introduction to the Nix programming language](doc/nix-language.md)

Ultimately, we're trading complexity. You take on the complexity of installing the Nix package manager (or running NixOS). After that, projects like this can more easily build applications without you having to worry about having the right software installed and configured. All you need is Nix.

# Usage<a id="sec-3"></a>

As discussed in the [end user guide](doc/nix-usage-flakes.md) after [installing Nix with flakes](doc/nix-installation.md), we can run the BluOS controller without even installing it:

```sh
nix run github:shajra/bluos-nix
```

The guide also discusses how to install the application so it's accessible from your `PATH`.

There's also a small [`bluos-controller` script](bluos-controller) at this project's root that will run the exact version checked out from Git, whether you installed Nix with flakes or not.

We generally start the controller with no arguments.

Sometimes it gets a little stuck. If this happens, try hitting `ctrl-r` to reset the application. You can also type `Alt` to see the Electron menu (auto-hidden by default).

The Linux version is wrapped by `daemon` as a convenience for job control, ensuring that only one instance runs at a time. Also, you don't have to deal with backgrounding processes or redirecting standard output/error.

You can call the Linux controller with `--help` or `--help-daemon` for more details:

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
        -s --scale           DPI scaling factor

# Release<a id="sec-4"></a>

The "main" branch of the repository on GitHub has the latest released version of this code. There is currently no commitment to either forward or backward compatibility.

The "old/\*" branches have older versions of BluOS controller. There might be a motivation to run with an older version intentionally, despite the nagging to upgrade.

"user/shajra" branches are personal branches that may be force-pushed to. The "main" branch should not experience force-pushes and is recommended for general use.

# License<a id="sec-5"></a>

This project repackages proprietary software. It is safe to assume that Bluesound controls all copying, modification, and distribution terms. The copyright is entirely theirs. To my knowledge, there is no license for usage.

Clearly, Bluesound wants people to download their official software for use. But it's not clear to what degree they support unofficial repackaging. They could request projects like this to cease and desist. But the more likely scenario is that they are happy to have a community help with something they don't have time for.

An additional benefit to them is not having to support Linux officially. If any of these repackaging projects has a problem, the burden of fixing it falls on the packager, not Bluesound. That extends to damages and liabilities as well. But don't worry about that too much. This project's patching is minor, and it's ultimately just a music management application that talks a little over the network.

# Contribution<a id="sec-6"></a>

Feel free to file issues and submit pull requests with GitHub.
