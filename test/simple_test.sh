#!/bin/bash

# look for MindTheGap binary. In devel mode, it's in ../build/bin directory.
# In production mode, it's in ../bin directory.
if [ -f "../bin/MindTheGap" ]
then
 bindir="../bin"
elif [ -f "../build/bin/MindTheGap" ]
then
 bindir="../build/bin"
else
 echo "could not find a compiled Bloocoo binary"
 exit 1
fi


run_test()
{
    # param : reads_file ref_file true_result prefix
    $bindir/MindTheGap find -in $1 -ref $2 -kmer-size 31 -out output/$4_find $5 1> output/$4_find.out 2> output/$4_find.err

    $bindir/MindTheGap fill -bkpt output/$4_find.breakpoints -graph output/$4_find.h5  -out output/$4_fill 1> output/$4_fill.out 2> output/$4_fill.err

    diff --ignore-matching-lines=">" output/$4_fill.insertions $3 1> /dev/null 2>&1

    var=$?
    if [ $var -eq 0 ]
    then
	echo "passed"
    else
	echo "FAILED"
    fi
}

mkdir -p output
output=""

output=$output"clean-insert : "
output=$output$(run_test reads/master.fasta references/deleted.fasta truths/insertion.fasta k-1 "-insert-only")

output=$output"\n1-SNP : "
output=$output$(run_test reads/master.fasta references/sSNP.fasta truths/sSNP.fasta sSNP "-snp-only")

output=$output"\n3-SNP*2 : "
output=$output$(run_test reads/master.fasta references/multiSNP.fasta truths/multiSNP.fasta multiSNP "-snp-only")

output=$output"\nsnp-before-clean-insert : "
output=$output$(run_test reads/master.fasta references/deleted_before_SNP.fasta truths/insertion_before_SNP.fasta k-1_before_SNP "-no-deletion -homo-only")

output=$output"\nsnp-begin-fuzzy : "
output=$output$(run_test reads/beginfuzzySNP.fasta references/beginfuzzySNP.fasta truths/beginfuzzySNP.fasta beginfuzzySNP "-snp-only")

output=$output"\nhetero-insert : "
output=$output$(run_test reads/deleted.fasta,reads/master.fasta references/deleted.fasta truths/insertion.fasta hete "-hete-only -max-rep 2")

output=$output"\ndeletion : "
output=$output$(run_test reads/deleted.fasta references/master.fasta truths/deletion.fasta deletion "-deletion-only")

output=$output"\nfuzzy-deletion : "
output=$output$(run_test reads/deletionfuzzy.fasta references/deletionfuzzy.fasta truths/deletionfuzzy.fasta deletionfuzzy "-deletion-only")

output=$output"\nn-in-solid-stretch : "
output=$output$(run_test reads/master.fasta references/n_in_stretch.fasta truths/n_in_stretch.fasta n_in_stretch "-insert-only")

output=$output"\nn-in-before-clean-insert : "
output=$output$(run_test reads/master.fasta references/n_before_gap.fasta truths/n_before_gap.fasta n_before_gap "-insert-only")

output=$output"\nn-after-clean-insert : "
output=$output$(run_test reads/master.fasta references/n_after_gap.fasta truths/n_after_gap.fasta n_after_gap "-insert-only")


echo -e $output | column -t