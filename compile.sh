#!/bin/bash
mkdir -p compiled
cat > build.m <<END
addpath(genpath(pwd))
addpath(genpath('/Users/guiomar/Documents/SOFTWARE/brainstorm3'))
mcc -m -R -nodisplay -d compiled main
exit
END
matlab -nodisplay -nosplash -r build