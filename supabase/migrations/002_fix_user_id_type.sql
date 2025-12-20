-- user_idカラムがUUID型の場合、TEXT型に変更
-- このマイグレーションは、既存のテーブルでuser_idがUUID型になっている場合に実行してください

-- まず、user_idカラムの型を確認
-- もしUUID型の場合は、以下のコマンドでTEXT型に変更

-- 注意: 既存のデータがある場合は、データをバックアップしてから実行してください

-- user_idカラムをTEXT型に変更（既存のデータを保持）
ALTER TABLE public.trades 
ALTER COLUMN user_id TYPE TEXT USING user_id::TEXT;

-- インデックスを再作成（必要に応じて）
DROP INDEX IF EXISTS idx_trades_user_id;
CREATE INDEX IF NOT EXISTS idx_trades_user_id ON public.trades(user_id);

DROP INDEX IF EXISTS idx_trades_user_date;
CREATE INDEX IF NOT EXISTS idx_trades_user_date ON public.trades(user_id, date DESC);

