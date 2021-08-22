#!/bin/bash
main() {
    check_extensions=$(check_extensions $extensions)
    if [ $? -ne 0 ]
    then 
        echo $check_extensions
    return 1
    fi
    find_command=$(make_find_command $directory "$extensions")
    grep_pipelines=$(make_ignore_grep "$ignores")
    command="${find_command}${grep_pipelines} |while read line; do cat \"\${line}\" ; done |   wc -l"
    confirm_command="${find_command}${grep_pipelines} |while read line; do echo \"\${line}\" ; done > check_files.txt"
    eval $command
    eval $confirm_command
}

make_ignore_grep() {
    ignores=$1
    grep_pipelines=""
    if [ "$ignores" != "" ];
    then
        for ignore in $ignores; do
            grep_pipelines+="| grep -v \"$ignore\""
        done
    fi
    echo $grep_pipelines
}

make_find_command() {
    directory=$1
    extensions=$2
    under_all_directory="./**/*"
    if [ "$directory" != "" ]
    then
        if [[ "$directory" =~ "/$" ]]
        then
            under_all_directory=$directory**/*
        else
            under_all_directory=$directory/**/*
        fi
    fi
    find_command="find $under_all_directory $(make_find_argvs "$extensions")"
    echo $find_command
}

make_find_argvs() {
    extensions=$1
    find_argvs=""
    for extension in $extensions; do
        find_argvs+=" -name \*${extension} -or"
    done
    find_argvs=$(delete_tail_str "$find_argvs" "-or")
    echo $find_argvs
}

delete_tail_str() {
    origin=$1
    str=$2
    echo $(echo $origin | sed -e "s/$str$/ /g")
}

check_extensions(){
    extensions=$1
    if [ "$extensions" = "" ];
    then
        echo error\) set extensions use -e option!
        return 1 
    fi
    return 0
}

while getopts :i:e:d: OPT; do
    case $OPT in
    i) ignores="$OPTARG" ;;
    e) extensions="$OPTARG" ;;
    d) directory="$OPTARG" ;;
    *) echo "this option is not exist." ;;
    esac
done

main
