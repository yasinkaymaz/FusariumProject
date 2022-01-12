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

<<<<<<< HEAD

bash /usr/local/bin/PAGIT/sourceme.pagit
#cd /usr/local/bin/ && ln -s /usr/bin/perl ./

WORKINGDIR="~/Documents/fusarium/Megahit_assembly_trimmed/temp/"
contigsFasta=megahit_12_trimmed.fa
REFDIR="~/Documents/fusarium/RefIdxFiles/"
SAMPLE_NAME="Fox-12"

cd $WORKINGDIR/

#ABACAS
mkdir runABACAS_First
cd runABACAS_First
ln -s $WORKINGDIR/$contigsFasta ./
ln -s $REFDIR/GCF_000149955.1_ASM14995v2_genomic.fna ./

perl joinMultifasta.pl GCF_000149955.1_ASM14995v2_genomic.fna GCF_000149955.1_ASM14995v2_genomic_chrJoined.fa

abacas.pl \
-r GCF_000149955.1_ASM14995v2_genomic_chrJoined.fa \
-q $contigsFasta \
-p nucmer -b -t \
-o "$SAMPLE_NAME"_abacas

perl splitABACASunion.pl GCF_000149955.1_ASM14995v2_genomic.fna \
GCF_000149955.1_ASM14995v2_genomic_chrJoined.fa \
"$SAMPLE_NAME"_abacas.fasta \
"$SAMPLE_NAME"_abacas.crunch \
"$SAMPLE_NAME"_abacas.tab


cat Split.ABACAS.fasta "$SAMPLE_NAME"_abacas.contigsInbin.fas > "$SAMPLE_NAME"_abacas_mappedAndUnmaped.fasta

#IMAGE
mkdir $WORKINGDIR/runIMAGE_First
cd $WORKINGDIR/runIMAGE_First

ln -s Raw_read_pairs_1.fastq ./
ln -s Raw_read_pairs_2.fastq ./

ln -s $WORKINGDIR/runABACAS_First/"$SAMPLE_NAME"_abacas_mappedAndUnmaped.fasta ./

image.pl \
-scaffolds "$SAMPLE_NAME"_abacas_mappedAndUnmaped.fasta \
-prefix Raw_read_pairs \
-iteration 1 \
-all_iteration 10 \
-dir_prefix ite \
-kmer 147 \
-vel_ins_len 400

#Second ABACAS
mkdir $WORKINGDIR/runABACAS_Second && cd $WORKINGDIR/runABACAS_Second
ln -s $WORKINGDIR/runIMAGE_First/ite10/new.fa ./
ln -s $REFDIR/GCF_000149955.1_ASM14995v2_genomic.fna ./

contigsFasta=new.fa

abacas.pl \
-r GCF_000149955.1_ASM14995v2_genomic.fna \
-q $contigsFasta \
-p nucmer -b -t \
-o "$SAMPLE_NAME"_abacas

mkdir $WORKINGDIR/runIMAGE_last && cd $WORKINGDIR/runIMAGE_last

ln -s Raw_read_pairs_1.fastq ./
ln -s Raw_read_pairs_2.fastq ./

ln -s $WORKINGDIR/runABACAS_Second/"$SAMPLE_NAME"_abacas.fasta ./

scaffoldsFasta="$SAMPLE_NAME"_abacas.fasta
image.pl \
-scaffolds $scaffoldsFasta \
-prefix Raw_read_pairs \
-iteration 1 -all_iteration 2 -dir_prefix ite -kmer 147 -vel_ins_len 400

cd $WORKINGDIR/
=======
>>>>>>> b0ed58d854e9944f6b254c952e654194c72fe56f
