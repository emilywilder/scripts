ls | while read a ; do
    echo -n "$a..."
    if ! ps2pdf -dEPSCrop "$a" &>/dev/null ; then
        echo "ps2pdf $a" >> failed.log
        echo "failed"
    else
        if ! pdf2svg "${a%%.eps}.pdf" "${a%%.eps}.svg" ; then
            echo "pdf2svg $a" >> failed.log
            echo "failed"
        else
            echo "OK"
        fi
    fi
done
