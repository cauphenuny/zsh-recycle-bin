version="recycle-bin v1.1.0"
trash_dir="~/.trash"
eval tdir=$trash_dir;

function __trash_delete {
    slient="false"
    while getopts "sRrdfIiPWxv" arg; do
        case $arg in
            s)
                slient="true"
                ;;
            v)
                slient="false"
                ;;
            *)
                ;;
        esac
    done
    shift $(( $OPTIND-1 ))
    if [ $# -lt 1 ]; then echo -e "${fg[red]}no operand!${reset_color}" && return 1; fi
    tim=$(date +'%F.%T')
    token=$(echo "$tim" | md5sum | cut -c 1-6)
    ! [ -d $tdir ] && mkdir $tdir
    dir=$tdir/$tim/
    ! [ "$slient" = "true" ] && echo -e "remove ${fg[yellow]}$@${reset_color} to $trash_dir${reset_color} ..."
    ! [ -d $dir ] && mkdir $dir && command mv $@ $dir && \
    echo -e "$(pwd)/" >> $dir/.trashinfo_$token
}

function __trash_recover {
    ! [ -d $tdir ] && mkdir $tdir
    if [ $# -lt 1 ]; then
        if [ $(ls $tdir | wc -w) -lt 1 ]; then
            return 0
        fi
        date=$(ls -lt $tdir | grep - | head -n 1 | awk '{print $9}')
    else
        date=$1
    fi
    if ! [ -d $tdir/$date ]; then
        echo -e ${fg[red]}"no such directory!"${reset_color} && return 1
    fi
    date=${date%%/*} &&
    token=$(echo "$date" | md5sum | cut -c 1-6) &&
    dest=$(cat $tdir/$date/.trashinfo_${token}) &&
    ls $tdir/$date &&
    echo -ne "-----\nrecover these file(s) to ${fg[yellow]}'$dest'${reset_color}? [y/n] " &&
    read key
    if [ "$key" = "y" ]; then
        command mv $tdir/$date/* $dest/ &&
        command mv $tdir/$date/.[^.]* $dest/ &&
        command rmdir $tdir/$date/ &&
        command rm $dest/.trashinfo_${token} &&
        echo "${fg[green]}recovered.${reset_color}"
    else
        echo "${fg[red]}terminated.${reset_color}"
    fi
}

function __trash_content {
    if [ $# -lt 1 ]; then
        find $tdir -mindepth 1 | grep --color=never -v "\.trashinfo_"
    else
        for file in $*
        do
            [ -d $tdir/$file ] && find $tdir -mindepth 2 | grep --color=never -v "\.trashinfo_" | grep --color=never $file
        done
    fi
}

function __trash_list {
    ls $tdir
}

function __trash_clear {
    if [ $# -lt 1 ]; then
        echo -ne "clear all trashes that is not deleted today, are you sure? [y/n] "
        read ans
        if [ "$ans" = "y" ]; then
            cur=$(date +'%F')
            for dir in $(ls $tdir); do
                if [ ${dir%%.*} != $cur ]; then
                    command rm -rfv $tdir/$dir
                fi
            done
            echo "cleared."
        else
            echo "terminated."
        fi
    else
        echo -ne "remove ${fg[yellow]}$argv${reset_color}, are you sure? [y/n] "
        read ans
        if [ "$ans" = "y" ]; then
            for file in $argv; do
                if ! [ -d $tdir/$file ]; then
                    echo "no such file: ${fg[yellow]}$file${reset_color}\ntry \`trash list\` to find trashname."
                fi
                command rm -rfv $tdir/$file
            done
        else
            echo "terminated."
        fi
    fi
}

function __trash_version {
    echo "$version"
}

function __trash_help {
    cat <<EOF
usage: trash <command> [options]

available commands:
  trash -d / delete [filename]    # put file to recycle bin         
  trash -r / recover              # recover latest trash        
  trash -r / recover [trashname]  # recover [trashname]        
  trash list                 # display trashname in recycle bin
  trash clear                # real remove trash which is not created today
  trash clear [trashname]    # real remove trash [trashname]
  trash content              # display details of files in recyble bin
  trash content [trashname]  # display details of [trashname] 
  trash version              # display version

# also can use del as trash delete, rec as trash recover
EOF
}

function trash {
    [[ $# -gt 0 ]] || {
        __trash_help
        return 1
    }
    local command="$1"
    shift
    type __trash_$command &>/dev/null || {
        __trash_help
        return 1
    }
    __trash_$command "$@"
}

alias del="trash delete"
alias rec="trash recover"
