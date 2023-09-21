#!/bin/bash

# Change directory to the location of the script
cd "$(dirname "$0")"

# Set variables
url="https://www.imdb.com/chart/top"
previous_ranking="imdb_top250_previous.txt"
current_ranking="imdb_top250_current.txt"

# Get IMDb Top 250 page
curl -s -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36" $url > imdb_top250.html

# Extract all titles
grep -o '<h3 class="ipc-title__text">[^<]*' imdb_top250.html |  \
# Remove HTML tages
awk -F'>' '{print $2}' | \
# Maintain titles starting with a serial number
awk '/^[0-9]/' | \
# Remove serial numbers
sed 's/^[0-9]*\. //' > $current_ranking

# [TODO] Match all content from title to year
# grep -oE '<h3 class="ipc-title__text">.*?>[0-9]{4}<' imdb_top250.html > $current_ranking

# Sort the new file
sort $current_ranking -o $current_ranking

# Print the extracted movie names and release years
# echo "Extracted content:"
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
