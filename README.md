## Template devcontainer for Visual Studio Code and NES development.

Includes CA65, make, and an extension to highlight 6502 assembler.

After container is built, devcontainer will run [get-nes-dependencies.sh](.devcontainer/scripts/get-nes-dependencies.sh) which will download headers and macros from CA65 into the [./include/](./include/) and [./macros/](./macros/) directories for the current `CA65` version.

[makefile](./makefile) looks for `main.asm` in [./src/](./src/) directory and build artifacts to [./out/](./out/).
