#!/usr/bin/env bash

./build.R

sqlite3 stats.db "PRAGMA foreign_keys = ON; PRAGMA integrity_check; PRAGMA foreign_key_check;"
