--
CREATE TABLE IF NOT EXISTS `users` (
    `u_id`              INTEGER PRIMARY KEY AUTOINCREMENT,
    `u_login`           TEXT NOT NULL UNIQUE,
    `u_name`            TEXT NOT NULL,
    `u_sname`           TEXT NOT NULL DEFAULT '',
    `u_fname`           TEXT NOT NULL DEFAULT '',
    `u_email`           TEXT NOT NULL UNIQUE,
    `u_password`        TEXT NOT NULL,
    `u_tel`             TEXT NOT NULL DEFAULT '',
    `u_icq`             TEXT NOT NULL DEFAULT '',
    `u_skype`           TEXT NOT NULL DEFAULT '',
    `u_user_session`    TEXT NOT NULL DEFAULT '',
    `u_admin_session`   TEXT NOT NULL DEFAULT '',
    `u_mode`            INTEGER NOT NULL DEFAULT '0',
    `u_absolute`        INTEGER NOT NULL DEFAULT '0',
    `u_create`          DATETIME NOT NULL DEFAULT "strftime('%s','now')",
    `u_avatar`          TEXT,
    `u_about`           TEXT
);
CREATE INDEX IF NOT EXISTS `u_id` ON `users` (`u_id`);
INSERT INTO `users` VALUES (NULL,'a_admin','Admin','','','admin@root.com','527430327a4474f69ba8a213d65673d1','','','','','','2','1',strftime('%s','now'),'','');

--
CREATE TABLE IF NOT EXISTS `guestbook` (
    `g_id`          INTEGER PRIMARY KEY AUTOINCREMENT,
    `g_user`        TEXT NOT NULL,
    `g_user_email`  TEXT,
    `g_mes`         TEXT NOT NULL,
    `g_answer`      TEXT,
    `g_admin_id`    INTEGER,
    `g_create`      DATETIME NOT NULL DEFAULT "DATETIME()"
);
CREATE INDEX IF NOT EXISTS `g_id` ON `guestbook` (`g_id`);

--
CREATE TABLE IF NOT EXISTS `articles` (
    `a_id`          INTEGER PRIMARY KEY AUTOINCREMENT,
    `a_u_login`     TEXT,
    `a_u_id`        INTEGER,
    `a_create`      DATETIME,
    `a_update`      DATETIME DEFAULT '',
    `a_title`       TEXT,
    `a_description` TEXT,
    `a_preview`     TEXT,
    `a_comments`    INTEGER NOT NULL DEFAULT '0',
    `a_previews`    INTEGER DEFAULT '0',
    `a_cat`         TEXT NOT NULL,
    `a_publish`   INTEGER NOT NULL DEFAULT '0'
);
CREATE INDEX IF NOT EXISTS `a_id` ON `articles` (`a_id`);

--
CREATE TABLE IF NOT EXISTS `gallery` (
    `g_id`          INTEGER PRIMARY KEY AUTOINCREMENT,
    `g_title`       TEXT NOT NULL,
    `g_description` TEXT,
    `g_cover`       TEXT,
    `g_create`      DATE not NULL,
    `g_author_id`   INTEGER NOT NULL,
    `g_comments`    INTEGER NOT NULL DEFAULT '0',
    `g_previews`    INTEGER DEFAULT '0',
    `g_publish`   INTEGER NOT NULL DEFAULT '0'
);
CREATE INDEX IF NOT EXISTS `g_id` ON `gallery` (`g_id`);

--
CREATE TABLE IF NOT EXISTS `photos` (
    `p_id`            INTEGER PRIMARY KEY AUTOINCREMENT,
    `g_id`            INTEGER NOT NULL,
    `p_name`          TEXT NOT NULL,
    `p_create`        DATETIME NOT NULL DEFAULT "DATETIME()",
    `p_description`   TEXT
);
CREATE INDEX IF NOT EXISTS `p_id` ON `photos` (`p_id`);

-- cmments for articles
CREATE TABLE IF NOT EXISTS `comments` (
    `c_id`      INTEGER PRIMARY KEY AUTOINCREMENT,
    `c_a_id`    INTEGER NOT NULL DEFAULT "",
    `c_g_id`    INTEGER NOT NULL DEFAULT "",
    `c_u_id`    INTEGER NOT NULL,
    `c_create`  DATETIME NOT NULL DEFAULT "DATETIME()",
    `c_comment` TEXT,
    `c_update`  DATETIME NOT NULL DEFAULT ""
);
CREATE INDEX IF NOT EXISTS `c_id` ON `comments` (`c_id`);