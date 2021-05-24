configfile: "config.json"

rule all:
	input:
		expand("output/{sample}/{sample}_secretion.tsv", sample=config["samples"])


rule signalP:
	input:
		data = "data/{sample}.fasta"
	conda:
		"envs/python_tools.yaml"


	output:
		signalP_out = "output/{sample}/{sample}_summary.signalp5",
		signalP_mat = "output/{sample}/{sample}_mature.fasta",

	params:
		temp_out = "{sample}_summary.signalp5",
		temp_mat = "{sample}_mature.fasta"


	threads: 12

	shell:
		"signalp -fasta {input.data} -mature; "
		"mv {params.temp_out} {output.signalP_out}; "
		"mv {params.temp_mat} {output.signalP_mat}"

rule ApoplastP:
	input:
		data = "data/{sample}.fasta"
	conda:
		"envs/python_tools.yaml"


	output:
		out = "output/{sample}/{sample}_summary.apop"

	params:
		dummy = "output/{sample}/{sample}_dummy.apop"


	threads: 1

	shell:
		"python2.7 /home/homma/software/ApoplastP_1.0.1/Scripts/ApoplastP.py -o {output.out} -i {input.data}"


rule targetP:
	input:
		"data/{sample}.fasta"
	conda:
		"envs/python_tools.yaml"


	output:
		"output/{sample}/{sample}_summary.targetp2"

	params:
		outfile = "{sample}_summary.targetp2",
		org = "pl"


	threads: 12

	shell:
		"targetp -org {params.org} -fasta {input}; "
		"mv {params.outfile} {output}"
	

rule tmhmm:
	input:
		"output/{sample}/{sample}_mature.fasta"
	output:
		"output/{sample}/{sample}_summary.tmhmm"
	conda:
		"envs/python_tools.yaml"

	threads: 1

	shell:
		"tmhmm {input} > {output}"


rule molecular_weight:
	input:
		data = "data/{sample}.fasta",
		mature = "output/{sample}/{sample}_mature.fasta"

	conda:
		"envs/python_tools.yaml"

	output:
		data = "output/{sample}/{sample}_molweight.tsv",
		mature = "output/{sample}/{sample}_molweight_mature.tsv"

	threads: 1

	shell:
		"scripts/mol_weight.py {input.data} {output.data}; "
		"scripts/mol_weight.py {input.mature} {output.mature}"

rule combine:
	input:
		molw = "output/{sample}/{sample}_molweight.tsv",
		molw_mature = "output/{sample}/{sample}_molweight_mature.tsv",
		signalp = "output/{sample}/{sample}_summary.signalp5",
		apop = "output/{sample}/{sample}_summary.apop",
		targetp = "output/{sample}/{sample}_summary.targetp2",
		tmhmm = "output/{sample}/{sample}_summary.tmhmm"
	params:
		sample = "{sample}",
		tmp = "output/{sample}/tmp_outfile.tsv",
		rmv = "output/{sample}/tmp*"
	conda:
		"envs/python_tools.yaml"


	output:
		"output/{sample}/{sample}_secretion.tsv"


	shell:
		"scripts/combine_files.sh {params.tmp} {params.sample} {input.signalp} {input.apop} {input.targetp} {input.molw}; "
		"scripts/combine_files.py {params.tmp} {input.molw_mature} {input.tmhmm} {output}; "
		"rm {params.rmv}"
