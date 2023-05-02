#!/bin/bash

/home/jvliegen/bin/extractImages.sh images_lchip2.pdf setup ex1 soc soc_bkp ipcore_lite ipcore commands communicator synchroniser comm_ip

# convert setup.pdf setup.png
# convert ex1.pdf -resize 640 ex1.png
#convert soc.pdf -quality 100 soc.png

for fname in setup ex1 soc ipcore_lite ipcore commands communicator synchroniser
do
  convert           \
     -verbose       \
     -density 150   \
      $fname.pdf      \
     -quality 100   \
     -flatten       \
     -sharpen 0x1.0 \
      $fname.jpg
done
