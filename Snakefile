working_dir = "/home/jiajinbu/nas3/lzz/chip"
hg19_index = "/home/jiajinbu/nas3/lzz/hg19_index/hg19_only_chromosome"

control_samples = "293_chip-seq_control"

SAMPLES = ["293_chip-seq_H3K36me3"]
REP = [1,2]

treatment = expand(working_dir + "/sam_result/{sample}_rep{rep}.bam", sample=SAMPLES, rep=REP)

rule all:
    input:
        working_dir + "/call_peak_result/peaks.narrowPeak"

rule mapping_by_bowtie2:
    input:
        working_dir + "/raw_data/{sample}_rep{rep}_R1.fastq.gz",
    output:
        working_dir + "/sam_result/{sample}_rep{rep}.sam"
    threads:12
    shell:
        "bowtie2 -p {threads} -x {hg19_index} -U {input} -S {output}"

rule sam_to_sorted_bam:
    input:
        working_dir + "/sam_result/{sample}_rep{rep}.sam"
    output:
        working_dir + "/sam_result/{sample}_rep{rep}.bam"
    threads:8
    shell:
        "samtools sort -@ {threads} -o {output} {input}"

rule macs2_call_peak:
    input:
        treatment,
        control = working_dir + "/sam_result/" + control_samples + "_rep1.bam"
    output:
        working_dir + "/call_peak_result/peaks.narrowPeak",
        dir = working_dir + "/call_peak_result"
    params:
        treatmant_samples = " ".join(treatment),
        prefix="".join(SAMPLES)
    shell:
        "macs2 callpeak -t {params.treatmant_samples} -c {input.control} -f BAM -g hs --outdir {output.dir} -n {params.prefix}"
