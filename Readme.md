[![Nightly Release Status](https://github.com/naev/naev/workflows/Nightly%20Release/badge.svg)](https://github.com/naev/naev/actions?query=workflow%3A%22Nightly+Release%22) [![CI Status](https://github.com/naev/naev/workflows/CI/badge.svg)](https://github.com/naev/naev/actions?query=workflow%3ACI) [![Packaging status](https://repology.org/badge/tiny-repos/naev.svg)](https://repology.org/project/naev/versions) [![Translation Status](https://hosted.weblate.org/widgets/naev/-/naev/svg-badge.svg)](https://hosted.weblate.org/projects/naev/)
# NAEV README

![Naev Logo](https://naev.org/imgs/naev.png)

Naev is a 2D space trading and combat game, taking inspiration from the [Escape
Velocity series](https://en.wikipedia.org/wiki/Escape_Velocity_(video_game)), among others.

You pilot a space ship from a top-down perspective, and are more or less free
to do what you want. As the genre name implies, you’re able to trade and engage
in combat at will. Beyond that, there’s an ever-growing number of storyline
missions, equipment, and ships; Even the galaxy itself grows larger with each
release. For the literarily-inclined, there are large amounts of lore
accompanying everything from planets to equipment.

## DEPENDENCIES

Naev's dependencies are intended to be relatively common. In addition to an
OpenGL-capable graphics card and driver with support for at least OpenGL 3.1,
Naev requires the following:
* SDL 2
* libxml2
* freetype2
* GLPK
* libpng
* libwebp
* OpenAL
* OpenBLAS
* libvorbis >= 1.2.2
* binutils
* intltool

If you're cross-compiling for Windows, you must install this soft dependency:
* [physfs](https://icculus.org/physfs/), example package name mingw-w64-physfs


### Linux and non-macOS \*nix

See [here](https://github.com/naev/naev/wiki/Compiling-on-*nix) for package lists for several
distributions.

### macOS

Warning: this procedure is inadequate if you want to build a Naev.app that you can share with users of older macOS versions than your own.

Dependencies may be installed using [Homebrew](https://brew.sh):
```
brew install freetype gettext glpk intltool libpng libvorbis luajit meson openal-soft physfs pkg-config sdl2_image suite-sparse
```
Building the latest available code in git is recommended, but to build version 0.8 you can add `sdl2_mixer` (and `autoconf-archive` and `automake` if using Autotools to build).

Meson needs an extra argument to find Homebrew's `openal-soft` package: `--pkg-config-path=/usr/local/opt/openal-soft/lib/pkgconfig`.
If build may fail if `suite-sparse` is installed via Homebrew, citing an undefined reference to `_cs_di_spfree`. A workaround is to pass `--force-fallback-for=SuiteSparse`.
(These arguments may be passed to the initial `meson setup` or applied later using `meson configure`. In the later case, make sure to run `meson configure --clearcache` to work around bugs in Meson. For 0.8/Autotools, set the `PKG_CONFIG_PATH` environment variable before running `./configure`.)

Naev 0.9 needs a BLAS library. To use Apple's, add `-Dblas=Accelerate` to your Meson options. You can also install `openblas` via Homebrew, but you'll have to follow its instructions carefully before Meson will be able to detect it. (Official builds are prepared using OSXCross, which bypasses a lot of problems with Homebrew and Apple's toolchain, but is also more difficult to set up.)

## COMPILING

### CLONING AND SUBMODULES

Naev requires the artwork submodule to run from git. You can check out the
submodules from the cloned repository with:

```bash
git submodule init
git submodule update
```

Note that `git submodule update` has to be run every time you `git pull` to stay
up to date. This can also be done automatically by setting the following
configuration:

```bash
git config submodule.recurse true
```

### COMPILATION

Run:

```bash
meson setup builddir .
cd builddir
meson compile
./naev.sh
```

If you need special settings you can run `meson configure` in your build
directory to see a list of all available options.

**For installation**, try: `meson configure --buildtype=release -Db_lto=true`

**For Windows packaging**, try adding: `--bindir=bin -Dndata_path=bin`

**For macOS**, try adding: `--prefix="$(pwd)"/build/dist/Naev.app --bindir=Contents/MacOS -Dndata_path=Contents/Resources`

**For normal development**, try adding: `--buildtype=debug -Db_sanitize=address` (adding `-Db_lundef=false` if compiling with Clang, substituting `-Ddebug_arrays=true` for `-Db_sanitize=...` on Windows if you can't use Clang).

**For faster debug builds** (but harder to trace with gdb/lldb), try `--buildtype=debugoptimized -Db_lto=true -Db_lto_mode=thin` in place of the corresponding values above.

## INSTALLATION

Naev currently supports `meson install` which will install everything that
is needed.

If you wish to create a .desktop for your desktop environment, logos
from 16x16 to 256x256 can be found in `extras/logos/`.

## WINDOWS

See https://github.com/naev/naev/wiki/Compiling-on-Windows for how to compile on windows.

## UPDATING ART ASSETS

Art assets are partially stored in the naev-artwork-production repository and
sometimes are updated. For that reason, it is recommended to periodically
update the submodules with the following command.

```bash
git submodule update
```

You can also set this to be done automatically on git pull with the following
command:

```bash
git config submodule.recurse true
```

Afterwards, every time you perform a `git pull`, it will also update the
artwork submodule.

## TRANSLATION

Naev supports unicode and gettext since version 0.8.0.

### ONLINE TRANSLATION

Naev is incorporated into Weblate. You can easily translate directly with a web
interface to your chosen language at
https://hosted.weblate.org/projects/naev/naev/ .

### MANUAL TRANSLATION

If you are a developer, you may need to update translation files as
text is modified. You can update all translation files with the
following commands:

```bash
meson compile potfiles        # necessary if files have been added or removed
meson compile naev-pot        # necessary if translatable strings changed
meson compile naev-update-po  # necessary outside the main line, where Weblate handles it
```

This will allow you to edit the translation files in `po/` manually to modify
translations.

If you like, you can set up commit hooks to handle the `potfiles` step. For instance:
```bash
# .git/hooks/pre-commit
#!/bin/bash
. utils/update-po.sh

# .git/hooks/post-commit
#!/bin/sh
git diff --exit-code po/POTFILES.in || exec git commit --amend -C HEAD po/POTFILES.in
```

## CRASHES & PROBLEMS

Please take a look at the [FAQ](https://github.com/naev/naev/wiki/FAQ) before submitting a new
bug report, as it covers a number of common gameplay questions and
common issues.

If Naev is crashing during gameplay, please file a bug report after
reading https://github.com/naev/naev/wiki/Bugs

