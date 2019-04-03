#!/bin/bash

cd "${HOME}"

SHA_BEF="$(yadm rev-parse HEAD)"
echo "Updating YADM instance from ${SHA_BEF}"
yadm pull 2>&1 > /dev/null
if [ "${SHA_BEF}" = "$(yadm rev-parse HEAD)" ]; then
	echo "YADM already up-to-date"
else
	echo "YADM correctly updated: bootstrapping"
	yadm bootstrap
fi
