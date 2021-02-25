FROM brainlife/mcr:2020a

#downloaded from https://neuroimage.usc.edu/bst/download.php
COPY bst_bin_R2020a_200616.zip /
RUN unzip /bst_bin_R2020a_200616.zip

ENTRYPOINT ["/brainstorm3/bin/R2020a/brainstorm3.command", "/opt/mcr/v98"]
