# AWS Amplify デプロイメントガイド

このドキュメントでは、AWS Amplifyを使用してアプリケーションをデプロイする方法を説明します。

## 概要

AWS Amplifyは、GitHubリポジトリと直接連携して自動的にビルドとデプロイを実行します。`main`ブランチにプッシュするたびに、自動的に最新バージョンがデプロイされます。

## 前提条件

- AWSアカウント
- GitHubリポジトリ（`ShoheiAsogawa/neon-trade-app`）
- Supabaseプロジェクト
- AWS S3バケット

## セットアップ手順

### 1. AWS Amplifyコンソールにアクセス

1. [AWS Amplify Console](https://console.aws.amazon.com/amplify/)にログイン
2. 「New app」→「Host web app」をクリック

### 2. GitHubリポジトリを接続

1. 「GitHub」を選択
2. 「Continue」をクリック
3. GitHubアカウントで認証（初回のみ）
4. リポジトリ `ShoheiAsogawa/neon-trade-app` を選択
5. ブランチ `main` を選択
6. 「Next」をクリック

### 3. ビルド設定

Amplifyは自動的に `amplify.yml` を検出します。設定を確認：

**Build settings:**
```yaml
version: 1
frontend:
  phases:
    preBuild:
      commands:
        - npm ci
    build:
      commands:
        - npm run build
  artifacts:
    baseDirectory: dist
    files:
      - '**/*'
  cache:
    paths:
      - node_modules/**/*
```

**環境変数の設定:**

「Environment variables」セクションで以下を追加します。各変数の値の取得方法は以下の通りです：

### 環境変数の値の取得方法

#### 1. VITE_SUPABASE_URL（SupabaseプロジェクトURL）

**手順:**
1. [Supabase Dashboard](https://app.supabase.com)にログイン
2. 左側のプロジェクト一覧から、使用するプロジェクトをクリック
3. 左側メニューの「Settings」（⚙️アイコン）をクリック
4. 「API」セクションをクリック
5. 「Project URL」の値をコピー
   - 形式: `https://xxxxxxxxxxxxx.supabase.co`
   - 例: `https://abcdefghijklmnop.supabase.co`

**Amplifyでの設定:**
- Key: `VITE_SUPABASE_URL`
- Value: コピーしたURL（例: `https://abcdefghijklmnop.supabase.co`）

---

#### 2. VITE_SUPABASE_ANON_KEY（Supabase公開キー）

**手順:**
1. 上記と同じ手順で「Settings」→「API」に移動
2. 「Project API keys」セクションを確認
3. 「anon」または「public」キーを探す
4. 「Reveal」ボタンをクリックしてキーを表示
5. キーの値をコピー
   - 長い文字列（例: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`）

**⚠️ 重要:**
- 「anon」または「public」キーを使用してください
- 「service_role」キーは使用しないでください（セキュリティ上の理由）

**Amplifyでの設定:**
- Key: `VITE_SUPABASE_ANON_KEY`
- Value: コピーしたanonキー

---

#### 3. VITE_AWS_REGION（AWSリージョン）

**手順:**
1. [AWS S3 Console](https://s3.console.aws.amazon.com)にログイン
2. 使用するS3バケットを選択（または作成）
3. バケットの詳細ページでリージョンを確認

**一般的なリージョンコード:**
- `ap-northeast-1` - 東京（推奨）
- `ap-northeast-3` - 大阪
- `us-east-1` - バージニア
- `us-west-2` - オレゴン

**Amplifyでの設定:**
- Key: `VITE_AWS_REGION`
- Value: リージョンコード（例: `ap-northeast-1`）

---

#### 4. VITE_AWS_ACCESS_KEY_ID（AWSアクセスキーID）

**手順:**
1. [AWS IAM Console](https://console.aws.amazon.com/iam/)にログイン
2. 左側メニューから「Users」をクリック
3. 既存のユーザーを選択、または「Create user」で新規作成

**新規ユーザー作成の場合:**
1. 「Create user」をクリック
2. ユーザー名を入力（例: `neon-trade-app-s3-user`）
3. 「Next」をクリック
4. 「Attach policies directly」を選択
5. 「Create policy」をクリック
6. 「JSON」タブを選択
7. 以下のポリシーを貼り付け（`your-bucket-name`を実際のバケット名に置き換え）:

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

8. ポリシー名を入力（例: `NeonTradeAppS3Policy`）
9. 「Create policy」をクリック
10. ユーザー作成画面に戻り、作成したポリシーを選択
11. 「Next」→「Create user」をクリック

**アクセスキーの作成:**
1. 作成したユーザーをクリック
2. 「Security credentials」タブをクリック
3. 「Create access key」をクリック
4. 「Command Line Interface (CLI)」を選択
5. 「Next」をクリック
6. 説明を入力（オプション、例: `For Neon Trade App S3 access`）
7. 「Create access key」をクリック
8. **Access key ID**をコピー
   - 形式: `AKIAIOSFODNN7EXAMPLE`
   - ⚠️ この画面でしか表示されないので、必ずコピーしてください

**Amplifyでの設定:**
- Key: `VITE_AWS_ACCESS_KEY_ID`
- Value: コピーしたAccess key ID

---

#### 5. VITE_AWS_SECRET_ACCESS_KEY（AWSシークレットアクセスキー）

**手順:**
1. 上記の「アクセスキーの作成」手順の続き
2. 「Create access key」をクリックした後の画面で
3. **Secret access key**をコピー
   - 形式: `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`
   - ⚠️ **この画面でしか表示されません！** 必ずコピーして安全に保管してください
   - 「Download .csv file」をクリックしてファイルとして保存することも可能

**⚠️ 重要:**
- Secret access keyは一度しか表示されません
- 失くした場合は、新しいアクセスキーを作成する必要があります
- このキーは絶対に公開しないでください

**Amplifyでの設定:**
- Key: `VITE_AWS_SECRET_ACCESS_KEY`
- Value: コピーしたSecret access key

---

#### 6. VITE_AWS_S3_BUCKET_NAME（S3バケット名）

**既存のバケットがある場合:**
1. [AWS S3 Console](https://s3.console.aws.amazon.com)にログイン
2. バケット一覧から使用するバケットを選択
3. バケット名をコピー
   - 例: `neon-trade-app-images`

**新規バケット作成の場合:**
1. [AWS S3 Console](https://s3.console.aws.amazon.com)にログイン
2. 「Create bucket」をクリック
3. 「Bucket name」を入力
   - グローバルで一意である必要があります
   - 小文字、数字、ハイフンのみ使用可能
   - 例: `neon-trade-app-images-2024`
4. 「AWS Region」を選択（例: `ap-northeast-1`）
5. 「Block Public Access settings」を設定
   - パブリックアクセスを許可する場合: 適切に設定
   - CloudFrontを使用する場合: ブロックのままでも可
6. 「Create bucket」をクリック
7. 作成されたバケット名をコピー

**Amplifyでの設定:**
- Key: `VITE_AWS_S3_BUCKET_NAME`
- Value: バケット名（例: `neon-trade-app-images`）

---

### Amplifyでの環境変数追加手順

1. Amplifyコンソールでアプリを選択
2. 左側メニューの「Environment variables」をクリック
3. 「Manage variables」をクリック
4. 各環境変数を追加:
   - 「Add variable」をクリック
   - Keyに変数名を入力（例: `VITE_SUPABASE_URL`）
   - Valueに実際の値を入力
   - 「Save」をクリック
5. すべての変数を追加したら、「Save」をクリック

**注意事項:**
- 環境変数を変更した後は、再デプロイが必要です
- 値は暗号化されて保存されます
- ビルドログには表示されません（セキュリティのため）

詳細は [SETUP_SECRETS.md](./SETUP_SECRETS.md) も参照してください。

### 4. デプロイの実行

1. 「Save and deploy」をクリック
2. ビルドプロセスが開始されます（通常5-10分）
3. ビルドが完了すると、自動的にデプロイされます

### 5. デプロイURLの確認

ビルドが完了すると、以下のようなURLが表示されます：

```
https://main.xxxxxxxxxxxxx.amplifyapp.com
```

このURLは自動的に生成され、カスタムドメインも設定可能です。

## 自動デプロイの仕組み

### ブランチベースのデプロイ

- **mainブランチ**: 本番環境（自動デプロイ）
- **その他のブランチ**: プレビュー環境（自動デプロイ）

### デプロイトリガー

- `main`ブランチへのプッシュ
- プルリクエストの作成/更新
- 手動デプロイ（Amplifyコンソールから）

## カスタムドメインの設定

### 1. ドメインの追加

1. Amplifyコンソールでアプリを選択
2. 「Domain management」をクリック
3. 「Add domain」をクリック
4. ドメイン名を入力
5. 「Configure domain」をクリック

### 2. DNS設定

Amplifyが提供するDNSレコードを、ドメインレジストラで設定：

- **CNAMEレコード**: Amplifyが提供する値
- **Aレコード**: Amplifyが提供するIPアドレス（オプション）

### 3. SSL証明書

Amplifyが自動的にSSL証明書を発行・更新します（Let's Encrypt）

## 環境変数の管理

### 環境ごとの設定

Amplifyでは、環境（ブランチ）ごとに異なる環境変数を設定できます：

1. Amplifyコンソールでアプリを選択
2. 「Environment variables」をクリック
3. 環境を選択（例: `main`）
4. 環境変数を追加/編集

### 機密情報の管理

- 環境変数は暗号化されて保存されます
- ビルドログには表示されません（セキュリティのため）
- AWS Systems Manager Parameter Storeと統合可能

## ビルドログの確認

### リアルタイムログ

1. Amplifyコンソールでアプリを選択
2. 「Build history」をクリック
3. ビルドを選択
4. 「View logs」をクリック

### ログの内容

- 依存関係のインストール
- ビルドプロセス
- エラーメッセージ
- デプロイステータス

## トラブルシューティング

詳細なトラブルシューティングガイドは [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) を参照してください。

### ビルドログの確認方法

1. Amplifyコンソールでアプリを選択
2. 失敗したブランチ（例: `main`）をクリック
3. 「Build history」タブをクリック
4. 最新のビルドをクリック
5. 「View logs」をクリック

### よくあるエラーと解決方法

#### 1. 環境変数が設定されていない

**エラーメッセージ:**
```
Error: Cannot find environment variable: VITE_SUPABASE_URL
```

**解決方法:**
1. Amplifyコンソールでアプリを選択
2. 左側メニューの「App settings」→「Environment variables」をクリック
3. 必要な環境変数を追加（[環境変数の値の取得方法](#環境変数の値の取得方法)を参照）
4. 「Save」をクリック
5. 「Redeploy this version」をクリック

#### 2. TypeScriptの型エラー

**エラーメッセージ:**
```
error TS2304: Cannot find name 'xxx'
```

**解決方法:**
1. ローカルで型チェックを実行:
   ```bash
   npm run type-check
   ```
2. エラーを修正
3. コミットしてプッシュ:
   ```bash
   git add .
   git commit -m "Fix TypeScript errors"
   git push origin main
   ```

#### 3. ビルドコマンドのエラー

**解決方法:**
1. ローカルでビルドを実行:
   ```bash
   npm ci
   npm run build
   ```
2. エラーを修正
3. コミットしてプッシュ

詳細は [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) を参照してください。

### 環境変数が反映されない

**問題:** 環境変数がアプリで使用できない

**解決方法:**
1. 環境変数名が `VITE_` で始まっているか確認
2. ビルドを再実行（環境変数変更後は再ビルドが必要）
3. ブラウザのキャッシュをクリア

### デプロイが遅い

**問題:** デプロイに時間がかかる

**解決方法:**
1. `amplify.yml`でキャッシュを有効化（既に設定済み）
2. 不要な依存関係を削除
3. ビルド時間を最適化

### S3アップロードエラー

**問題:** 画像のアップロードが失敗する

**解決方法:**
1. AWS認証情報が正しいか確認
2. IAMポリシーで適切な権限が付与されているか確認
3. バケット名とリージョンが正しいか確認
4. CORS設定を確認（必要に応じて）

## コスト

### Amplifyホスティング

- **無料枠**: 月間15GBの転送、1000ビルド分
- **有料**: 使用量に応じた従量課金

詳細: [AWS Amplify Pricing](https://aws.amazon.com/amplify/pricing/)

### 推奨設定

- 開発環境: 無料枠内で運用可能
- 本番環境: トラフィックに応じてコストが発生

## 高度な設定

### リダイレクト設定

`amplify.yml`に追加：

```yaml
frontend:
  customHeaders:
    - pattern: '**/*'
      headers:
        - key: 'X-Frame-Options'
          value: 'DENY'
  redirects:
    - source: '/<*>'
      target: '/index.html'
      status: '200'
```

### キャッシュ設定

CloudFrontのキャッシュポリシーをカスタマイズ可能

### CI/CD統合

GitHub Actionsと併用可能（`.github/workflows/deploy.yml`参照）

## 参考リンク

- [AWS Amplify Documentation](https://docs.aws.amazon.com/amplify/)
- [Amplify Console User Guide](https://docs.aws.amazon.com/amplify/latest/userguide/welcome.html)
- [Amplify Build Settings](https://docs.aws.amazon.com/amplify/latest/userguide/build-settings.html)

## 次のステップ

1. Amplifyコンソールでアプリを作成
2. GitHubリポジトリを接続
3. 環境変数を設定
4. デプロイを実行
5. カスタムドメインを設定（オプション）

デプロイが完了したら、自動的に最新バージョンが反映されます！

