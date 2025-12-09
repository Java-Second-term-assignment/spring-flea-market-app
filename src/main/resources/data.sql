-- 初期ユーザ投入（開発用）。NoOpPasswordEncoder 前提で平文パスワード
INSERT INTO users (name, email, password, role) VALUES
-- 出品者：メールとパスワード
('出品者 A',
'sellerA@example.com',
'password',
'USER'),
-- 購入者：わかりやすいメールに修正（'z'は誤りだと運用上混乱するため）
('購入者 B',
'buyerB@example.com',
'password',
'USER'),
-- 管理者：管理用アカウント
('運営者 C',
'adminC@example.com',
'adminpass',
'ADMIN');
-- 初期カテゴリ投入（よく使う 4 種）
INSERT INTO category (name) VALUES
-- 書籍カテゴリ
('本'),
-- 家電カテゴリ
('家電'),
-- ファッションカテゴリ
('ファッション'),
-- 玩具カテゴリ
('おもちゃ');
-- 初期商品投入（出品者 A が 2 商品を出品）
INSERT INTO item (user_id, name, description, price, category_id, status, image_url)
VALUES
-- Java 入門書（カテゴリ：本、出品中）
(
(SELECT id FROM users WHERE email = 'sellerA@example.com'),
'Java プログラミング入門'
,
'初心者向けの Java 入門書です。'
,
1500.00,
(SELECT id FROM category WHERE name = '本'),
'出品中',
NULL
),
-- イヤホン（カテゴリ：家電、出品中）
(
(SELECT id FROM users WHERE email = 'sellerA@example.com'),
'ワイヤレスイヤホン',
'ノイズキャンセリング機能付き。',
8000.00,
(SELECT id FROM category WHERE name = '家電'),
'出品中',
NULL
);
-- （任意）サンプル注文：コメントアウト例。必要時にコメント解除
-- INSERT INTO app_order (item_id, buyer_id, price, status)
-- VALUES (
--	(SELECT id FROM item WHERE name = 'Java プログラミング入門'),
--	(SELECT id FROM users WHERE email = 'buyerB@example.com'),
--	1500.00,
--	'購入済'
--);