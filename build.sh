#!/usr/bin/env bash

rm -rf stats.sdb
sqlite3 < stats.sql
./build.R
sqlite3 stats.sdb "PRAGMA foreign_keys = ON; PRAGMA integrity_check; PRAGMA foreign_key_check;"
