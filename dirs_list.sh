#!/bin/ash
#
# dir_list.sh
#
# Get a list of directories and the number of files in them
#

DIRS="$(ls -Ad -1 $1*/)"

dir_size=""
all_files_num=""
trp_files_num=""
ent_files_num=""
other_files_num=""

printf "%6s %6s %6s %6s %6s %s\n" "Size" "Files" "trp" "ENT" "Others" "Directory"
for DIR in $DIRS; do
  dir_size="$(du -sh $DIR | awk '{print $1}')"
  all_files_num="$(find $DIR -type f | wc -l)"
  trp_files_num="$(find $DIR -type f -name '*.trp' | wc -l)"
  ent_files_num="$(find $DIR -type f -name '*.ENT' | wc -l)"
  other_files_num="$(find $DIR -type f ! -name '*.trp' -a ! -name '*.ENT' | wc -l)"
  printf "%6s %6s %6s %6s %6s %s\n" $dir_size $all_files_num $trp_files_num $ent_files_num $other_files_num $DIR
done
