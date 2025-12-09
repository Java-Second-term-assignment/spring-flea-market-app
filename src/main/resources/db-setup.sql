-- PostgreSQLデータベースとユーザーのセットアップスクリプト
-- このスクリプトはPostgreSQLのスーパーユーザーで実行してください
-- macOSのHomebrewでは現在のユーザー名がデフォルトのスーパーユーザーです

-- データベースが存在しない場合のみ作成
-- OWNERは実行ユーザー（現在のユーザー）に設定されます
SELECT 'CREATE DATABASE fleamarket'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'fleamarket')\gexec

-- 上記の方法が使えない場合は、以下のDOブロックを使用
-- DO $$
-- BEGIN
--     IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'fleamarket') THEN
--         EXECUTE 'CREATE DATABASE fleamarket WITH ENCODING = ''UTF8'' LC_COLLATE = ''en_US.UTF-8'' LC_CTYPE = ''en_US.UTF-8'' TEMPLATE = template0';
--     END IF;
-- END
-- $$;

-- データベースが既に存在する場合はエラーが出ますが、問題ありません
CREATE DATABASE fleamarket
    WITH 
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TEMPLATE = template0;

-- ユーザーが存在しない場合のみ作成
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'fleauser') THEN
        CREATE USER fleauser WITH PASSWORD 'fleapass';
    END IF;
END
$$;

-- データベースへの権限を付与
GRANT ALL PRIVILEGES ON DATABASE fleamarket TO fleauser;

-- fleamarketデータベースに接続してスキーマ権限を付与
\c fleamarket

-- スキーマへの権限を付与
GRANT ALL ON SCHEMA public TO fleauser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO fleauser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO fleauser;
