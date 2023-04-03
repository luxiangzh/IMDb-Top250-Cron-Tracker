#!/bin/bash

# Set variables
url="https://www.imdb.com/chart/top"
previous_ranking="imdb_top250_previous.txt"
current_ranking="imdb_top250_current.txt"

# Get IMDb Top 250 page
curl -s $url > imdb_top250.html

# Extract movie names and release years
grep -zoP '<td class="titleColumn">.*?\n\s*\d+\.\n\s*<a[^>]*>([^<]+)<\/a>.*?\n\s*<span class="secondaryInfo">\(([0-9]{4})\)<\/span>.*?\n\s*<\/td>' imdb_top250.html | \
# Remove all HTML tags
sed -rz 's/<[^>]*>//g' | \
# Remove leading and trailing spaces, and delete the line containing the serial number
sed 's/^ *//;s/ *$//; /^[[:space:]]*[0-9]\+\.[[:space:]]*/d' | \
# Combine the movie title, release year, and blank line into one line
awk '!(NR%3){print prev, $0; next} {prev=$0}' > $current_ranking

# Sort the new file
sort $current_ranking -o $current_ranking

# Print the extracted movie names and release years
# echo "Extracted movie names and release years:"
# cat $current_ranking
# echo

# Check if the previous file exists; if it doesn't, rename the current file as the previous file and exit the program silently.
if [ ! -e $previous_ranking ]; then
    mv $current_ranking $previous_ranking
    exit 0;
fi

# Compare and output the movie names and release years that have entered or dropped out of the top 250
entered=$(comm -13 <(sort $previous_ranking) <(sort $current_ranking))
dropped=$(comm -23 <(sort $previous_ranking) <(sort $current_ranking))

if [ -n "$entered" ] || [ -n "$dropped" ]; then
    echo -n "Entered the top 250: "
    echo "$entered"

    echo -n "Dropped out of the top 250: "
    echo "$dropped"

    # Rename the new file as the old file for the next comparison
    mv $current_ranking $previous_ranking

    # Clean up temporary files
    rm imdb_top250.html

    # Exit the script with a non-zero status code (1) to indicate that there were changes in the top 250
    exit 1
fi


# Rename the new file as the old file for the next comparison
mv $current_ranking $previous_ranking

# Clean up temporary files
rm imdb_top250.html
