# データベースエラー修正ガイド

## エラー内容

```
invalid input syntax for type uuid: "user_1766195429532_y938fhcgs"
```

このエラーは、Supabaseの`trades`テーブルの`user_id`カラムがUUID型として定義されているのに、文字列を渡そうとしているために発生しています。

## 原因

Supabaseのテーブルエディタで手動でテーブルを作成した場合、`user_id`カラムがデフォルトでUUID型になっている可能性があります。

## 解決方法

### 方法1: SQL Editorで直接修正（推奨）

1. [Supabase Dashboard](https://app.supabase.com)にログイン
2. プロジェクトを選択
3. 左側メニューの「SQL Editor」をクリック
4. 以下のSQLを実行:

```sql
-- user_idカラムをTEXT型に変更
ALTER TABLE public.trades 
ALTER COLUMN user_id TYPE TEXT USING user_id::TEXT;
```

5. 「Run」をクリックして実行

### 方法2: マイグレーションファイルを使用

1. `supabase/migrations/002_fix_user_id_type.sql`の内容を確認
2. SupabaseのSQL Editorで実行

### 方法3: テーブルを再作成（データがない場合）

既存のデータがない場合は、テーブルを削除して再作成:

```sql
-- 注意: 既存のデータがすべて削除されます
DROP TABLE IF EXISTS public.trades CASCADE;

-- テーブルを再作成（001_create_trades_table.sqlの内容を実行）
CREATE TABLE IF NOT EXISTS public.trades (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id TEXT NOT NULL,  -- TEXT型であることを確認
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

-- インデックスとRLSポリシーも再作成
-- （001_create_trades_table.sqlの残りの部分を実行）
```

## 確認方法

修正後、以下のSQLで`user_id`カラムの型を確認:

```sql
SELECT 
    column_name, 
    data_type 
FROM 
    information_schema.columns 
WHERE 
    table_schema = 'public' 
    AND table_name = 'trades' 
    AND column_name = 'user_id';
```

結果が `data_type = 'text'` であることを確認してください。

## 修正後の動作確認

1. ブラウザでアプリをリロード
2. エラーが解消されているか確認
3. 新しいトレードを追加してテスト

## トラブルシューティング

### RLSポリシーエラーが発生する場合

RLSポリシーも確認してください:

```sql
-- 既存のポリシーを確認
SELECT * FROM pg_policies WHERE tablename = 'trades';

-- 必要に応じてポリシーを再作成
-- （001_create_trades_table.sqlのRLSポリシー部分を実行）
```

### データ型変換エラー

既存のデータがある場合、`USING user_id::TEXT`で変換できない場合は:

```sql
-- 一時カラムを作成
ALTER TABLE public.trades ADD COLUMN user_id_new TEXT;

-- データをコピー
UPDATE public.trades SET user_id_new = user_id::TEXT;

-- 古いカラムを削除
ALTER TABLE public.trades DROP COLUMN user_id;

-- 新しいカラムをリネーム
ALTER TABLE public.trades RENAME COLUMN user_id_new TO user_id;

-- NOT NULL制約を追加
ALTER TABLE public.trades ALTER COLUMN user_id SET NOT NULL;
```

