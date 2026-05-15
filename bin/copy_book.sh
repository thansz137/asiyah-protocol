#!/usr/bin/env bash

set -e

# Get the directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Go to novel/ directory, which is a sibling of the bin/ where this script is
cd "${SCRIPT_DIR}/../novel" || { echo "Error: Could not cd to novel/"; exit 1; }


wait_for_continue() {
    while true; do
        read -n 1 -p "Ready to continue? (c = continue, x = exit): " key
        echo ""   # New line after input
        
        case "$key" in
            [cC])
                return 0 ;;      # Continue
            [xX])
                echo "Exiting script."
                exit 0 ;;
            *)
                echo "Invalid input. Please press 'c' or 'x'." ;;
        esac
    done
}

START_PROMPT="I would like you to evaluate the novel.
I would like to provide the contents on a chapter by chapter basis.
Please indicate if this is acceptable.
If it is, I will being by providing the first chapter."

{ echo "$START_PROMPT"; } | xclip -selection clipboard
wait_for_continue

CHAPTER_PROMPT="You will read this entire file, every word. 
No skipping, no skimming, no assumptions. 
Upon completion, you will do the following:
- output the section header and then a newline
- output the last sentence in the chapter and then a newline
- output 'I am ready for the next chapter.'

You will not output anything else. 
You may end this conversation at any time by saying \"I'm done\".

Here are the contents of the file:"

for file in $(printf '%s\n' [0-9]*.md | sort -V); do

    case "$file" in 
        00a_legal.md) continue ;;
    esac


    title=$(head -1 "$file")
    cleaned=$(sed '
        /\[<- Previous\]/d
        /\[Next ->\]/d
    ' "$file" | tac | sed '1,/^---$/d' | tac)
    { echo "$CHAPTER_PROMPT"; echo "";  echo "$cleaned"; }  | xclip -selection clipboard

    echo "Processed $file: $title"
    wait_for_continue
done
