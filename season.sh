#!/usr/bin/env bash

sqlite3 -separator " " stats.sdb "SELECT DISTINCT year, season FROM match;" | while read -r ele; do ./season.R stats.sdb $ele -out "${ele/ /-}.html"; done

exit
