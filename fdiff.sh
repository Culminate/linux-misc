#!/bin/bash

argc=$#  # количество аргументов
argv=$@  # список всех аргументов
workdir=$(git worktree list 2>/dev/null | grep -o "/[a-zA-Z0-9/-]*")
nameworkdir=$(echo $workdir | sed -r 's/.*(\/)(.*)/\2/')
workbranch=$(git branch 2> /dev/null | sed -r -e '/^[^*]/d' -e 's/\* (\(HEAD detached at )?([a-zA-Z0-9_.\-]*)(\)?)/\2/')
# git log Inzer_10_4_test..Inzer_24_12_test --author='vgrigoriev' --name-only --pretty=format: | grep -ve "^$" | sort | uniq
# git diff $commit1 --name-only -- $PWD 2>/dev/null

clean() {
rm -r $1 $2
}

fdiff() {
    if [[ -n "$2" ]]; then
        tobranch=$2                                      # 2 ветка для сравнения
    else
        tobranch=$workbranch
    fi

    if [[ -n "$3" ]]; then
        nameauthor=$3
    fi

    frombranch=$1                                        # 1 ветка для сравнения
    execbranch="$frombranch..$tobranch"                  # строка для команды git log
    tobranch=$(echo $tobranch | sed 's/\//-/g')
    frombranch=$(echo $frombranch | sed 's/\//-/g')
    fromdir="$workdir/../.$nameworkdir-$frombranch/"     # папка 1 ветки для сравнения
    todir="$workdir/../.$nameworkdir-$tobranch/"         # папка 2 ветки для сравнения

    if [[ -n "$nameauthor" ]]; then
        execauthor="--author=$nameauthor"
    fi

    files=$(git log $execbranch $execauthor --name-only --pretty=format: -- $PWD | grep -ve "^$" | sort | uniq)

    if [ "$files" ]; then
        echo "Diff files found `echo $files | wc -w`"
        git checkout $frombranch &>/dev/null
        mkdir $fromdir || clean $fromdir
        cd $workdir
        cp $files $fromdir --parents 2>/dev/null
        cd - >/dev/null
        git checkout $tobranch &>/dev/null
        mkdir $todir || clean $todir
        cd $workdir
        cp $files $todir --parents 2>/dev/null
        cd - >/dev/null

        git checkout $workbranch &>/dev/null

        echo "Compare $frombranch $tobranch"
        meld $fromdir $todir 2>/dev/null
        clean $todir $fromdir && echo "Clean tmp files"
    else
        echo "Diff files not found"
    fi
}

main() {
    i=0
    while [ -n "$1" ]
    do
    case "$1" in
    -a)
        if [ -n "$2" ]; then
            nameauthor=$2
        fi;;
    *)
        commit+=([$i]=$1)
        i=$(( $i + 1 ))        # инкремент в баш стиле
        ;;
    esac
    shift
    done

    if [[ ${#commit[@]} > 0 ]]; then  # если аргументов веток в массиве больше 0 то выполняем команду сравнения
        fdiff ${commit[@]}            # передать функции весь список как аргументы
    fi
}

main $argv