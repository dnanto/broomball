PRAGMA foreign_keys = ON;

-- Schema: stats
--   stats
ATTACH "stats.sdb" AS "stats";
BEGIN;
CREATE TABLE "stats"."player"(
  "id" TEXT PRIMARY KEY NOT NULL
);
CREATE TABLE "stats"."team"(
  "id" TEXT PRIMARY KEY NOT NULL,
  "captain" TEXT,
  "co-captain" TEXT,
  "color" TEXT NOT NULL,
  CONSTRAINT "fk_team_player1"
    FOREIGN KEY("captain")
    REFERENCES "player"("id"),
  CONSTRAINT "fk_team_player2"
    FOREIGN KEY("co-captain")
    REFERENCES "player"("id")
);
CREATE INDEX "stats"."team.fk_team_player1_idx" ON "team" ("captain");
CREATE INDEX "stats"."team.fk_team_player2_idx" ON "team" ("co-captain");
CREATE TABLE "stats"."match"(
  "id" INTEGER PRIMARY KEY NOT NULL,
  "team1" TEXT NOT NULL,
  "team2" TEXT NOT NULL,
  "year" INTEGER NOT NULL,
  "season" REAL NOT NULL,
  "week" INTEGER NOT NULL,
  "game" INTEGER NOT NULL,
  "rink" TEXT,
  "date" TEXT,
  "time" TEXT,
  CONSTRAINT "fk_game_team1"
    FOREIGN KEY("team1")
    REFERENCES "team"("id"),
  CONSTRAINT "fk_game_team2"
    FOREIGN KEY("team2")
    REFERENCES "team"("id")
);
CREATE INDEX "stats"."match.fk_game_team1_idx" ON "match" ("team1");
CREATE INDEX "stats"."match.fk_game_team2_idx" ON "match" ("team2");
CREATE TABLE "stats"."shot"(
  "id" INTEGER PRIMARY KEY NOT NULL,
  "match" INTEGER NOT NULL,
  "team" TEXT NOT NULL,
  "goalie" TEXT,
  "period" INTEGER,
  "SH" INTEGER DEFAULT 0,
  CONSTRAINT "fk_shots_player1"
    FOREIGN KEY("goalie")
    REFERENCES "player"("id"),
  CONSTRAINT "fk_shots_game1"
    FOREIGN KEY("match")
    REFERENCES "match"("id"),
  CONSTRAINT "fk_shots_team1"
    FOREIGN KEY("team")
    REFERENCES "team"("id")
);
CREATE INDEX "stats"."shot.fk_shots_player1_idx" ON "shot" ("goalie");
CREATE INDEX "stats"."shot.fk_shots_game1_idx" ON "shot" ("match");
CREATE INDEX "stats"."shot.fk_shots_team1_idx" ON "shot" ("team");
CREATE TABLE "stats"."point"(
  "id" INTEGER PRIMARY KEY NOT NULL,
  "match" INTEGER NOT NULL,
  "team" TEXT NOT NULL,
  "period" INTEGER,
  "time" TEXT,
  "shooter" TEXT NOT NULL,
  "assist1" TEXT,
  "assist2" TEXT,
  "goalie" TEXT,
  "EV" INTEGER NOT NULL,
  "PP" INTEGER NOT NULL,
  "SH" INTEGER NOT NULL,
  "EN" INTEGER NOT NULL,
  CONSTRAINT "fk_scoring_game1"
    FOREIGN KEY("match")
    REFERENCES "match"("id"),
  CONSTRAINT "fk_scoring_team1"
    FOREIGN KEY("team")
    REFERENCES "team"("id"),
  CONSTRAINT "fk_scoring_player1"
    FOREIGN KEY("shooter")
    REFERENCES "player"("id"),
  CONSTRAINT "fk_scoring_player2"
    FOREIGN KEY("assist1")
    REFERENCES "player"("id"),
  CONSTRAINT "fk_scoring_player3"
    FOREIGN KEY("assist2")
    REFERENCES "player"("id"),
  CONSTRAINT "fk_scoring_player4"
    FOREIGN KEY("goalie")
    REFERENCES "player"("id")
);
CREATE INDEX "stats"."point.fk_scoring_game1_idx" ON "point" ("match");
CREATE INDEX "stats"."point.fk_scoring_team1_idx" ON "point" ("team");
CREATE INDEX "stats"."point.fk_scoring_player1_idx" ON "point" ("shooter");
CREATE INDEX "stats"."point.fk_scoring_player2_idx" ON "point" ("assist1");
CREATE INDEX "stats"."point.fk_scoring_player3_idx" ON "point" ("assist2");
CREATE INDEX "stats"."point.fk_scoring_player4_idx" ON "point" ("goalie");
CREATE TABLE "stats"."roster"(
  "team" TEXT NOT NULL,
  "player" TEXT NOT NULL,
  PRIMARY KEY("team","player"),
  CONSTRAINT "fk_team_has_player_team1"
    FOREIGN KEY("team")
    REFERENCES "team"("id"),
  CONSTRAINT "fk_team_has_player_player1"
    FOREIGN KEY("player")
    REFERENCES "player"("id")
);
CREATE INDEX "stats"."roster.fk_team_has_player_player1_idx" ON "roster" ("player");
CREATE INDEX "stats"."roster.fk_team_has_player_team1_idx" ON "roster" ("team");
CREATE TABLE "stats"."penalty"(
  "id" INTEGER PRIMARY KEY NOT NULL,
  "match" INTEGER NOT NULL,
  "team" TEXT NOT NULL,
  "period" INTEGER,
  "time" TEXT,
  "player" TEXT,
  "server" TEXT,
  "call" TEXT,
  "duration" INTEGER NOT NULL,
  "goalie" TEXT,
  "scored" INTEGER,
  CONSTRAINT "fk_penalty_game1"
    FOREIGN KEY("match")
    REFERENCES "match"("id"),
  CONSTRAINT "fk_penalty_team1"
    FOREIGN KEY("team")
    REFERENCES "team"("id"),
  CONSTRAINT "fk_penalty_player1"
    FOREIGN KEY("player")
    REFERENCES "player"("id"),
  CONSTRAINT "fk_penalty_player2"
    FOREIGN KEY("server")
    REFERENCES "player"("id"),
  CONSTRAINT "fk_penalty_player3"
    FOREIGN KEY("goalie")
    REFERENCES "player"("id")
);
CREATE INDEX "stats"."penalty.fk_penalty_game1_idx" ON "penalty" ("match");
CREATE INDEX "stats"."penalty.fk_penalty_team1_idx" ON "penalty" ("team");
CREATE INDEX "stats"."penalty.fk_penalty_player1_idx" ON "penalty" ("player");
CREATE INDEX "stats"."penalty.fk_penalty_player2_idx" ON "penalty" ("server");
CREATE INDEX "stats"."penalty.fk_penalty_player3_idx" ON "penalty" ("goalie");
CREATE TABLE "stats"."meta"(
  "id" INTEGER PRIMARY KEY NOT NULL,
  "match" INTEGER,
  "period" INTEGER,
  "time" TEXT,
  "note" TEXT NOT NULL,
  "subject" TEXT,
  "verb" TEXT,
  "object" TEXT,
  CONSTRAINT "fk_table1_game1"
    FOREIGN KEY("match")
    REFERENCES "match"("id")
);
CREATE INDEX "stats"."meta.fk_table1_game1_idx" ON "meta" ("match");
CREATE TABLE "stats"."lstat"(
  "id" INTEGER PRIMARY KEY NOT NULL,
  "team" TEXT NOT NULL,
  "player" TEXT NOT NULL,
  "year" INTEGER NOT NULL,
  "season" INTEGER NOT NULL,
  "G" INTEGER DEFAULT 0,
  "A" INTEGER DEFAULT 0,
  "PIM" INTEGER DEFAULT 0,
  "PPG" INTEGER DEFAULT 0,
  "PPA" INTEGER DEFAULT 0,
  "SHG" INTEGER DEFAULT 0,
  "SHA" INTEGER DEFAULT 0,
  "GWG" INTEGER DEFAULT 0,
  "W" INTEGER DEFAULT 0,
  "L" INTEGER DEFAULT 0,
  "OTL" INTEGER DEFAULT 0,
  "SH" INTEGER DEFAULT 0,
  "GA" INTEGER DEFAULT 0,
  "SHO" INTEGER DEFAULT 0,
  CONSTRAINT "fk_lstats_team1"
    FOREIGN KEY("team")
    REFERENCES "team"("id"),
  CONSTRAINT "fk_lstats_player1"
    FOREIGN KEY("player")
    REFERENCES "player"("id")
);
CREATE INDEX "stats"."lstat.fk_lstats_team1_idx" ON "lstat" ("team");
CREATE INDEX "stats"."lstat.fk_lstats_player1_idx" ON "lstat" ("player");
COMMIT;
