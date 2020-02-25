#!/bin/bash
config=$1

function is_yes {
  lower=$(echo $1 | tr '[:upper:]' '[:lower:]')
  [[ $lower == y* ]]
  return $?
}

function is_no {
  lower=$(echo $1 | tr '[:upper:]' '[:lower:]')
  [[ $lower == n* ]]
  return $?
}

