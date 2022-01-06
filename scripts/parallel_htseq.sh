#!/bin/bash
# parallel_htseq.sh

### Example
#
# Make the script executable
# sudo chmod u+x parallel_htseq.sh
#
# Execute
# bash parallel_htseq.sh star_files/ count_files/ path/to/annotations.gtf

# First argument is the input directory, second is output directory, third is
# the annotation file
input_dir=$1
output_dir=$2
gtf=$3

# List all the appropriate files, and send to the parallel command
find $input_dir -name "*.bam" | parallel --jobs 6 "htseq-count -s reverse -a 10 -f bam -r pos {} $gtf > $output_dir/{/.}.count"
printf "Completed htseq-count. Fixing output file names...\n"

### NOTICE ###
# Depending on the names of your output STAR files, you may need to change the
# string being used in this for loop to identify and rename files. Currently, the
# string "_Aligned.sortedByCoord.out" is removed from output count file names
for file in $output_dir/*_Aligned.sortedByCoord.out.count; do
        mv "$file" "${file//_Aligned.sortedByCoord.out/}"
done
printf "Done.\n"
exit 0
