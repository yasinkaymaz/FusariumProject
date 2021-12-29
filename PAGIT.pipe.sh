#!/usr/bin/bash


source /usr/local/bin/PAGIT/sourceme.pagit

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

perl abacas.pl \
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

perl image.pl \
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

perl abacas.pl \
-r GCF_000149955.1_ASM14995v2_genomic.fna \
-q $contigsFasta \
-p nucmer -b -t \
-o "$SAMPLE_NAME"_abacas

mkdir $WORKINGDIR/runIMAGE_last && cd $WORKINGDIR/runIMAGE_last

ln -s Raw_read_pairs_1.fastq ./
ln -s Raw_read_pairs_2.fastq ./

ln -s $WORKINGDIR/runABACAS_Second/"$SAMPLE_NAME"_abacas.fasta ./

scaffoldsFasta="$SAMPLE_NAME"_abacas.fasta
perl image.pl \
-scaffolds $scaffoldsFasta \
-prefix Raw_read_pairs \
-iteration 1 -all_iteration 2 -dir_prefix ite -kmer 147 -vel_ins_len 400

cd $WORKINGDIR/
