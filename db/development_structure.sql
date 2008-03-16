CREATE TABLE schema_info (version integer);
CREATE TABLE scrape_results ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "created_at" datetime DEFAULT NULL, "updated_at" datetime DEFAULT NULL, "watch_id" integer DEFAULT NULL, "text_raw" text DEFAULT NULL);
CREATE TABLE watches ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "created_at" datetime DEFAULT NULL, "updated_at" datetime DEFAULT NULL, "uri" varchar(255) DEFAULT NULL, "xpath" varchar(255) DEFAULT NULL);
INSERT INTO schema_info (version) VALUES (3)