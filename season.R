#!/usr/bin/env Rscript

datatableize <- function(df)
{
  DT::datatable(
    df,
    style = "bootstrap",
    class = "table-bordered table-striped table-hover responsive",
    filter = list(position = "top"),
    rownames = F
  )
}

overall.2 <- function(df.point, df.penalty)
{
  schema <- data.frame(
    player = character(), 
    P = integer(), G = integer(), A = integer(), 
    EVG = integer(), EVA = integer(), EVA1 = integer(), EVA2 = integer(), 
    PPG = integer(), PPA = integer(), PPA1 = integer(), PPA2 = integer(), 
    SHG = integer(), SHA = integer(), SHA1 = integer(), SHA2 = integer(), 
    PEN = integer(), PIM = integer(),
    stringsAsFactors = F
  )
  bind_rows(
    rename(mutate(count(filter(df.point, EV == 1), shooter), type = "EVG"), player = shooter),
    rename(mutate(count(filter(df.point, EV == 1), assist1), type = "EVA1"), player = assist1),
    rename(mutate(count(filter(df.point, EV == 1), assist2), type = "EVA2"), player = assist2),
    rename(mutate(count(filter(df.point, PP == 1), shooter), type = "PPG"), player = shooter),
    rename(mutate(count(filter(df.point, PP == 1), assist1), type = "PPA1"), player = assist1),
    rename(mutate(count(filter(df.point, PP == 1), assist2), type = "PPA2"), player = assist2),
    rename(mutate(count(filter(df.point, SH == 1), shooter), type = "SHG"), player = shooter),
    rename(mutate(count(filter(df.point, SH == 1), assist1), type = "SHA1"), player = assist1),
    rename(mutate(count(filter(df.point, SH == 1), assist2), type = "SHA2"), player = assist2),
    mutate(summarise(group_by(df.penalty, player), n = length(duration)), type = "PEN"),
    mutate(summarise(group_by(df.penalty, player), n = sum(duration)), type = "PIM")
  ) %>% 
  spread(type, n) %>% 
  bind_rows(schema) %>%
  filter(!is.na(player)) %>%
  replace(is.na(.), 0) %>%
  mutate(
    P = EVG + EVA1 + EVA2 + PPG + PPA1 + PPA2 + SHG + SHA1 + SHA2,
    G = EVG + PPG + SHG,
    A = EVA1 + EVA2 + PPA1 + PPA2 + SHA1 + SHA2,
    EVA = EVA1 + EVA2, PPA = PPA1 + PPA2, SHA = SHA1 + SHA2
  ) %>%
  arrange(
    desc(P), 
    desc(EVG), desc(PPG), desc(SHG), 
    desc(EVA1), desc(PPA1), desc(SHA1), 
    desc(PPA2), desc(EVA2), desc(SHA2), 
    PEN, PIM
  ) %>%
  select(player, P, G, A, EVG, EVA, EVA1, EVA2, PPG, PPA, PPA1, PPA2, SHG, SHA, SHA1, SHA2, PEN, PIM)
}
