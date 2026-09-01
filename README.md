# Base OVMF

[![Light Squares Attestable Builds](https://app.lightsquares.dev/api/badge/lightsquares/base-ovmf.svg)](https://app.lightsquares.dev/builds/dashboard?show=lightsquares/base-ovmf)

Builds the pinned AMD SEV-SNP OVMF firmware used by the confidential VM base image.

```sh
podman build -t base-ovmf-builder .
podman run --rm -v "$PWD:/workspace" -w /workspace \
  base-ovmf-builder ./build.sh
```

The firmware is written to `dist/OVMF.fd`.
