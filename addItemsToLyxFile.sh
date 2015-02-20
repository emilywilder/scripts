#!/usr/bin/env bash

# Script to add terms from a plaintext file to a LyX document
# in the enumerate layout

if [ -z "$1" -o -z "$2" -o -z "$3" ]; then
    echo "usage: $0 <src-file> <lyx-infile> <lyx-outfile>" >&2
    exit 1
fi
# make sure src-file is readable
if [ ! -r "${1}" ]; then
    echo "Missing src-file: ${1}" >&2
    exit 1
fi
# clean existing lyx-outfile if exists
if [ -f "${3}" ]; then
    echo "Found ${3}, deleting..."
    if ! > "${3}"; then
        echo "Error deleting ${3}..." >&2
        exit 1
    fi
fi
# iterate of list of terms
cat "${2}" | while read -r src_line; do
    # if the line is the end of the document, start inserting terms
    if [[ "${src_line}" == "\\end_body" ]]; then
        cat "${1}" |
            cut -d\  -f2- |
            while read item ; do
                echo "Processing ${item}..."
                printf "%s\n%s\n%s\n\n" "\\begin_layout Enumerate" "${item}" "\\end_layout" >> "${3}"
            done
    fi
    printf "%s\n" "${src_line}" >> "${3}"
done

