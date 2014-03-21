#####################################################################################################
# Environmental variables
#####################################################################################################
PS1="[\u \W]\\$ "
# LANG=C
# LANG=ja_JP.UTF-8
LANG=ja_JP.SJIS
LC_CTYPE="$LANG"
LC_NUMERIC="$LANG"
LC_TIME="C"
LC_COLLATE="$LANG"
LC_MONETARY="$LANG"
LC_MESSAGES="C"
LC_ALL=
PAGER='less -MQXcgi -x4'
LESSCHARSET=dos
EDITOR='vim'
TZ=JST-9
HISTSIZE=10000
HISTFILESIZE=10000
HISTCONTROL=
HISTIGNORE=ls
HISTTIMEFORMAT='%Y/%m/%d-%H:%M:%S '
IGNOREEOF=3
TMP=/var/tmp
tmp=$TMP
TEMP=$TMP
temp=$TMP
SCREENDIR=${TMP}/screen
export DISPLAY=:0.0           # cygwin XWin Server
# export DISPLAY=localhost:11.0 # ssh X11Forwarding
export PS1 LANG PAGER LESSCHARSET EDITOR TZ IGNOREEOF TMP tmp TEMP temp SCREENDIR
export HISTSIZE HISTFILESIZE HISTCONTROL HISTIGNORE HISTTIMEFORMAT
export LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES LC_ALL
#####################################################################################################
stty stop undef
#####################################################################################################
# Alias
#####################################################################################################
alias ls='ls -F'
alias la='ls -A'
alias ll='ls -l'
alias lsdir='find . -maxdepth 1 -type d -not -name . -printf "%f\n" | column -c 80'
alias lsdot='ls -A | grep ^\\. | column -c 80'
alias ..='cd ..'
alias ...='cd ../..'
alias mv='mv -i'
alias cp='cp -i'
alias rm='rm -i'
alias grep='grep --colour=auto'
alias egrep='egrep --colour=auto'
alias info='info --vi-keys'
alias free='free -m'
alias less='less -MQSXcgi -x4'
alias bc='bc -q'
alias psa='ps --headers --sort=pid -e -o %cpu,%mem,rss,ppid,pgrp,pid,user,args'
alias psp='ps --headers --sort=pid -e -o user,args'
alias psm='ps --headers --sort=pid -a -o %cpu,%mem,rss,ppid,pgrp,pid,user,args'
alias vi='vim'
alias vimemo='vi ~/work/memo.txt'
alias xml='xmlstarlet'
alias start='cygstart'
#####################################################################################################
alias cdtop="cd $(cygpath -D)"
alias cdpro='cd /cygdrive/c/Program\ Files'
alias cdos='cd /srv/os'
alias cdapp='cd /srv/app'
alias cdwork='cd /srv/work'
alias cdpatch='cd /srv/patch'
alias cdbin='cd /srv/bin'
#####################################################################################################
# Function
#####################################################################################################
function httpserver() {
    python -m SimpleHTTPServer
#     http://192.168.0.20:8000
}
function lt() {
    ls -lt $1 | head -n 20
}
function vip() {
    vi -p $(find $@ -type f)
}
function vio() {
    vi -o $@
}
function 7za() {
    for f in $@;do
        7z a -r $(cygpath -am ${f}).zip $f > /dev/null
    done &
}
function 7zx() {
    for f in $@;do
        7z x $(cygpath -am $f) > /dev/null
    done &
}
function xmlformat() {
    tmp=$(mktemp)
    xml fo --encode utf-8 $1 > $tmp
    /bin/mv -f $tmp $1
}
function xmldelcomment() {
    xml ed -d '//comment()' $1
}
function mt() {
(
    mount=false
    unmount=false
    while getopts au OPT
    do
        case $OPT in
            a)
                unmount=true
                mount=true
                ;;
            u)
                unmount=true
                ;;
        esac
    done
    shift $((OPTIND - 1))

    if [ $unmount = 'false' -a $mount = 'false' ];then
        echo "USAGE: ${FUNCNAME[0]} [-a|-u]"
        mount |
        egrep ' on /srv/[a-z]+ ' |
        awk -F ' on ' '{ split($2, arr, "[[:space:]]"); printf("%s\t%s\n", arr[1], $1); }' |
        column -t -s '	'
    else
        if [ $unmount = 'true' ];then
            mount |
            egrep ' on /srv/[a-z]+ ' |
            egrep -o '/srv/[a-z]+' |
            awk '{ system("umount " $1) }'
        fi
        if [ $mount = 'true' ];then
            cat /srv/mount |
            awk -F '\t' '{ c = sprintf("eval mount \"%s\" %s", $1, $2); system(c); }'
        fi
    fi
)
}
function rp() {
(
    type=unix
    while getopts hmuw OPT
    do
        case $OPT in
            h)
                echo "USAGE: ${FUNCNAME[0]} [-m|-u|-w]"
                return
                ;;
            m)
                type=mixed
                ;;
            u)
                type=unix
                ;;
            w)
                type=windows
                ;;
        esac
    done
    shift $((OPTIND - 1))

    file=$1
    if [ -z "$file" ];then
        file=.
    fi

    cygpath --absolute --type $type $file | tr -d '[\n]' | putclip
    echo $(getclip)
)
}
patch_tmp=/tmp/patch_tmp
function cpsrc() {
    mkdir -p ${patch_tmp}/src{,_old}
    for f in $@;do
        r=$(cygpath -a -u $f)
        tar -c $r | tar -x --strip-components=2 -C ${patch_tmp}/src_old
        tar -c $r | tar -x --strip-components=2 -C ${patch_tmp}/src
    done
}
function mgsrc() {
    (cd ${patch_tmp}/src_old; tar -c *) | (cd src_old; tar -x)
    (cd ${patch_tmp}/src; tar -c *) | (cd src; tar -x)
}
function mkpatch() {
    for i in $(seq -w 1 100);do
        if [ ! -e ${i}.patch ];then
            diff -Nurp src_old src > ${i}.patch
            break
        fi
    done
}
function pt() {
(
    dry_run=false
    patch_opt=
    patch_type=
    patch_dir=.
    while getopts adnopr OPT
    do
        case $OPT in
            a)
                patch_dir=/srv/app
                ;;
            d)
                dry_run=true
                ;;
            n)
                patch_opt=' --binary -Np1 -i '
                patch_type=FORWARD
                ;;
            o)
                patch_dir=/srv/os
                ;;
            r)
                patch_opt=' --binary -Rp1 -i '
                patch_type=REVERSE
                ;;
        esac
    done
    shift $((OPTIND - 1))

    patch_file=$1

    if [ -z "$patch_opt" -o ! -f "$patch_file" ];then
cat << EOF
USAGE: ${FUNCNAME[0]} [-d] [-n|-r] [-a|-o] PATCH_FILE
       -d : dry-run
       -n : forward patch
       -r : reverse patch
       -a : apply patch to /srv/app
       -o : apply patch to /srv/os
EOF
        return
    fi

    patch_file=$(cygpath -au $patch_file)
    patch_tmp=$(mktemp)

    patch --dry-run --directory=$patch_dir $patch_opt $patch_file > $patch_tmp 2>&1
    patch_stat=$?

    if [ $patch_stat -eq 0 ];then
        if [ "$dry_run" = "true" ];then
            cat $patch_tmp
            echo -e "\nDRY-RUN SUCCESS $patch_type"
        else
            patch --directory=$patch_dir $patch_opt $patch_file
            echo -e "\nSUCCESS $patch_type"
        fi
    else
        cat $patch_tmp
        echo -e "\npatch --directory=$patch_dir $patch_opt $patch_file"
        echo -e "\nFAIL    $patch_type"
    fi

    /bin/rm $patch_tmp
)
}
function mklink() {
(
    link_from=
    link_to=
    while getopts cao OPT
    do
        case $OPT in
            a)
                link_to=/cygdrive/c/Temp/app
                ;;
            o)
                link_to=/cygdrive/c/Temp/os
                ;;
            c)
                (
                echo -n "/srv/os ";  cygpath -am $(ls -l /cygdrive/c/Temp/os/$(basename $(mt | grep ^/srv/os | awk '{ print $2 }')) | awk '{ print $NF}');
                echo -n "/srv/app "; cygpath -am $(ls -l /cygdrive/c/Temp/app/$(basename $(mt | grep ^/srv/app | awk '{ print $2 }')) | awk '{ print $NF}');
                ) | column -t
                return
                ;;
        esac
    done
    shift $((OPTIND - 1))

    link_from=$1
    if [ ! -d "$link_from" -o ! -d "$link_to" ];then
cat << EOF
USAGE: ${FUNCNAME[0]} [-a|-o] DIRECTORY
       ${FUNCNAME[0]} -c
EOF
        return
    fi

    link_base=$(basename $link_from)
    link_abs=$(cygpath -aw $link_from)

    cd $link_to
    /bin/rm $link_base
    cmd /c "mklink /d $link_base $link_abs" > /dev/null
    ls -l $(cygpath -au $link_base) | awk '{ printf("%s %s %s\n", $(NF - 2), $(NF - 1), $NF) }'
)
}
function mkctags() {
#     ctags --list-languages
    if [ -z "$1" -o -z "$2" ];then
        echo "USAGE: ${FUNCNAME[0]} TAG_FILE DIRECTORY"
        return
    fi
    ctags -R --languages=C,C++ -f $1 $2
}
function outline() {
#     ctags --list-kinds
    ctags -x --C++-kinds=fp $@ | awk '{ print $1 }'
}
function grepsrc() {
    cmd="grep -rn --include='*.c' --include='*.cpp' --include='*.h'"
    echo $cmd | tr -d '[\n]' | putclip
    echo $(getclip)
}
function chownme() {
    find $@ -printf 'BEFORE %m %u:%g %y %p\n'
    chown -R 1000:513 $@
    find $@ -type f -not -iname '*.exe' -not -iname '*.dll' -exec chmod 644 '{}' \;
    find $@ '(' -type d -o '(' -type f '(' -iname '*.exe' -o -iname '*.dll' ')' ')' ')' -exec chmod 755 '{}' \;
    find $@ -printf 'AFTER  %m %u:%g %y %p\n'
}
function pscopy() {
    from=$1
    to=$2
    if [ ! -d "$from" -o -z "$to" ];then
        echo "USAGE: ${FUNCNAME[0]} FROM_DIR TO_DIR"
        return
    fi
    from=$(cygpath -am $from)
    to=$(cygpath -am $to)
    powershell -command "copy-item -force -recurse -path $from -destination $to; write-output pscopy-finished"
}
