#!/bin/bash

# https://www.youtube.com/watch?v=JMJGwVyOerw
# Made By DrKel
# You thought it was safe? Nah.

initialize_variables() {
  echo "Initializing variables..." #dude i was uncreative okay
  sleep 1
}

perform_calculations() {
  echo "Performing calculations..." #idk
  sleep 1
}

process_data() {
  echo "Processing data..." #amogus
  sleep 1
}

countdown() {
  for i in {10..1}; do
    echo "Counting down: $i"
    sleep 1
  done
}

spam_lyrics() {
  while true; do
    echo "Never gonna give you up"
    sleep 0.083
    echo "Never gonna let you down"
    sleep 0.083
    echo "Never gonna run around and desert you"
    sleep 0.083
    echo "Never gonna make you cry"
    sleep 0.083
    echo "Never gonna say goodbye"
    sleep 0.083
    echo "Never gonna tell a lie and hurt you"
    sleep 0.083
  done
}

redirect_to_rickroll() {
  xdg-open "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
}

main() {
  initialize_variables
  perform_calculations
  process_data
  countdown
  spam_lyrics & # Runs in the background
  redirect_to_rickroll
}

main
