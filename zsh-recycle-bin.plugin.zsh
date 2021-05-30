trash_dir="~/.trash"

function delete {
    slient="false"
    while getopts "sRrdfIiPWxv" arg
    do
        case $arg in
            s)
            slient="true"
            ;;
            ?)
        ;;
        esac
    done
    shift $(( $OPTIND-1 ))
    tim=$(date +'%F.%T')
    token=$(echo "$tim" | md5sum | cut -c 1-6)
    eval tdir=$trash_dir;
    dir=$tdir/$tim/
    ! [ "$slient" = "true" ] && echo -e "remove ${fg[yellow]}$@${reset_color} to $trash_dir${reset_color} ..."
    ! [ -d $dir ] && mkdir $dir
    command mv $@ $dir &&
    echo -e "$(pwd)/" >> $dir/.trashinfo_$token
}

function recover {
    eval tdir=$trash_dir;
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

function trash {
    eval tdir=$trash_dir
    case $1 in
        "list")
            ls $tdir
            ;;
        "clear")
            echo -ne "clear all trashes that is not deleted today, are you sure? [y/n] "
            read ans
            if [ "$ans" = "y" ]; then
                cur=$(date +'%F')
                for dir in $(ls $tdir)
                do
                    if [ ${dir%%.*} != $cur ]; then
                        echo "delete $dir"
                        command rm -r $tdir/$dir
                    fi
                done
                echo "cleared."
            else
                echo "terminated."
            fi
            ;;
        *)
            echo "$0 [list/clear]"
            ;;
    esac
}

alias del="delete"
alias rec="recover"
