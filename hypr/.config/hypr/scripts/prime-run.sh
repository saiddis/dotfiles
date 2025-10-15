#!/bin/bash
# prime-run: Run apps on NVIDIA GPU with PRIME Render Offload + NVDEC

export MOZ_DISABLE_RDD_SANDBOX=1

prime-run "$@"
