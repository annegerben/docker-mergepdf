# docker-mergepdf

Docker container that watches a folder for odd and even pdf files and merges them via pdftk. 
Ideal when your scanner has an automatic document feeder (ADP) but it's single sided.

### usage
The container expects a volume `/srv/input` as the folder that is watched and `/srv/output` as the folder for the merged file. The current syntax expects a file that named `scan_o.pdf` (for odd) containing the odd pages of a dualside scan and a file named `scan_e.pdf` for the even pages. As you can see in the executed script `mergepdf.sh` pdftk is called with the `shuffle A Bend-1` parameter. That means one could first scan all odd pages than turn arround the whole staple of sheets and scan the even pages beginning with the last page.

I use https://hub.docker.com/r/coppit/inotify-command to rename input files from the scanner.
