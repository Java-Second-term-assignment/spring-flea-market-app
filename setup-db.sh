#!/bin/bash

# これを実行するだけでデータベースを作成してくれます。

# PostgreSQLデータベースセットアップスクリプト
# このスクリプトはPostgreSQLがインストールされ、サービスが起動している必要があります

echo "PostgreSQLデータベースセットアップを開始します..."

# PostgreSQLがインストールされているか確認
if ! command -v psql &> /dev/null; then
    echo "エラー: PostgreSQLがインストールされていません。"
    echo "macOSの場合: brew install postgresql@15"
    echo "その後、PostgreSQLサービスを起動してください: brew services start postgresql@15"
    exit 1
fi

# PostgreSQLサービスが起動しているか確認
if ! pg_isready -q; then
    echo "エラー: PostgreSQLサービスが起動していません。"
    echo "macOSの場合: brew services start postgresql@15"
    exit 1
fi

# SQLスクリプトのパス
SQL_SCRIPT="src/main/resources/db-setup.sql"

# SQLスクリプトが存在するか確認
if [ ! -f "$SQL_SCRIPT" ]; then
    echo "エラー: SQLスクリプトが見つかりません: $SQL_SCRIPT"
    exit 1
fi

# PostgreSQLのスーパーユーザーを取得（macOSのHomebrewでは現在のユーザー名がデフォルト）
PG_USER="${PGUSER:-$(whoami)}"

# PostgreSQLのスーパーユーザーでSQLスクリプトを実行
echo "データベースとユーザーを作成しています..."
echo "PostgreSQLユーザー: $PG_USER として接続します..."
# エラーメッセージを抑制（既存のデータベース/ユーザーがある場合のエラーは無視）
psql -U "$PG_USER" -f "$SQL_SCRIPT" 2>&1 | grep -v "already exists" || true

if [ $? -eq 0 ]; then
    echo "✓ データベースとユーザーの作成が完了しました。"
    echo ""
    echo "作成された内容:"
    echo "  - データベース: fleamarket"
    echo "  - ユーザー: fleauser"
    echo "  - パスワード: fleapass"
    echo ""
    echo "アプリケーションを起動できます。"
else
    echo "エラー: データベースの作成に失敗しました。"
    exit 1
fi

