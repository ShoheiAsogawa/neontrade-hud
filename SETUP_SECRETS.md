# GitHub Secrets設定値の取得方法

このドキュメントでは、GitHub Actionsで使用する各Secretの実際の値をどこで確認・取得するかを説明します。

## 1. Supabase設定値

### VITE_SUPABASE_URL

1. [Supabase Dashboard](https://app.supabase.com)にログイン
2. プロジェクトを選択
3. 左側メニューの「Settings」（⚙️アイコン）をクリック
4. 「API」セクションをクリック
5. 「Project URL」の値をコピー
   - 例: `https://xxxxxxxxxxxxx.supabase.co`

### VITE_SUPABASE_ANON_KEY

1. 上記と同じ手順で「Settings」→「API」に移動
2. 「Project API keys」セクションを確認
3. 「anon」または「public」キーの値をコピー
   - 注意: 「service_role」キーは使用しないでください（セキュリティ上の理由）

## 2. AWS設定値

### VITE_AWS_REGION

通常は以下のいずれかを使用します：
- `ap-northeast-1` (東京) - 推奨
- `ap-northeast-3` (大阪)
- `us-east-1` (バージニア)
- `us-west-2` (オレゴン)

**確認方法:**
1. [AWS Console](https://console.aws.amazon.com)にログイン
2. S3サービスに移動
3. バケットを作成/選択
4. バケットの詳細ページでリージョンを確認

### VITE_AWS_ACCESS_KEY_ID と VITE_AWS_SECRET_ACCESS_KEY

**重要:** 新しいIAMユーザーを作成して、最小限の権限のみを付与することを推奨します。

#### IAMユーザーの作成手順:

1. [AWS IAM Console](https://console.aws.amazon.com/iam/)にログイン
2. 左側メニューから「Users」をクリック
3. 「Create user」をクリック
4. ユーザー名を入力（例: `neon-trade-app-s3-user`）
5. 「Next」をクリック
6. 「Attach policies directly」を選択
7. 「Create policy」をクリック（新しいポリシーを作成）

#### ポリシーの作成:

1. 「JSON」タブを選択
2. 以下のポリシーを貼り付け（`your-bucket-name`を実際のバケット名に置き換え）:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::your-bucket-name/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": "arn:aws:s3:::your-bucket-name"
    }
  ]
}
```

3. ポリシー名を入力（例: `NeonTradeAppS3Policy`）
4. 「Create policy」をクリック
5. ユーザー作成画面に戻り、作成したポリシーを選択
6. 「Next」→「Create user」をクリック

#### アクセスキーの作成:

1. 作成したユーザーをクリック
2. 「Security credentials」タブをクリック
3. 「Create access key」をクリック
4. 「Command Line Interface (CLI)」を選択
5. 「Next」をクリック
6. 説明を入力（オプション）
7. 「Create access key」をクリック
8. **重要:** 以下の2つの値をコピーして安全に保管:
   - **Access key ID** → `VITE_AWS_ACCESS_KEY_ID` に使用
   - **Secret access key** → `VITE_AWS_SECRET_ACCESS_KEY` に使用
   - ⚠️ Secret access keyはこの画面でしか表示されません！

### VITE_AWS_S3_BUCKET_NAME

1. [AWS S3 Console](https://s3.console.aws.amazon.com)にログイン
2. バケット一覧から使用するバケットを選択
3. バケット名をコピー
   - 例: `neon-trade-app-images`

**バケットがまだない場合の作成手順:**

1. 「Create bucket」をクリック
2. バケット名を入力（グローバルで一意である必要があります）
3. リージョンを選択（例: `ap-northeast-1`）
4. 「Block Public Access settings」を設定
   - パブリックアクセスを許可する場合は適切に設定
   - またはCloudFrontを使用する場合はブロックのまま
5. 「Create bucket」をクリック

## 3. ローカルでの確認方法

既に `.env` ファイルが存在する場合：

```bash
# Windows PowerShell
Get-Content .env

# Windows CMD
type .env

# Linux/Mac
cat .env
```

**注意:** `.env` ファイルはGitにコミットしないでください（`.gitignore`に含まれています）

## 4. 値の確認チェックリスト

各Secretを追加する前に、以下を確認してください：

- [ ] `VITE_SUPABASE_URL`: SupabaseプロジェクトのURL（`https://`で始まる）
- [ ] `VITE_SUPABASE_ANON_KEY`: anon/publicキー（長い文字列）
- [ ] `VITE_AWS_REGION`: リージョンコード（例: `ap-northeast-1`）
- [ ] `VITE_AWS_ACCESS_KEY_ID`: IAMユーザーのアクセスキーID
- [ ] `VITE_AWS_SECRET_ACCESS_KEY`: IAMユーザーのシークレットキー
- [ ] `VITE_AWS_S3_BUCKET_NAME`: S3バケット名

## 5. セキュリティのベストプラクティス

1. **最小権限の原則**
   - IAMユーザーには必要最小限の権限のみを付与
   - 不要になったキーは削除

2. **定期的なローテーション**
   - アクセスキーは定期的に更新（3-6ヶ月ごと推奨）

3. **キーの保管**
   - Secret access keyは安全な場所に保管
   - 共有や公開は絶対にしない

4. **環境の分離**
   - 開発環境と本番環境で異なるキーを使用

## トラブルシューティング

### Supabase接続エラー
- URLが正しいか確認（`https://`で始まる）
- anonキーが正しいか確認（service_roleキーではないか）

### AWS S3アップロードエラー
- アクセスキーIDとシークレットキーが正しいか確認
- IAMポリシーで適切な権限が付与されているか確認
- バケット名とリージョンが正しいか確認

### GitHub Actionsでのエラー
- Secret名が正確か確認（大文字小文字を区別）
- Secretが正しく設定されているか確認（リポジトリのSettings → Secrets）

