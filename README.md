# Wine/Wine Staging + DXVK package builder & auto-installer

![](https://i.imgur.com/5WCPioZ.png)

Boost up your Wine experience with a taste of DXVK and automate installation of [DXVK](https://github.com/doitsujin/dxvk) + [Wine](https://www.winehq.org/)/[Wine Staging](https://github.com/wine-staging/wine-staging/) on Debian/Ubuntu/Mint/Arch Linux/Manjaro. Additionally, update your GPU drivers + PlayonLinux wineprefixes to use the latest Wine & DXVK combination available.

## About

One-click solution for accessing bleeding-edge Wine/Wine Staging & DXVK packages _system-widely_ on Debian/Ubuntu/Mint and on Arch Linux/Manjaro.

## Motivation

**Accessibility, lower the barrier.** Help people to get their hands on the latest bleeding-edge Wine/Wine Staging & DXVK software on major Linux distribution platforms without hassle or headaches.

There is not an easy way to auto-install bleeding-edge Wine/Wine Staging & DXVK, especially on Debian/Ubuntu/Mint. The newest Wine/Wine Staging is not easily accessible on Debian-based Linux distributions, and DXVK is practically bundled to Lutris or Steam gaming platform as a form of Proton. However, not all Windows programs, like MS Office or Adobe Photoshop, could run under Linux Steam client: Many Windows programs actually rely on system-wide Wine installation which is why system-wide Wine/Wine Staging & DXVK auto-installation this script offers becomes quite handy.

The solution provided here _is independent from Steam client or any other Wine management platform_. The latest Wine/Wine Staging & DXVK bundle will be accessible system-widely, not just via Steam, Lutris or PlayOnLinux. Provided PlayOnLinux prefix update is optional, as well.

----------------

## Adapt system-wide Wine/DXVK to your Steam Windows games

If you want to easily use Wine/Wine Staging and DXVK with your Steam Windows games on Linux, you may want to check out my helper script [steam-launchoptions](https://github.com/Fincer/steam-launchoptions).

With the helper script, you can set launch options for a single game/selected group of games/all games you have on your Steam account. You can customize the launch options for both Windows and Linux games and clean all existing launch options, too.

----------------

## Contents

- **Wine/Wine Staging & DXVK:** Install script for supported Linux distributions

- **Nvidia drivers:** Install script for supported Debian-based distributions

- **Patches:** Possibility to use your custom patches with Wine & DXVK

----------------

## Requirements

- **Linux Distribution:** Debian/Ubuntu/Mint OR Arch Linux/Manjaro. Variants may be compatible but they are not tested.

- **RAM:** 4096 MB (DXVK build process may fail with less RAM available)

- **Not listed as a hard dependency, but recommended for DXVK**: The latest Nvidia or AMD GPU drivers (Nvidia proprietary drivers // AMDGPU)

- **Time:** it can take between 0.5-2 hours for the script to run. Compiling Wine takes _a lot of time_. You have been warned.

----------------

## Why to compile from source?

Latest version of Wine/Wine Staging & DXVK are only available via git as source code which must be compiled before usage. Note that compiling Wine takes a lot of time. Compiling from source has its advantages and disadvantages, some of them listed below.

**Advantages:**

- packages are directly adapted to your system

- packages do not rely on PPAs which may be abandoned in time

- using Git sources provide the latest packages available publicly

**Disadvantages:**

- takes time & CPU processing power

- is unreliable in some cases, the script may break easily due to rapid DXVK development or distro changes

- may break working already-working versions of the packages (use `--no-install` parameter to avoid installation of DXVK & Wine, just as precaution)

----------------

## Script usage

For short help instructions, run:

```
bash updatewine.sh --help
```

on the main script folder.

You can pass arguments like:

```
bash updatewine.sh --no-staging --no-install
```

All supported arguments are:

- `--no-staging` = Compile Wine instead of Wine Staging

- `--no-install` = Do not install Wine or DXVK, just compile them. Note that Wine must be installed for DXVK compilation.

- `--no-wine` = Do not compile or install Wine/Wine Staging

- `--no-dxvk` = Do not compile or install DXVK

- `--no-pol` = Do not update current user's PlayOnLinux Wine prefixes

----------------

## Custom patches for Wine & DXVK

You can apply your own patches for DXVK & Wine by dropping valid `.patch` or `.diff` files into `dxvk_custom_patches` (DXVK) or `wine_custom_patches` (Wine) folder.

Folders `dxvk_disabled_patches` and `wine_disabled_patches` are just for management purposes, they do not have a role in script logic at all.

Wine patches are not related to Wine Staging patchset. You can use your custom Wine patches either with Wine Staging or vanilla Wine.

----------------

## Compiled packages are stored for later usage

Successfully compiled Wine & DXVK packages are stored in separate subfolders. Their locations are as follows.

On Debian/Ubuntu/Mint:

- `main-script-folder/debian/compiled_deb/`

On Arch Linux:

- `main-script-folder/arch/compiled_pkg/`

The actual subfolders which hold compiled programs are generated according to buildtime timestamp, known as `build identifier`.

## DXVK usage

**NOTE:** DXVK must be installed before applying these steps.

To enable DXVK on existing wineprefixes, just run

```
WINEPREFIX=/path/to/my/wineprefix setup_dxvk
```

`winetricks` is required for this command. 

## Add DXVK to PlayOnLinux Wine prefixes

To install DXVK on specific PlayOnLinux wineprefix which uses a different than `system` version of Wine, apply the following command syntax:

```
WINEPREFIX="$HOME/.PlayOnLinux/wineprefix/myprefix" WINEPATH=$HOME/.PlayOnLinux/wine/{linux-amd64,linux-x86}/wineversion/bin" setup_dxvk
```

where you need to set either `linux-amd64` or `linux-x86`, and `wineversion` + `myprefix` to match real ones, obviously.

system-wide `winetricks` executable (`/usr/bin/winetricks`) is required for this command.

### Manually uninstall temporary development packages (Debian/Ubuntu/Mint):

Development packages can take extra space on your system so you may find useful to uninstall them. The script provides an automatic method for that but you can still use additional `debian_cleanup_devpkgs.sh` script which is targeted for uninstalling build time dependencies manually. The script uninstalls majority of Wine-Staging (Git), meson & glslang buildtime dependencies which may not be longer required. Be aware that while running the script, it doesn't consider if you need a development package for any other package compilation process (out of scope of Wine/DXVK)!

To use `debian_cleanup_devpkgs.sh`, simply run:

```
bash debian_cleanup_devpkgs.sh
```

---------------------------

### EXAMPLES:

**NOTE:** If `--no-install` option is given, the script doesn't check for PlayOnLinux Wine prefixes.

**NOTE:** PlayOnLinux Wine prefixes are checked for current user only.

**1)** Compile Wine Staging & DXVK, and make installable packages for them. Install the packages:

`bash updatewine.sh`

**2)** Compile DXVK and make an installable package for it. Do not install:

`bash updatewine.sh --no-wine --no-install`

**3)** Compile Wine Staging and make an installable package for it. Do not install:

`bash updatewine.sh --no-dxvk --no-install`

**4)** Compile Wine and make an installable package for it. Do not install:

`bash updatewine.sh --no-staging --no-dxvk --no-install`

**5)** Compile Wine & DXVK, and make installable packages for them. Do not install:

`bash updatewine.sh --no-staging --no-install`

**6)** Compile Wine Staging & DXVK, and make installable packages for them. Do not install:

`bash updatewine.sh --no-install`

**7)** Compile Wine & DXVK, and make installable packages for them. Install the packages:

`bash updatewine.sh --no-staging`

**8)** Compile Wine, and make an installable package for it. Install the package, do not check PlayOnLinux wineprefixes:

`bash updatewine.sh --no-staging --no-dxvk --no-pol`

----------------

## GPU drivers

For DXVK, it is strongly recommended that you install the latest Nvidia/AMDGPU drivers on your Linux distribution. For that purpose, Arch Linux/Manjaro users can use Arch/AUR package database. Debian/Ubuntu/Mint users should use provided scripts files

### GPU drivers on Debian/Ubuntu/Mint

**Nvidia users**

Use `debian_install_nvidia.sh` by running `bash debian_install_nvidia.sh`

**AMD users**

Not a solution provided yet.

**NOTE:** The latest GPU drivers are usually NOT available on official Debian/Ubuntu/Mint package repositories, thus these helper scripts are provided.

**NOTE:** Nvidia & AMD driver installer shell script can be run individually, as well. It is not bundled to the rest of the scripts in this repository, so feel free to grab them for other purposes, as well.

---------------------------

### NOTES

The following section contains important notes about the script usage.

**Do not pause a virtual machine**. It is not recommended to run this script in a virtualized environment (Oracle VirtualBox, for instance) if you plan to `Pause` the virtual machine during script runtime. This causes an internal sudo validate loop to get nuts. In normal environments and in normal runtime cases, this doesn't happen. Validate loop is required to keep sudo permissions alive for the script since the execution time exceeds default system-wide sudo timeout limit (which is a normal case).

---------------------------

### Script validation test

Validation test done for the script to ensure it works as expected. Occasional test-runs are mandatory due to rapid development of the packages (Wine/DXVK) it handles.

**Latest test-run:** 15th November, 2018

**Linux Distributions:** 

- Success: Arch Linux 64-bit, Linux Mint 19 64-bit, Ubuntu 18.04 64-bit

- Partial failure: Debian 9 64-bit (DXVK)

#### Failure reasons:

Debian:

- DXVK uninstallable: no winetricks package available

---------------------------

### TODO

- winetricks package for pure Debian users (DXVK runtime dependency)

- Add compilation/installation script for the latest AMDGPU on Debian/Ubuntu/Mint

- Remove temp folders in case of failure (meson/glslang/dxvk-git/wine... temp build folders)

- Better handling for sudo validation loop function

    - may cause the terminal output to get nuts

    - when interrupting the script, the exit functionality may not be handled correctly?

- The script doesn't handle SIGINT correctly while executing 'pkgdependencies' function

- Add non-interactive mode for Puppet, Ansible, SaltStack and for better automation?

    - Consider the following topics/issues while developing

        - supress any warning messages, or terminate script execution if requirements not met

        - supply sudo password or run as root?

        - sudo validation loop, how to handle correctly?

---------------------------

### LICENSE

This repository uses GPLv3 license. See [LICENSE](LICENSE) for details.
