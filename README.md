# gifoverlay.sh
overlay a picture ontop a gif.

see the script for possibly more up to date options

the main script is gifoverlay.sh

\- gifoverlay.sh -

A tool for overlaying stuff in gifs

usage: gifoverlay.sh [options] [gif to use as template] [image to overlay]

Options available:

-h , --help : lists this help

-t , --tile : tile the gif (thanks to stackoverflow user GeeMack!)

-m=foo , --mask=foo : use the file foo for a mask (this copies the alpha channel of the template) (thanks to @piconaut for help!)

-o , --optimize : optimize the gif layers.

-f=bar , --file=bar : save to the file named bar
