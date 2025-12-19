#!/usr/bin/env bash

TIME=""
COMMANDS=()

while [[ $# -gt 0 ]]; do
  case $1 in
  -h | --help)
    vcgencmd -h
    exit 0
    ;;
  -t)
    TIME="-t"
    shift
    ;;
  *)
    COMMANDS+=("$1")
    shift
    ;;
  esac
done

parse_get_throttled() {
  declare -A bit_meanings=(
    [0]="Undervoltage detected"
    [1]="ARM frequency capped"
    [2]="Currently throttled"
    [3]="Soft temperature limit active"
    [16]="Undervoltage has occurred"
    [17]="ARM frequency capping has occurred"
    [18]="Throttling has occurred"
    [19]="Soft temperature limit has occurred"
  )

  hex="${1#*=}"
  val=$((hex))

  if ((val == 0)); then
    echo "No bits set"
  fi

  for ((i = 0; i < 32; i++)); do
    if (((val >> i) & 1)); then
      meaning="${bit_meanings[$i]}"
      if [[ -z $meaning ]]; then
        meaning="Unknown"
      fi
      echo "Bit $i ($meaning) is set"
    fi
  done
}

declare -A cmd_map
cmd_map[get_throttled]=parse_get_throttled

if [ ${#COMMANDS[@]} -eq 0 ]; then
  vcgencmd
  exit 0
fi

for cmd in "${COMMANDS[@]}"; do
  echo "### Running command '$cmd'"
  output=$(vcgencmd $TIME "$cmd")
  handler="${cmd_map[$cmd]}"
  if [[ -n $handler ]]; then
    "$handler" "$output"
  else
    echo "### No parser for command '$cmd', raw output:"
    echo "$output"
  fi
  echo ""
done
