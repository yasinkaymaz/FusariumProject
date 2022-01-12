
#conda activate DAB
InFasta=$1
InAGP=$2
python ~/Dropbox/codes/CGTools/fasta_to_tab.py $InFasta


rm "${InFasta}".rc.fixed.fasta

while read line
do
    chr=$(echo $line|awk '{print $1}')
    grep -v "#" "${InAGP}"|grep -v Chr0_ |grep -w $chr > "${InAGP}".tmp

    chr_scaffold=$(echo $line|awk '{print $2}')
    newseq=''
    while read coord
    do
        str=$(echo $coord| awk '{print $2}')
        end=$(echo $coord| awk '{print $3}')
        stu=$(echo $coord| awk '{print $5}')
        strnd=$(echo $coord| awk '{print $9}')

        if [ "$stu" = "W" ]
        then
            seq=$(echo $chr_scaffold| cut -b $str-$end)
            if [ "$strnd" = "-" ]
            then
                #"taking a reverse complement"
                fixedseq=`echo $seq|rev | tr "ATGCNatgcn" "TACGNTACGN"`;
                echo "$chr\t$str\t$end\t$strnd"
            else
                fixedseq=$seq
            fi
        else
            fixedseq=$(printf "%0.sN" {1..100})
        fi
        newseq=$newseq$fixedseq
    done < "${InAGP}".tmp

    echo ">$chr\n$newseq" >> "${InFasta}".rc.fixed.fasta

done < "${InFasta}".tab
