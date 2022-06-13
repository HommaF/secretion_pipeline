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
		signalP_mat = "output/{sample}/{sample}_signalP_mature.fasta",

	params:
		temp_out = "{sample}_summary.signalp5",
		temp_mat = "{sample}_mature.fasta"


	threads: 10

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
		targetP_out = "output/{sample}/{sample}_summary.targetp2",
		targetP_mat = "output/{sample}/{sample}_targetP_mature.fasta",

	params:
		temp_out = "{sample}_summary.targetp2",
		temp_mat = "{sample}_mature.fasta",
		org = "non-pl"


	threads: 10

	shell:
		"targetp -org {params.org} -fasta {input} -mature; "
		"mv {params.temp_out} {output.targetP_out};"
		"mv {params.temp_mat} {output.targetP_mat}"
	

rule tmhmm:
	input:
		"output/{sample}/{sample}_signalP_mature.fasta"
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
		mature_signalP = "output/{sample}/{sample}_signalP_mature.fasta",
		signalP_info = "output/{sample}/{sample}_summary.signalp5",
		mature_targetP = "output/{sample}/{sample}_targetP_mature.fasta"

	conda:
		"envs/python_tools.yaml"

	output:
		data = "output/{sample}/{sample}_molweight.tsv",
		mature = "output/{sample}/{sample}_molweight_mature.tsv",
		temp = temp("output/{sample}/{sample}_molweight_combined.fasta")

	threads: 1

	shell:
		"scripts/combine_signalP_targetP.sh {input.mature_signalP} {input.signalP_info} {input.mature_targetP} {output.temp}; "
		"scripts/mol_weight.py {input.data} {output.data}; "
		"scripts/mol_weight.py {output.temp} {output.mature}"

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
