-- 依存順に DROP してクリーンスタート(開発用途)
DROP TABLE IF EXISTS review CASCADE;
DROP TABLE IF EXISTS favorite_item CASCADE; DROP TABLE IF EXISTS chat CASCADE;
DROP TABLE IF EXISTS app_order CASCADE; DROP TABLE IF EXISTS item CASCADE;
DROP TABLE IF EXISTS category CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ===== users(ユーザー)テーブル作成 ===== 
CREATE TABLE users (
	id SERIAL PRIMARY KEY,　-- 主キー(連番)
	name VARCHAR(50) NOT NULL,　-- 表示名(必須)
	email VARCHAR(255) NOT NULL UNIQUE,　-- ログイン用メール(必須・一意)
	password VARCHAR(255) NOT NULL,　-- パスワード(開発時は平文運用を想定)
	role VARCHAR(20) NOT NULL, -- 権限(USER / ADMIN)
	line_notify_token VARCHAR(255), -- LINE Notify アクセストークン
	enabled BOOLEAN NOT NULL DEFAULT TRUE -- アカウント有効/無効フラグ(既定は有効)
);


-- ===== category(カテゴリ)テーブル作成 ===== 
CREATE TABLE category (
  id SERIAL PRIMARY KEY, -- 主キー(連番)
  name VARCHAR(50) NOT NULL UNIQUE ); -- カテゴリ名(必須・一意)
  
-- ===== item(商品)テーブル作成 ===== 
CREATE TABLE item (
	id SERIAL PRIMARY KEY,
	user_id INT NOT NULL,
	name VARCHAR(255) NOT NULL,
	description TEXT,
	price NUMERIC(10,2) NOT NULL,
	category_id INT,
	status VARCHAR(20) DEFAULT '出品中',
	image_url TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 作成日時(既定で現在時刻) 
	FOREIGN KEY (user_id) REFERENCES users(id), -- 出品者 FK 制約
	FOREIGN KEY (category_id) REFERENCES category(id) -- カテゴリ FK 制約
);

-- ===== app_order(注文)テーブル作成 =====

CREATE TABLE app_order (
	id SERIAL PRIMARY KEY,
	item_id INT NOT NULL,
	buyer_id INT NOT NULL,
	price NUMERIC(10,2) NOT NULL,
	status VARCHAR(20) DEFAULT '購入済',
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 作成日時
	FOREIGN KEY (item_id) REFERENCES item(id), -- 商品FK制約
	FOREIGN KEY (buyer_id) REFERENCES users(id) --購入者FK制約
);

-- ===== chat(取引チャット)テーブル作成 =====

CREATE TABLE chat (
	id SERIAL PRIMARY KEY,
	item_id INT NOT NULL,
	sender_id INT NOT NULL,
	message TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 送信日時 
	FOREIGN KEY (item_id) REFERENCES item(id), -- 商品 FK 制約 
	FOREIGN KEY (sender_id) REFERENCES users(id) -- 送信者 FK 制約
);

-- ===== favorite_item(お気に入り)テーブル作成 ===== 
CREATE TABLE favorite_item (
	id SERIAL PRIMARY KEY,
	user_id INT NOT NULL,
	item_id INT NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 登録日時
	UNIQUE (user_id, item_id),
	FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (item_id) REFERENCES item(id)
);

-- ===== review(評価)テーブル作成 ===== 
CREATE TABLE review (
	id SERIAL PRIMARY KEY,
	order_id INT NOT NULL UNIQUE,
	reviewer_id INT NOT NULL,
	seller_id INT NOT NULL,
	item_id INT NOT NULL,
	rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5), -- 1〜5 の整数 
	comment TEXT, -- コメント(任意) 
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 登録日時
	FOREIGN KEY (order_id) REFERENCES app_order(id), 
	FOREIGN KEY (reviewer_id) REFERENCES users(id), 
	FOREIGN KEY (seller_id) REFERENCES users(id), 
	FOREIGN KEY (item_id) REFERENCES item(id)
);

-- ===== パフォーマンス向上のためのインデックス =====
CREATE INDEX IF NOT EXISTS idx_item_user_id ON item(user_id);
CREATE INDEX IF NOT EXISTS idx_item_category_id ON item(category_id);
CREATE INDEX IF NOT EXISTS idx_order_item_id ON app_order(item_id);
CREATE INDEX IF NOT EXISTS idx_order_buyer_id ON app_order(buyer_id);
CREATE INDEX IF NOT EXISTS idx_chat_item_id ON chat(item_id);
CREATE INDEX IF NOT EXISTS idx_chat_sender_id ON chat(sender_id);
CREATE INDEX IF NOT EXISTS idx_fav_user_id ON favorite_item(user_id);
CREATE INDEX IF NOT EXISTS idx_fav_item_id ON favorite_item(item_id); 
CREATE INDEX IF NOT EXISTS idx_review_order_id ON review(order_id);



