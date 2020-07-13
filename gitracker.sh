#!/bin/bash

# Как пользоваться:
# Добавляем файл с путями (описанно ниже)
# Запуск скрипта без аргуметов даст нам список репозиториев с текущими и возможными ветками и тэгами
# Чтобы поменять ветку на определённом репозитории, то нужно ввести его алиас и номер/наименование ветки или тэга
# Чтобы поменять ветку на всех репозитоиях, то введите символ собаки (@) и наменование ветки
#
# Добавляем пути в файл git_paths.sh рядом со скриптом
# Пути и алиасы к ним, сначала пишется путь, потом алиас
# Отображаюбтся алиасы вместо путей
#
# Пример:
#
# paths=(
# ".           main"
# "server      server"
# "lib/channel channel"
# "lib/config  config"
# "lib/connect connect"
# "lib/mutex   mutex"
# "lib/packet  packet"
# "lib/route   route"
# "lib/trace   trace"
# )

NC="\e[0m"    # no color
YELLOW="\e[93m"
GREEN="\e[32m"
RED="\e[31m"
BLUE="\e[34m"

BOLD="\e[1m"

REGEX_NUMERIC="^[0-9]+$"

declare -A accpaths # ассоциативный массив

# Вывод ошибки
errcho() {
    echo -e "${RED}$@${NC}" 1>&2;
}

# Отображаем путь до скрипта, чтобы он работал из других директорий
cwd() {
    echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
}

# Выводим список веток
git_branches() {
    echo "$(git -C "$1" branch)"
}

# Изменяем ветку на репозитории
git_branch() {
    git -C "$1" checkout "$2"
}

# Выводим список тэгов
git_tags() {
    echo "$(git -C "$1" tag)"
}

# Смотрим есть ли тэг на текущем месте
git_tag() {
    curtag="$(git -C "$1" tag --points-at HEAD | tail -n1)" # get last tag
    if [[ -n "$curtag" ]]; then curtag=" $curtag"; fi
    echo "$curtag"
}

# Выводим либо название ветки, либо хэш
git_hash() {
    echo "$1" | sed -E "s/.* ([0-9a-z\.]+)\)|\* /\1/"
}

# Превращаем обычный массив в ассоциативный
associative() {
    for pair in "${paths[@]}"; do
        path=($pair)
        name=${path[1]}
        accpaths["$name"]="$path"
    done
}

print_br_chg_msg() {
    echo -e "${BLUE}Repo ${GREEN}$2${BLUE} in $1 change branch to ${YELLOW}$3${NC}"
}

# Смена ветки
# $1 путь к ветке
# $1 алиас к ветке
# $2 номер ветки или её название
change_branch() {
    path="$1"
    name="$2"
    num="$3"

    # Если у нас не цифра, то напрямую передаём аргумент в функцию
    if ! [[ "$num" =~ $REGEX_NUMERIC ]]; then
        print_br_chg_msg "$path" "$name" "$num"
        git_branch "$path" "$num"
        return 0
    fi

    branch=$(git_branches "$path")
    IFS=$'\n' read -rd '' -a allbranches <<< "$branch" # Конвертируем вывод гита в массив

    get_tags=$(git_tags "$path")
    IFS=$'\n' read -rd '' -a tags <<< "$get_tags"

    for b in "${allbranches[@]}"; do
        if [[ $b != \** ]]; then
            obranches+=($b)
        fi
    done

    num_br=${#obranches[@]}
    num_tg=${#tags[@]}
    num_all=$((num_br+num_tg))

    if (( "$num" >= "$num_all" )); then
        errcho "Second argument out of range"
        exit
    fi

    if (( "$num" < $num_br )); then
        desired=${obranches[$num]}
    else
        numtag=$(($num-num_br))
        desired=${tags[$numtag]}
    fi

    print_br_chg_msg "$path" "$name" "$desired"
    git_branch "$path" "$desired"
}

change_branches() {

    if [[ $1 =~ $REGEX_NUMERIC ]]; then
        errcho "Use symbolic name of branch for multiple change branch"
        exit
    fi

    for pair in "${paths[@]}"; do
        path=($pair)
        name=${path[1]}
        change_branch $path $name $1
    done
}

show_repo() {
    path="$1"
    name="$2"
    branch=$(git_branches "$path") # Запрос git branch
    IFS=$'\n' read -rd '' -a allbranches <<< "$branch" # Конвертируем вывод гита в массив

    get_tags=$(git_tags "$path")
    IFS=$'\n' read -rd '' -a tags <<< "$get_tags"

    obranches=()
    for b in "${allbranches[@]}"; do
        if [[ $b == \** ]]; then # Если текущая ветка
            tag=$(git_tag "$path") # Смотрим tag на HEAD
            strbr=$(git_hash "$b")
            if [[ " $strbr" == "$tag" ]]; then
                curbranch="$strbr"
            else
                curbranch="$strbr$tag"
            fi
        else
            obranches+=($b)
        fi

        # Отображаем полученные результаты
        if [[ $b == "${allbranches[-1]}" ]]; then
            printf "${GREEN}$name${NC}\t [${BOLD}${YELLOW}$curbranch${NC}]\t"

            for ob in "${!obranches[@]}"; do # Выводим ветки
                printf "$ob) ${obranches[ob]} "
            done

            for t in "${!tags[@]}"; do # Выводим тэги
                ob=$((ob+1))
                printf "$ob) ${tags[t]} "
            done
            echo
        fi
    done
}

# Показывает состояние всех веток
show_repos() {
    for pair in "${paths[@]}"; do
        path=($pair)    # Путь
        name=${path[1]} # Ассоциированное имя
        show_repo "$path" "$name"
    done
}

search_git() {
while [[ "$PWD" != "/" ]]; do
    if [[ -f ".gitracker" ]]; then
        source ".gitracker"
        break
    elif [[ -d ".git" ]]; then
        if [[ -f ".gitmodules" ]]; then
            repname=$(basename "$PWD")
            path="."
            paths+=("$path $repname")
            while read line; do
            search=$(echo "$line" | grep "submodule" | sed -E "s/\[submodule \"(.*)\"\]/\1/")
            if [[ -n $search ]]; then
                repname="$search"
                continue
            fi
            search=$(echo "$line" | grep "path" | sed -E "s/path = (.*)/\1/")
            if [[ -n $search ]]; then
                path="$search"
                paths+=("$path $repname")
            fi
            done < .gitmodules
        fi
        break
    fi
    cd ..
done
}

search_git

if [[ -n "$1" && -n "$2" ]]; then
    if [[ "$1" == @ ]]; then # Если собака то все репозитории меняют ветку
        change_branches "$2"
    else
        associative
        path="${accpaths["$1"]}"
        if [[ -z "$path" ]]; then errcho "Wrong alias for repo"; exit; fi

        change_branch "$path" "$1" "$2"
    fi
    echo
    show_repos
else
    show_repos
fi
