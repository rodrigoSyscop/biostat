# biostat
A set of scripts to help with [biostat](https://www.biostars.org/p/43677/) project.


## How to use

### Download
Clone this repo on your home directory:
```bash
git clone https://git@github.com:rodrigoSyscop/biostat.git biostat.app
```

### Install 
```bash
# run it straight
bash ./biostat.app/install.sh
```

### Using it

Put your files on `˜/biostat/input` directory and run the commands below:

```bash
# generate the .sam, .bam, and sorted files
biostat

# merge all *_sorted.txt files
biostat_merge_idxstats

# merge all *_sorted_flag.txt files
biostat_merge_flags
```

All output files will be placed on `~/biostat/output`.
