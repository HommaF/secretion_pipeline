configfile: "config.json"

rule all:
	input:
		expand("output/signalP/{sample}_signalP.fasta", sample=config["samples"])


rule signalP:
	input:
		"data/{sample}.fasta"

	output:
		signalP_out = "output/signalP/{sample}_signalP.fasta",
		signalP_mat = "output/signalP/{sample}_mature.fasta"

	threads: 1

	shell:
		"/home/homma/software/signalp-5.0b.Linux/signalp-5.0b/bin/signalp -fasta {input} -mature {output.signalP_mat} > {output.signalP_out}"

