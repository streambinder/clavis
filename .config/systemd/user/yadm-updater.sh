#!/bin/bash

set -euo pipefail

cd "${HOME}"

SHA_BEF="$(yadm rev-parse HEAD)"
echo "Updating YADM instance from ${SHA_BEF}"
(
	yadm pull
	yadm submodule update --init --recursive
) >/dev/null 2>&1
if [ "${SHA_BEF}" = "$(yadm rev-parse HEAD)" ]; then
	echo "YADM already up-to-date"
else
	echo "YADM correctly updated: bootstrapping"
	yadm bootstrap
fi
