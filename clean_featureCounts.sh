#!/bin/bash

# Simple bash script to clean counts produced by Subread featureCounts function
# Run by executing "bash clean_feat_counts.sh input.count > output.count"
# Keeps only gene id and count columns, with no headers

file=$1
output=$file.clean

cut -f1,7 $file | tail -n +3 > $output
