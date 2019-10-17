#!/usr/bin/env bash

boob_db=$1

_rofi () {
    rofi -dmenu -i -no-levenshtein-sort -width 1000 "$@"
}

_boob () {
    if [[ -z "${boob_db}" ]]; then
        boob "$@"
    else
        boob "$boob_db" "$@"
    fi
}

# keybindings
kb_switch_mode="Alt+Tab"
kb_databases="Alt+d"
# colors
help_color="#2d7ed8"

help_text="Use <span color='${help_color}'>${kb_switch_mode}</span> to switch mode. <span color='${help_color}'>${kb_databases}</span> to list databases"

main () {    
    showRofi
    processRofiInput
}

showRofi() {
    prompt_prefix=""
    if [[ ! -z "${boob_db}" ]]; then
        prompt_prefix="${boob_db} "
    fi
    
    case "$mode" in
        bookmarks)
            menu=$(_boob print | column -t -s $'\t' | _rofi -p "${prompt_prefix}${mode}" -filter "${filter}" -mesg "${help_text}" -kb-custom-1 "${kb_switch_mode}" -kb-custom-2 "${kb_databases}")
            ;;
        tags)
            menu=$(_boob print tags | _rofi -p "${prompt_prefix}${mode}" -mesg "${help_text}" -kb-custom-1 "${kb_switch_mode}" -kb-custom-2 "${kb_databases}")
            ;;
        databases)
            menu=$(_boob print databases | _rofi -p "${mode}" -mesg "${help_text}" -kb-custom-1 "${kb_switch_mode}" -kb-custom-2 "${kb_databases}")
            ;;
    esac
}

processRofiInput() {
    case $? in
        1)
            exit
            ;;
        10)
            switchMode
            ;;
        11)
            mode="databases" main
            ;;
        0)
            processRofiSelectEntry
            ;;
    esac
}

processRofiSelectEntry() {
    case "$mode" in
        bookmarks)
            id=$(getId "$content" "$menu")
            for bm in ${id}; do
                _boob browse "${bm}"
            done
            ;;
        tags)
            filter="${menu}" mode="bookmarks" main
            ;;
        databases)
            boob_db="${menu}"
            mode="bookmarks" main
            ;;
    esac   
}

switchMode() {
    case "$mode" in
        bookmarks)
            mode="tags" main
            ;;
        tags)
            mode="databases" main
            ;;
        databases)
            mode="bookmarks" main
            ;;
    esac
}

getId () {
  id=$(echo "${2%% *}")
  if [ -z "$id" ]; then
    prev=""
    IFS=$'\n'
    for line in $1; do
      if [ "$2" = "$line" ]; then
        id=$(echo "${prev%% *}")
        break
      else
        prev="$line"
      fi
    done
  fi
  echo $id
}

mode=bookmarks main
