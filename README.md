# IMDb-Top250-Cron-Tracker

This is a Bash script that extracts the current list of top-rated movies from the IMDb Top 250 page, compares it to the previous list, and outputs the movies that have entered or dropped out of the top 250.

## Installation

1. Clone or download the script from GitHub.

2. Make sure you have the following dependencies installed:
- `curl`
- `sed`
- `grep`
- `awk`
- `sort`
- `comm`
  
3. Make the script executable by running:
   ```bash
   chmod +x imdb_top250.sh
   ```
   
4. Add the script to a scheduled task and set it to send an email in case of abnormal termination.
