# biostat
A set of scripts to help with [biostat](https://www.biostars.org/p/43677/).

You have to download/clone it to your home dir, fix the `$GENOME_PATH` and `$SAMPLES_DIR` and good luck!

## How to use

Clone this repo where you samples are.
```bash
git clone https://git@github.com:rodrigoSyscop/biostat.git
```

Get `$GENOME_PATH` and `$SAMPLES_DIR` properly set.
Then you can choose run choosing one of below options:

```bash
# run it straight
bash ./biostat/biostat.sh

# add executable permission to it
chmod ug+x ./biostat/biostat.sh

# then run it as before, but without bash in front of command
./biostat/biostat.sh

# create an alias
alias biostat='bash ~/biostat/biostat.sh'

# then just run
biostat
```
