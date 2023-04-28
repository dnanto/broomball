#!/usr/bin/env Rscript

library(tidyverse)
library(openxlsx)

process_book <- function(path) {
  print(path)
  tables <- (
    getSheetNames(path) %>%
      .[str_detect(., "\\d-\\d")] %>%
      # read each week-game sheet
      lapply(function(sheet) {
        tokens <- as.integer(str_split_fixed(sheet, "-", 2))
        read.xlsx(path, sheet, colNames = F) %>%
          mutate(sheet = sheet, week = tokens[1], game = tokens[2]) %>%
          select(sheet, week, game, everything())
      }) %>%
      bind_rows() %>%
      # split by table type, the first column
      split(.$X1) %>%
      lapply(function(df) {
        # remove extra columns, those that are all NA's
        n <- first(which(is.na(df[1, ])))
        n <- ifelse(is.na(n), ncol(df), n - 1)
        df <- df[, 1:n]
        # for each week-game sheet
        bind_rows(lapply(split(df, df$sheet), function(df) {
          # use the first row as the header and then remove it
          fields <- c("sheet", "week", "game", df[1, 4:ncol(df)])
          setNames(df[-1, ], fields)
        }))
      })
  )

  team <- read.xlsx(path, "team")
  # map team color to name
  color_to_team <- setNames(team$team, team$color)

  # extract year and season from the basename
  tokens <- str_split_fixed(str_remove(basename(path), ".xlsx"), "[-\\.]", 2)

  tables$match <- (
    mutate(
      tables$match,
      home = recode(home, !!!color_to_team),
      away = recode(away, !!!color_to_team),
      year = as.integer(tokens[1]),
      season = as.numeric(tokens[2])
    ) %>%
      rename(team1 = home, team2 = away)
  )
  tables$point <- (
    mutate(
      tables$point,
      team = recode(color, !!!color_to_team),
      year = as.integer(tokens[1]),
      season = as.numeric(tokens[2]),
      across(c("period", "EV", "PP", "SH", "EN"), as.integer)
    )
  )

  if ("penalty" %in% names(tables)) {
    tables$penalty <- (
      mutate(
        tables$penalty,
        team = recode(color, !!!color_to_team),
        year = as.integer(tokens[1]),
        season = as.numeric(tokens[2]),
        across(c("period", "duration"), function(ele) suppressWarnings(as.integer(ele))),
        across("scored", as.logical)
      )
    )
  }
  if ("shot" %in% names(tables)) {
    tables$shot <- (
      with(tables, shot[map_lgl(shot, ~ !all(is.na(.)))]) %>%
        mutate(team = recode(color, !!!color_to_team)) %>%
        pivot_longer(cols = matches("[0-9]+"), names_to = "period", values_to = "SH") %>%
        arrange(sheet) %>%
        mutate(
          year = as.integer(tokens[1]),
          season = as.numeric(tokens[2]),
          across(c("period", "SH"), as.integer)
        ) %>%
        drop_na(SH)
    )
  }
  tables$team <- rename(team, id = team)
  tables$roster <- (
    read.xlsx(path, "roster") %>%
      pivot_longer(cols = everything(), names_to = "color", values_to = "player") %>%
      filter(complete.cases(.)) %>%
      mutate(team = recode(color, !!!color_to_team))
  )
  tables$player <- select(tables$roster, player) %>% rename(id = player)

  tables
}

tables <- (
  list.files("data/xlsx", full.names = T) %>%
    enframe(name = NULL, value = "path") %>%
    arrange(path) %>%
    mutate(name = basename(path)) %>%
    filter(str_detect(name, "^\\d+-[\\d\\.]+.xlsx$")) %>%
    separate("name", c("year", "season"), extra = "drop") %>%
    apply(1, function(row) process_book(row["path"]))
)

df.player.1 <- read_tsv("data/tsv/player.tsv", col_types = "c")
df.player.2 <- bind_rows(lapply(tables, function(df) df[["player"]]))
df.player <- (
  bind_rows(df.player.1, df.player.2) %>%
    distinct() %>%
    arrange()
)

df.team.1 <- read_tsv("data/tsv/team.tsv", col_types = "ccc")
df.team.2 <- (
  lapply(tables, function(df) df[["team"]]) %>%
    bind_rows() %>%
    arrange()
)
df.team <- bind_rows(df.team.1, df.team.2)

df.roster.1 <- read_tsv("data/tsv/roster.tsv", col_types = "cc")
df.roster.2 <- bind_rows(lapply(tables, function(df) df[["roster"]]))
df.roster <- bind_rows(df.roster.1, df.roster.2) %>% select(-color)

df.match.1 <- read_tsv("data/tsv/match.tsv", col_types = "icciiiicct")
df.match.2 <- (
  lapply(tables, function(df) df[["match"]]) %>%
    bind_rows()
)
df.match <- (
  bind_rows(df.match.1, df.match.2) %>%
    mutate(id = seq_along(id)) %>%
    select(id, team1, team2, year, season, week, game, rink, date, time)
)

df.shot.1 <- read_tsv("data/tsv/shot.tsv", col_types = "iiccii")
df.shot.2 <- (
  lapply(tables, function(df) df[["shot"]]) %>%
    bind_rows() %>%
    left_join(df.match, by = c("year", "season", "week", "game")) %>%
    rename(match = id)
)
df.shot <- (
  bind_rows(df.shot.1, df.shot.2) %>%
    mutate(id = 1:nrow(.)) %>%
    select(id, match, team, goalie, period, SH)
)

df.point.1 <- read_tsv("data/tsv/point.tsv", col_types = "iiciccccciiii")
df.point.2 <- (
  lapply(tables, function(df) df[["point"]]) %>%
    bind_rows() %>%
    left_join(df.match, by = c("year", "season", "week", "game")) %>%
    rename(match = id, time = time.x)
)
df.point <- (
  bind_rows(df.point.1, df.point.2) %>%
    mutate(id = 1:nrow(.)) %>%
    select(id, match, team, period, time, shooter, assist1, assist2, goalie, EV, PP, SH, EN)
)

df.penalty.1 <- read_tsv("data/tsv/penalty.tsv", col_types = "iiciccccicl")
df.penalty.2 <- (
  lapply(tables, function(df) df[["penalty"]]) %>%
    bind_rows() %>%
    left_join(df.match, by = c("year", "season", "week", "game")) %>%
    rename(match = id, time = time.x)
)
df.penalty <- (
  bind_rows(df.penalty.1, df.penalty.2) %>%
    mutate(id = 1:nrow(.)) %>%
    select(id, match, team, period, time, player, server, call, duration, goalie, scored)
)

df.lstat <- read_tsv("data/tsv/lstat.tsv", col_types = "icciiiiiiiiiiiiiiii")

conn <- DBI::dbConnect(RSQLite::SQLite(), "stats.sdb")
DBI::dbAppendTable(conn, "player", df.player)
DBI::dbAppendTable(conn, "team", df.team)
DBI::dbAppendTable(conn, "roster", df.roster)
DBI::dbAppendTable(conn, "match", df.match)
DBI::dbAppendTable(conn, "shot", df.shot)
DBI::dbAppendTable(conn, "point", df.point)
DBI::dbAppendTable(conn, "penalty", df.penalty)
DBI::dbAppendTable(conn, "lstat", df.lstat)
DBI::dbDisconnect(conn)
