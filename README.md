# NaniteOS

A hybrid kernel operating system built with artificial general intelligence integration.

Current goals:
- Boot from MBR and UEFI
- Produce buildable .img/.iso artifacts for x86, x86_64, and ARM
- Development environments: Debian, Fedora, Arch, WSL
- Test environments: QEMU, VirtualBox, VMware

Repository layout (initial):
- nanoid/              # Microkernel (Nanoid)
- agi/                 # AGI/SLM integration and services
- integration/         # Linux kernel patches and integration layer (do NOT vendor full kernel)
- build/               # Build scripts and CI helpers
- docs/                # Architecture and design documents
- tests/               # Testing tooling and harnesses (QEMU images, unit tests)
- scripts/             # Utility scripts for environment setup and tooling

See docs/ARCHITECTURE.md for a first-draft architecture overview.
