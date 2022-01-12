
#conda activate DAB

python ~/Dropbox/codes/CGTools/fasta_to_tab.py ragtag.scaffold.fasta


rm fasta.tmp

while read line
do
    chr=$(echo $line|awk '{print $1}')
    grep -v "#" ragtag.scaffold.agp|grep -w $chr > ragtag.scaffold.agp.tmp

    chr_scaffold=$(echo $line|awk '{print $2}')
    newseq=''
    while read coord
    do
        str=$(echo $coord| awk '{print $2}')
        end=$(echo $coord| awk '{print $3}')
        seq=$(echo $chr_scaffold| cut -b $str-$end)
        stu=$(echo $coord| awk '{print $5}')
        strnd=$(echo $coord| awk '{print $9}')

        if [ "$stu" = "W" ]
        then
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
    done < ragtag.scaffold.agp.tmp

    echo ">$chr\n$newseq" >> fasta.tmp

done < ragtag.scaffold.fasta.tab
