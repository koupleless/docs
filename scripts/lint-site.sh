#!/bin/bash
echo "Install dependencies"
./scripts/install-dependency.sh
echo -ne "mdspell "
mdspell --version
echo -ne "mdl "
mdl --version
