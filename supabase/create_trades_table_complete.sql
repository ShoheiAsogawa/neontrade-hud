-- ============================================
-- NEON TRADE APP - トレードテーブル作成SQL
-- ============================================
-- このSQLをSupabaseのSQL Editorで実行してください
-- 既存のテーブルがある場合は、先に削除してから実行してください

-- ============================================
-- 1. 既存のテーブルと関連オブジェクトを削除（既存データも削除されます）
-- ============================================
DROP TABLE IF EXISTS public.trades CASCADE;

-- ============================================
-- 2. トレードテーブルの作成
-- ============================================
CREATE TABLE public.trades (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id TEXT NOT NULL,
    symbol TEXT NOT NULL,
    side TEXT NOT NULL CHECK (side IN ('LONG', 'SHORT')),
    entry_price NUMERIC,
    exit_price NUMERIC,
    quantity NUMERIC,
    pnl NUMERIC NOT NULL,
    date DATE NOT NULL,
    time TEXT NOT NULL,
    logic TEXT NOT NULL,
    timeframe TEXT NOT NULL,
    strategy TEXT NOT NULL,
    mood TEXT NOT NULL,
    image_url TEXT,
    status TEXT NOT NULL CHECK (status IN ('WIN', 'LOSS', 'BE')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 3. インデックスの作成
-- ============================================
CREATE INDEX idx_trades_user_id ON public.trades(user_id);
CREATE INDEX idx_trades_date ON public.trades(date DESC);
CREATE INDEX idx_trades_user_date ON public.trades(user_id, date DESC);

-- ============================================
-- 4. RLS (Row Level Security) の有効化
-- ============================================
ALTER TABLE public.trades ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 5. RLSポリシーの作成
-- ============================================
-- 認証済みユーザーは自分のデータのみアクセス可能
-- 認証が設定されていない場合は、user_idでフィルタリング

-- SELECT（読み取り）ポリシー
CREATE POLICY "Users can view their own trades"
    ON public.trades FOR SELECT
    USING (
        auth.uid()::text = user_id 
        OR user_id = current_setting('app.user_id', true)
    );

-- INSERT（挿入）ポリシー
CREATE POLICY "Users can insert their own trades"
    ON public.trades FOR INSERT
    WITH CHECK (
        auth.uid()::text = user_id 
        OR user_id = current_setting('app.user_id', true)
    );

-- UPDATE（更新）ポリシー
CREATE POLICY "Users can update their own trades"
    ON public.trades FOR UPDATE
    USING (
        auth.uid()::text = user_id 
        OR user_id = current_setting('app.user_id', true)
    );

-- DELETE（削除）ポリシー
CREATE POLICY "Users can delete their own trades"
    ON public.trades FOR DELETE
    USING (
        auth.uid()::text = user_id 
        OR user_id = current_setting('app.user_id', true)
    );

-- ============================================
-- 6. updated_atを自動更新するトリガー関数
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- ============================================
-- 7. トリガーの作成
-- ============================================
CREATE TRIGGER update_trades_updated_at 
    BEFORE UPDATE ON public.trades
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 8. 確認用クエリ（オプション）
-- ============================================
-- テーブルが正しく作成されたか確認
SELECT 
    column_name, 
    data_type,
    is_nullable,
    column_default
FROM 
    information_schema.columns 
WHERE 
    table_schema = 'public' 
    AND table_name = 'trades'
ORDER BY 
    ordinal_position;

-- インデックスが作成されたか確認
SELECT 
    indexname,
    indexdef
FROM 
    pg_indexes 
WHERE 
    tablename = 'trades'
    AND schemaname = 'public';

-- RLSポリシーが作成されたか確認
SELECT 
    policyname,
    cmd,
    qual,
    with_check
FROM 
    pg_policies 
WHERE 
    tablename = 'trades'
    AND schemaname = 'public';

