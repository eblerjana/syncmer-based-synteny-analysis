rule run_syng_path:
	"""
	Construct a syncmer graph.
	"""
	input:
		assemblies = set([asm for asm in SAMPLE_TO_FILENAME.values()])
	output:
		path = "{results}/syng/syncmere-graph.1path",
		khash = "{results}/syng/syncmere-graph.1khash"
	log:
		"{results}/syng/syncmere-graph.log"
	benchmark:
		"{results}/syng/syncmere-graph.benchmark"
	threads: 4
	resources:
		mem_mb = 10000,
		walltime = "05:00:00"
	params:
		outname = "{results}/syng/syncmere-graph"
	shell:
		"""
		{SYNG}/syng -T {threads} -o {params.outname} -w {WINDOW_LEN} -k {KMER_LEN} -writeK -outputEnds -writePath {input} &> {log}
		"""
		


rule generate_syncmer_stats_path:
	"""
	Determine the number of unique syncmers
	across all paths, using path data.
	"""
	input:
		path = "{results}/syng/syncmere-graph.1path",
		khash = "{results}/syng/syncmere-graph.1khash"
	output:
		sync_stats = "{results}/stats/statistics_path_syncmers.tsv",
		histo_stats = "{results}/stats/statistics_path_histogram.tsv"
	resources:
		mem_mb = 10000,
		walltime = "05:00:00"
	log:
		"{results}/stats/statistics_path.log"
	benchmark:
		"{results}/stats/statistics_path.benchmark"
	threads: 1
	params:
		outname = "{results}/stats/statistics_path"
	shell:
		"""
		{SYNCMER_TOOLKIT} histogram {input.path} {input.khash} {params.outname} &> {log}
		"""


rule generate_distance_stats_path:
	"""
	Determine the number of unique syncmers
	across all paths, using path data.
	"""
	input:
		path = "{results}/syng/syncmere-graph.1path",
		khash = "{results}/syng/syncmere-graph.1khash",
		syncmers = "{results}/stats/statistics_path_syncmers.tsv"
	output:
		"{results}/syncmers/syncmers_{sample}_{interval}.tsv"
	resources:
		mem_mb = 10000,
		walltime = "05:00:00"
	log:
		"{results}/syncmers/syncmers_{sample}_{interval}.log"
	benchmark:
		"{results}/syncmers/syncmers_{sample}_{interval}.benchmark"
	threads: 1
	params:
		filename = lambda wildcards: SAMPLE_TO_FILENAME[wildcards.sample]
	shell:
		"""
		{SYNCMER_TOOLKIT} query {input.path} {input.khash} {input.syncmers} {params.filename} {wildcards.interval} {output} &> {log}
		"""


def input_create_paf(wildcards):
	file_s1 = "{results}/syncmers/syncmers_{samplename}_{interval}.tsv".format(results = wildcards.results, samplename = wildcards.sample1, interval = SAMPLE_TO_INTERVAL[wildcards.sample1])
	file_s2 = "{results}/syncmers/syncmers_{samplename}_{interval}.tsv".format(results = wildcards.results, samplename = wildcards.sample2, interval = SAMPLE_TO_INTERVAL[wildcards.sample2])
	return [file_s1, file_s2]


rule create_paf:
	"""
	Create PAF file of both haplotypes of a sample.
	"""
	input:
		hap1 = lambda wildcards: input_create_paf(wildcards)[0],
		hap2 = lambda wildcards: input_create_paf(wildcards)[1]
	output:
		paf = "{results}/paf/align_{sample1}_{sample2}.paf",
		tmp1 = temp("{results}/paf/align_{sample1}_{sample2}_forward.paf"),
		tmp2 = temp("{results}/paf/align_{sample1}_{sample2}_reverse.paf")
	log:
		forward = "{results}/paf/align_{sample1}_{sample2}_forward.log",
		reversed = "{results}/paf/align_{sample1}_{sample2}_reverse.log"
	resources:
		mem_mb = 10000,
	benchmark:
		"{results}/paf/align_{sample1}_{sample2}.benchmark"
	params:
		len_h1 = lambda wildcards: SAMPLE_TO_LENGTH[wildcards.sample1],
		len_h2 = lambda wildcards: SAMPLE_TO_LENGTH[wildcards.sample2],
		chrom_h1 = lambda wildcards: SAMPLE_TO_CONTIGNAME[wildcards.sample1],
		chrom_h2 = lambda wildcards: SAMPLE_TO_CONTIGNAME[wildcards.sample2],
	shell:
		"""
		python3 {SCRIPTS}/generate_syncmer_paf.py -syncmersH1 {input.hap1} -syncmersH2 {input.hap2} -lenH1 {params.len_h1} -lenH2 {params.len_h2} -chromosomeH1 {params.chrom_h1} -chromosomeH2 {params.chrom_h2} -outfile {output.tmp1} &> {log.forward}
		python3 {SCRIPTS}/generate_syncmer_paf.py -syncmersH1 {input.hap1} -syncmersH2 {input.hap2} -lenH1 {params.len_h1} -lenH2 {params.len_h2} -chromosomeH1 {params.chrom_h1} -chromosomeH2 {params.chrom_h2} --reverse -outfile {output.tmp2} &> {log.reversed}
		cat {output.tmp1} {output.tmp2} > {output.paf}
		"""
