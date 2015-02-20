#!/usr/bin/env bash

# Script to add terms from a plaintext file to a LyX document
# in the enumerate layout

if [ -z "$1" -o -z "$2" ]; then
    echo "usage: $0 <src-file> <lyx-file>" >&2
    exit 1
fi

# make sure src-file is readable
if [ ! -r "${1}" ]; then
    echo "Missing src-file: ${1}" >&2
    exit 1
else
    # make a backup
    if ! cp "${2}" "${2}.bak"; then
        echo "unable to create backup file: ${2}.bak" >&2
        exit 1
    fi
fi

# create a temporary file to store new document
if ! _tmpdir="$(mktemp -dt $(basename $0).XXXXXXXX)"; then
    echo "unable to create temp dir" >&2
    exit 1
else
    _tmpfile="${_tmpdir}/tmpfile"
fi

# iterate of list of terms
cat "${2}" | while read -r src_line; do
    # if the line is the end of the document, start inserting terms
    if [[ "${src_line}" == "\\end_body" ]]; then
        cat "${1}" |
            cut -d\  -f2- |
            while read item ; do
                echo "Processing ${item}..."
                printf "%s\n%s\n%s\n\n" "\\begin_layout Enumerate" "${item}" "\\end_layout" >> "${_tmpfile}"
            done
    fi
    printf "%s\n" "${src_line}" >> "${_tmpfile}"
done

# copy tmpfile to lyx document
if ! cp "$_tmpfile" "${2}"; then
    echo "unable to copy tmpfile to lyx-file" >&2
    exit 1
else
    # cleanup tmpdir
    if [ -d "$_tmpdir" ]; then
        rm -rf "$_tmpdir"
    fi
fi
