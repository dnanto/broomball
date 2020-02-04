SELECT
  a.player
    AS player,
  COALESCE(b.G, 0) +
  COALESCE(c.A1, 0) +
  COALESCE(d.A2, 0) +
  COALESCE(e.G, 0) +
  COALESCE(e.A, 0)
    AS P,
  COALESCE(b.G, 0) +
  COALESCE(e.G, 0)
    AS G,
  COALESCE(c.A1, 0) +
  COALESCE(d.A2, 0) +
  COALESCE(e.A, 0)
    AS A,
  COALESCE(c.A1, 0)
    AS A1,
  COALESCE(d.A2, 0)
    AS A2,
  COALESCE(b.PPG, 0) +
  COALESCE(e.PPG, 0)
    AS PPG,
  COALESCE(c.PPA1, 0) +
  COALESCE(d.PPA2, 0) +
  COALESCE(e.PPA, 0)
    AS PPA,
  COALESCE(c.PPA1, 0)
    AS PPA1,
  COALESCE(d.PPA2, 0)
    AS PPA2,
  COALESCE(b.SHG, 0) +
  COALESCE(e.SHG, 0)
    AS SHG,
  COALESCE(c.SHA1, 0) +
  COALESCE(d.SHA2, 0) +
  COALESCE(e.SHA, 0)
    AS SHA,
  COALESCE(c.SHA1, 0)
    AS SHA1,
  COALESCE(d.SHA2, 0)
    AS SHA2,
  COALESCE(b.ENG, 0)
    AS ENG,
  COALESCE(c.ENA1, 0) +
  COALESCE(d.ENA2, 0)
    AS ENA,
  COALESCE(c.ENA1, 0)
    AS ENA1,
  COALESCE(d.ENA2, 0)
    AS ENA2,
  COALESCE(f.PN, 0)
    AS PN,
  COALESCE(e.PIM, 0) +
  COALESCE(f.PIM, 0)
    AS PIM
FROM
  (
      (
          (
            SELECT player, team
            FROM roster
          ) AS A
          JOIN
          (
            SELECT DISTINCT team
            FROM
              (
                SELECT team1 AS team
                FROM match
                WHERE year = 2019 AND season = 24
                UNION ALL
                SELECT team2 AS team
                FROM match
                WHERE year = 2019 AND season = 24
              ) AS teams
          ) AS B
            ON A.team = B.team
      ) AS a
      LEFT JOIN
      (
        SELECT
          shooter        AS player,
          COUNT(shooter) AS G,
          SUM(PP)  AS PPG,
          SUM(SH)  AS SHG,
          SUM(EN)  AS ENG
        FROM point
        GROUP BY shooter
      ) AS b
        ON a.player = b.player
      LEFT JOIN
      (
        SELECT
          assist1        AS player,
          COUNT(assist1) AS A1,
          SUM(PP)  AS PPA1,
          SUM(SH)  AS SHA1,
          SUM(EN)  AS ENA1
        FROM point
        GROUP BY assist1
      ) AS c
        ON a.player = c.player
      LEFT JOIN
      (
        SELECT
          assist2        AS player,
          COUNT(assist2) AS A2,
          SUM(PP)  AS PPA2,
          SUM(SH)  AS SHA2,
          SUM(EN)  AS ENA2
        FROM point
        GROUP BY assist2
      ) AS d
        ON a.player = d.player
      LEFT JOIN
      (
        SELECT
          player,
          SUM(G)   AS G,
          SUM(A)   AS A,
          SUM(PPG) AS PPG,
          SUM(PPA) AS PPA,
          SUM(SHG) AS SHG,
          SUM(SHA) AS SHA,
          SUM(PIM) AS PIM
        FROM lstat
        GROUP BY player
      ) AS e
        ON a.player = e.player
      LEFT JOIN
      (
        SELECT
          player,
          SUM(duration) AS PIM,
          COUNT(player) AS PN
        FROM penalty
        GROUP BY player
      ) AS f
        ON a.player = f.player
  )
ORDER BY
  P
  DESC,
  player
  ASC
