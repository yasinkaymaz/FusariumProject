#!/usr/bin/bash

#SOURCE PAGIT
source ~/Documents/PAGIT/sourceme.pagit

#FILE AND FOLDER VARIABLES
WORKINGDIR=~/Documents/TEST
fastq=12_read
fastqLoc=${WORKINGDIR}/fastq
contigs=~/Documents/TEST/12_megahit_contig.fa
refFasta=GCF_000149955.1_ASM14995v2_genomic.fna
refLoc=${WORKINGDIR}/$refFasta
SAMPLE_NAME="TEST_ABA"
fastq1=$fastqLoc"1.fq"
fastq2=$fastqLoc"2.fq"

#ABACAS CONFIG
echo "Configuring ABACAS_First"
mkdir ${WORKINGDIR}/runABACAS_First
cd ${WORKINGDIR}/runABACAS_First
ln -s ../$contigs
ln -s ../$refFasta

#JOIN FOR ABACAS
echo "running joinMultifasta.pl"
perl $PAGIT_HOME/ABACAS/joinMultifasta.pl ${refLoc} ${refFasta}_chrJoined.fa
chrJoined=${WORKINGDIR}/runABACAS_First/${refFasta}_chrJoined.fa

#FIRST ABACAS RUN
echo "running abacas.pl"
perl $PAGIT_HOME/ABACAS/abacas.pl \
-r $chrJoined \
-q $contigs \
-p nucmer \
-o "$SAMPLE_NAME"_abacas

#SPLIT ABACAS
echo "running splitABACASunion.pl"
perl $PAGIT_HOME/ABACAS/splitABACASunion.pl $refFasta $chrJoined \
"$SAMPLE_NAME"_abacas.fasta \
"$SAMPLE_NAME"_abacas.crunch \
"$SAMPLE_NAME"_abacas.tab

#CONCAT SEQUENCES
echo "running cat"
cat Split.ABACAS.fasta "$SAMPLE_NAME"_abacas.bin > "$SAMPLE_NAME"_abacas_mappedAndUnmaped.fasta

#IMAGE CONFIG
echo "Configuring IMAGE"
mkdir ${WORKINGDIR}/runIMAGE_First
cd ${WORKINGDIR}/runIMAGE_First
cp -s ${WORKINGDIR}/*.fq .
ln -s -f ${WORKINGDIR}/runABACAS_First/"$SAMPLE_NAME"_abacas_mappedAndUnmaped.fasta
echo "*************************************"

#FIRST IMAGE RUN
echo "running IMAGE"
$PAGIT_HOME/IMAGE/image.pl \
-scaffolds "$SAMPLE_NAME"_abacas_mappedAndUnmaped.fasta -prefix $fastq -iteration 1 \
-all_iteration 10 \
-dir_prefix ite \
-vel_ins_len 400

#SECOND RUN ABACAS CONFIG
echo "Configuring ABACAS_Second"
mkdir ${WORKINGDIR}/runABACAS_Second
cd ${WORKINGDIR}/runABACAS_Second
ln -s -f ${WORKINGDIR}/runIMAGE_First/ite10/new.fa
#SET NEW CONTIG
contigs=new.fa

echo "running joinMultifasta.pl"
perl $PAGIT_HOME/ABACAS/joinMultifasta.pl ${refLoc} ${refFasta}_chrJoined.fa
chrJoined=${WORKINGDIR}/runABACAS_Second/${refFasta}_chrJoined.fa

#SECOND ABACAS RUN
echo "running SECOND abacas.pl"
perl $PAGIT_HOME/ABACAS/abacas.pl \
-r $chrJoined \
-q $contigs \
-p nucmer \
-o "$SAMPLE_NAME"_abacas

#SPLIT ABACAS
echo "running splitABACASunion.pl"
perl $PAGIT_HOME/ABACAS/splitABACASunion.pl $refFasta $chrJoined \
"$SAMPLE_NAME"_abacas.fasta \
"$SAMPLE_NAME"_abacas.crunch \
"$SAMPLE_NAME"_abacas.tab

#CONCAT SEQUENCES
echo "running cat"
cat Split.ABACAS.fasta "$SAMPLE_NAME"_abacas.bin > "$SAMPLE_NAME"_abacas_mappedAndUnmaped.fasta

#SECOND IMAGE CONFIG
echo "Configuring SECOND IMAGE"
mkdir ${WORKINGDIR}/runIMAGE_Second
cd ${WORKINGDIR}/runIMAGE_Second
cp -s ../*.fq .
ln -s -f ${WORKINGDIR}/runABACAS_Second/"$SAMPLE_NAME"_abacas_mappedAndUnmaped.fasta
echo "*************************************"

#SECOND IMAGE RUN
echo "running SECOND IMAGE"
$PAGIT_HOME/IMAGE/image.pl \
-scaffolds "$SAMPLE_NAME"_abacas.fasta -prefix $fastq -iteration 1 \
-all_iteration 2 \
-dir_prefix ite \
-vel_ins_len 400

cd $WORKINGDIR
