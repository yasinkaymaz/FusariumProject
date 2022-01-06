#!/bin/bash
#SOURCE PAGIT
source ~/Documents/PAGIT/sourceme.pagit

fastq=$1
contigs=$2
refFasta=$3
refEmbl=$4

#FILE AND FOLDER VARIABLES
WORKINGDIR=~/Documents/TEST
fastq=12_read
fastqLoc=${WORKINGDIR}/fastq
contigs=~/Documents/TEST/12_megahit_contig.fa
refFasta=GCF_000149955.1_ASM14995v2_genomic.fna
refLoc=${WORKINGDIR}/$refFasta
SAMPLE_NAME="Fox12"
fastq1=$fastqLoc"1.fastq"
fastq2=$fastqLoc"2.fastq"

echo
echo "Running Abacas:"
mkdir ${WORKINGDIR}/runABACAS_First
cd ${WORKINGDIR}/runABACAS_First

perl $PAGIT_HOME/ABACAS/joinMultifasta.pl $refLoc ${refFasta}_chrJoined.fa
chrJoined=${WORKINGDIR}/runABACAS_First/${refFasta}_chrJoined.fa

perl $PAGIT_HOME/ABACAS/abacas.pl -r $chrJoined -q $contigs -p nucmer -o "$SAMPLE_NAME"_abacas -d &> ../out.abacas.txt

echo "running splitABACASunion.pl"
perl $PAGIT_HOME/ABACAS/splitABACASunion.pl $refFasta $chrJoined "$SAMPLE_NAME"_abacas.fasta "$SAMPLE_NAME"_abacas.crunch "$SAMPLE_NAME"_abacas.tab

#CONCAT SEQUENCES
echo "running cat"
cat Split.ABACAS.fasta "$SAMPLE_NAME"_abacas.bin > "$SAMPLE_NAME"_abacas_mappedAndUnmaped.fasta

echo "ABACAS ran successfully!"
echo "Following gaps exit:"
cat *.gaps
cd ..

echo "Now starting IMAGE: (can take 3-10 minutes)"
mkdir ${WORKINGDIR}/runIMAGE_First
cd ${WORKINGDIR}/runIMAGE_First
ln -s -f ${WORKINGDIR}/runABACAS_First/"$SAMPLE_NAME"_abacas_mappedAndUnmaped.fasta
cp -s ${WORKINGDIR}/*.fastq .

$PAGIT_HOME/IMAGE/image.pl -scaffolds "$SAMPLE_NAME"_abacas_mappedAndUnmaped.fasta -prefix $fastq -iteration 1 -all_iteration 10 -dir_prefix ite -vel_ins_len 400 &> ../out.image.txt

contigs2scaffolds.pl ite10/new.fa ite10/new.read.placed 300 10 Res.image >> ../out.image.pl
cd ../
echo "IMAGE ran successfull!"
echo "Here the statistics:"
cd runIMAGE_First
image_run_summary.pl ite
echo "Looking at the contigs:"
stats contigs.fa | head -n 3
stats ite10/new.fa | head -n 3

cd ..
