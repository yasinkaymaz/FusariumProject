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
#joinMultifasta
perl $PAGIT_HOME/ABACAS/joinMultifasta.pl $refLoc ${refFasta}_chrJoined.fa
chrJoined=${WORKINGDIR}/runABACAS_First/${refFasta}_chrJoined.fa
#RUN FIRST ABACAS
perl $PAGIT_HOME/ABACAS/abacas.pl -r $chrJoined -q $contigs -p nucmer -o "$SAMPLE_NAME"_abacas -d &> ../out.abacas.txt
#RUN ABACAS SPLIT
echo "running splitABACASunion.pl"
perl $PAGIT_HOME/ABACAS/splitABACASunion.pl $refFasta $chrJoined "$SAMPLE_NAME"_abacas.fasta "$SAMPLE_NAME"_abacas.crunch "$SAMPLE_NAME"_abacas.tab

#CONCAT SEQUENCES
echo "running cat"
cat Split.ABACAS.fasta "$SAMPLE_NAME"_abacas.bin > "$SAMPLE_NAME"_abacas_mappedAndUnmaped.fasta

echo "ABACAS ran successfully!"
echo "Following gaps exit:"
cat *.gaps
cd ..

#FIRST IMAGE CONTIG
echo "Now starting IMAGE: (can take 3-10 minutes)"
mkdir ${WORKINGDIR}/runIMAGE_First
cd ${WORKINGDIR}/runIMAGE_First
ln -s -f ${WORKINGDIR}/runABACAS_First/"$SAMPLE_NAME"_abacas_mappedAndUnmaped.fasta
cp -s ${WORKINGDIR}/*.fastq .
#RUN FIRST IMAGE
$PAGIT_HOME/IMAGE/image.pl -scaffolds "$SAMPLE_NAME"_abacas_mappedAndUnmaped.fasta -prefix $fastq -iteration 1 -all_iteration 2 -dir_prefix ite -vel_ins_len 400 &> ../out.image.txt

#POST IMAGE RESULTS
contigs2scaffolds.pl ite2/new.fa ite2/new.read.placed 300 10 Res.image >> ../out.image.pl
cd ../
echo "IMAGE ran successfull!"
echo "Here the statistics:"
cd runIMAGE_First
image_run_summary.pl ite
echo "Looking at the contigs:"
stats contigs.fa | head -n 3
stats ite2/new.fa | head -n 3

$contigs=${WORKINGDIR}/ABACAS_First/ite2/new.fa
cd ..

#SECOND RUN ABACAS CONFIG
echo "Configuring ABACAS_Second"
mkdir ${WORKINGDIR}/runABACAS_Second
cd ${WORKINGDIR}/runABACAS_Second

perl $PAGIT_HOME/ABACAS/joinMultifasta.pl $refLoc ${refFasta}_chrJoined.fa
chrJoined=${WORKINGDIR}/runABACAS_First/${refFasta}_chrJoined.fa

#SECOND ABACAS RUN
echo "running SECOND abacas.pl"
perl $PAGIT_HOME/ABACAS/abacas.pl -r $chrJoined -q $contigs -p nucmer -o "$SAMPLE_NAME"_abacas -d &> ../out.abacas2.txt
echo "running splitABACASunion.pl"
perl $PAGIT_HOME/ABACAS/splitABACASunion.pl $refFasta $chrJoined "$SAMPLE_NAME"_abacas.fasta "$SAMPLE_NAME"_abacas.crunch "$SAMPLE_NAME"_abacas.tab

#CONCAT SEQUENCES
echo "running cat"
cat Split.ABACAS.fasta "$SAMPLE_NAME"_abacas.bin > "$SAMPLE_NAME"_abacas_mappedAndUnmaped.fasta

#CONFIG SECOND IMAGE
cho "Configuring SECOND IMAGE"
mkdir ${WORKINGDIR}/runIMAGE_Second
cd ${WORKINGDIR}/runIMAGE_Second
cp -s ${WORKINGDIR}/*.fastq .
ln -s -f ${WORKINGDIR}/runABACAS_Second/"$SAMPLE_NAME"_abacas_mappedAndUnmaped.fasta
#RUN SECOND IMAGE
$PAGIT_HOME/IMAGE/image.pl -scaffolds "$SAMPLE_NAME"_abacas_mappedAndUnmaped.fasta -prefix $fastq -iteration 1 -all_iteration 2 -dir_prefix ite -vel_ins_len 400 &> ../out.image2.txt

#POST IMAGE STATS
contigs2scaffolds.pl ite2/new.fa ite2/new.read.placed 300 10 Res.image >> ../out.image.pl
cd ../
echo "IMAGE ran successfull!"
echo "Here the statistics:"
cd runIMAGE_Second
image_run_summary.pl ite
echo "Looking at the contigs:"
stats contigs.fa | head -n 3
stats ite2/new.fa | head -n 3

