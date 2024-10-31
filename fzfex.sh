#!/bin/bash

mkdir /tmp/cpitems

create_file () {
    read -rp "Nhập tên tệp được phân tách bằng \"dấu gạch chéo\"(/) : " filenames

    IFS='/' read -ra file_array <<< "$filenames"

    for filename in "${file_array[@]}"; do
        touch "$filename"
    done
}
export -f create_file

create_dir () {
    selected_dir="$(pwd)"
    read -rp "Nhập tên thư mục: " new_dir_name
    mkdir -p "$selected_dir/$new_dir_name"
}
export -f create_dir

rename() {
    read -rp "Nhập tên để đổi tên: $1 -> " n
    mv -v  "$1" "$n"
}
export -f rename

fzfex () {
    while true; do
        selection="$(lsd -a -1 | fzf \
            --bind "left:pos(2)+accept" \
            --bind "right:accept" \
            --bind "shift-up:preview-up" \
            --bind "shift-down:preview-down" \
            --bind "ctrl-d:execute(create_dir)+reload(lsd -a -1)" \
            --bind "ctrl-f:execute(create_file)+reload(lsd -a -1)" \
            --bind "ctrl-r:execute(rename {})+reload(lsd -a -1)" \
            --bind "ctrl-t:execute(trash {+})+reload(lsd -a -1)" \
            --bind "ctrl-c:execute(cp -R {} /tmp/cpitems/$(basename {}).copy)" \
            --bind "ctrl-m:execute(mv -n {} /tmp/cpitems/$(basename {}).copy)+reload(lsd -a -1)" \
            --bind "ctrl-g:execute(mv -n /tmp/cpitems/* . && rm -rf /tmp/cpitems/*)+reload(lsd -a -1)" \
            --bind "esc:execute(rm /tmp/cpitems/*)+abort" \
            --bind "space:toggle" \
            --color=fg:#d8c3a5,fg+:#d8c3a5,bg+:#4b3832 \
            --color=hl:#e98074,hl+:#e85a4f,info:#edc4b3,marker:#ac6c5b \
            --color=pointer:#d9534f,spinner:#e2975d,prompt:#c47b57,header:#eac67a \
            --height 95% \
            --pointer  \
            --reverse \
            --multi \
            --info inline \
            --prompt "Search: " \
            --border "bold" \
            --border-label "$(pwd)/" \
            --preview-window=right:65% \
            --preview 'sel=$(echo {} | cut -d " " -f 2); cd_pre="$(echo $(pwd)/$(echo {}))";
                    echo "Folder: " $cd_pre;
                    lsd -a --icon=always --color=always "${cd_pre}";
                    cur_file="$(file $(echo $sel) | grep [Tt]ext | wc -l)";
                    if [[ "${cur_file}" -eq 1 ]]; then
                        bat --style=numbers --theme=ansi --color=always $sel 2>/dev/null
                    else
                        chafa -c full --color-space rgb --dither none -p on -w 9 2>/dev/null {}
                    fi')"
                    if [[ -d ${selection} ]]; then
                        >/dev/null cd "${selection}"
                    elif [[ -f "${selection}" ]]; then
                        file_type=$(file -b --mime-type "${selection}" | cut -d'/' -f1)
                        case $file_type in
                            "text")
                                nano "${selection}"
                                ;;
                            "image")
                                for fType in ${selection}
                                do 
                                    if [[ "${fType}" == *.xcf ]]; then
                                        gimp 2>/dev/null "${selection}"
                                    else
                                        sxiv "${selection}"
                                    fi
                                done
                                ;;
                            "video")
                                mpv -fs "${selection}" > /dev/null
                                ;;
                            "application")
                                for fType in ${selection}
                                do
                                    if [[ "${fType}" == *.docx ]] || [[ "${fType}" == *.odt ]]; then
                                        libreoffice "${selection}" > /dev/null
                                    elif [[ "${fType}" == *.pdf ]]; then
                                        zathura 2>/dev/null "${selection}"
                                    fi
                                done
                                ;;

                            "inode")
                                nano "${selection}"
                                ;;
                        esac
                    else
                        break
                    fi
        done
        }

clear
fzfex

