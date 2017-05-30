#!/bin/bash

# settings
BIN_DIR="$HOME/.bin/biostat"
BASE_DIR="$HOME/biostat"
INPUT_DIR="$BASE_DIR/input"
OUTPUT_DIR="$BASE_DIR/output"

# do not change anything below
# get current directory
CUR_DIR=$(pwd)

# create binary dir
echo -en "Creating '$BIN_DIR' directory ..."
mkdir -p $BIN_DIR
echo -en " [ DONE ]\n"

echo -en "Creating '$INPUT_DIR' directory ..."
mkdir -p $INPUT_DIR
echo -en " [ DONE ]\n"

echo -en "Creating '$OUTPUT_DIR' directory ..."
mkdir -p $OUTPUT_DIR
echo -en " [ DONE ]\n"


# copying binary files
for bin in $(ls $CUR_DIR/bin);do
    echo -en "Installing $bin binary ..."
    cp -f $CUR_DIR/bin/$bin $BIN_DIR    
    echo -en " [ DONE ]\n"
done
chmod -R 750 $BIN_DIR

# put biostat binaries on PATH
echo -en ""
grep -q 'export PATH=$PATH:$HOME/.bin/biostat' $HOME/.bash_profile
if [ $? -ne 0 ];then
    echo -en "\n\n# BIOSTAT\n" >> $HOME/.bash_profile
    echo -en "Adding $BIN_DIR into your \$PATH ..."
    echo 'export PATH=$PATH:$HOME/.bin/biostat' >> $HOME/.bash_profile
    echo -en " [ DONE ]\n"
fi

# create .biostatrc
echo "BASE_DIR=\"$BASE_DIR\"" > $HOME/.biostatrc
echo "INPUT_DIR=\"$INPUT_DIR\"" >> $HOME/.biostatrc
echo "OUTPUT_DIR=\"$OUTPUT_DIR\"" >> $HOME/.biostatrc

echo -e "\n===== ALL SET ====="
echo ""
echo "You may want to run: source $HOME/.bash_profile"
echo ""
echo "Put your input files on $INPUT_DIR"
echo "cd into it: cd $INPUT_DIR"
echo -e "\nNow you are able to run:"
echo -e "\tbiostat"
echo -e "\tbiostat_merge_idxstats"
echo -e "\tbiostat_merge_flags"
