#!/usr/bin/env bash

MAX_LEN=9999
UNKNOWN_ARGS=0
SEP="-"
NUMS=3
MAX_WORDS=4
CHECK_PASSWORD=1

while [[ $# -gt 0 ]]; do
  case $1 in
  --max-len)
    MAX_LEN="$2"
    shift
    shift
    ;;
  --max-words)
    MAX_WORDS="$2"
    shift
    shift
    ;;
  --no-nums)
    NUMS=0
    shift
    ;;
  --nums)
    NUMS="$2"
    shift
    shift
    ;;
  --sep)
    SEP="$2"
    shift
    shift
    ;;
  --no-check)
    CHECK_PASSWORD=0
    shift
    ;;
  *)
    echo "Unknown argument $1"
    UNKNOWN_ARGS=1
    shift
    ;;
  esac
done

if [[ $UNKNOWN_ARGS == 1 ]]; then
  exit 1
fi

function password_word_len() {
  _count=0
  for _word in "${password_words[@]}"; do
    _count=$(($_count + ${#_word}))
  done
  _num_seps=$((${#password_words[@]} - 1))
  _count=$(($_count + $_num_seps))
  echo $_count
}

function has_capital() {
  for _word in "${password_words[@]}"; do
    if [[ $_word =~ [A-Z] ]]; then
      return 0
    fi
  done
  return 1

}

function generate_password() {
  words=$(gopass pwgen -x -xs " " -1 1)

  password_words=()

  for word in ${words}; do
    if [[ ${#password_words[@]} -ge $MAX_WORDS ]]; then
      break
    fi

    randnum=$(($RANDOM % 5))
    if [[ $randnum == 0 ]]; then
      # Capitalize some words
      word="${word^}"
    fi
    password_words+=("$word")
    cur_len=$(password_word_len)
    if [[ $cur_len -gt $(($MAX_LEN - $NUMS)) ]]; then
      unset password_words[-1]
    fi
  done

  if ! has_capital; then
    generate_password
    return
  fi
  password=$(
    IFS=$SEP
    echo "${password_words[*]}"
  )
  for ((i = 1; i <= $NUMS; i++)); do
    password+=$(($RANDOM % 10))
  done
  echo "$password"
}

final_pw=$(generate_password)

if [[ $CHECK_PASSWORD ]]; then
  echo "$final_pw" | wl-copy
  echo "Password has been copied to clipboard."
  while true; do
    read -p "Is the password acceptable? (y/n): " yn
    case $yn in
    [yY])
      break
      ;;
    [nN])
      echo "Exiting"
      exit 1
      ;;
    *)
      echo "Invalid response"
      ;;
    esac
  done
fi

while true; do
  read -p "Enter path to save this password to: " pw_path
  extra_args=""
  if [[ $(gopass ls -f | grep -x "$pw_path") ]]; then
    echo "Password already exists at $pw_path"
    while true; do
      read -p "Overwrite? (y/n): " yn
      case $yn in
      [yY])
        extra_args+=" -f"
        break 2
        ;;
      [nN])
        break
        ;;
      *)
        echo "Invalid response"
        ;;
      esac
    done
    continue
  fi
  break
done

ssh-agent bash -c "ssh-add ~/.ssh/id_ed25519 && echo '$final_pw' | gopass insert '$pw_path' $extra_args"
