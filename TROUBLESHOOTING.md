# デプロイ失敗のトラブルシューティング

このドキュメントでは、AWS Amplifyでのデプロイ失敗の原因と解決方法を説明します。

## ビルドログの確認方法

1. Amplifyコンソールでアプリを選択
2. 左側メニューの「Hosting」→「Branches」をクリック
3. 失敗したブランチ（例: `main`）をクリック
4. 「Build history」タブをクリック
5. 最新のビルドをクリック
6. 「View logs」をクリックしてログを確認

## よくあるエラーと解決方法

### 1. 環境変数が設定されていない

**エラーメッセージ:**
```
Error: Cannot find environment variable: VITE_SUPABASE_URL
```

**解決方法:**
1. Amplifyコンソールでアプリを選択
2. 左側メニューの「App settings」→「Environment variables」をクリック
3. 必要な環境変数を追加:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
   - `VITE_AWS_REGION`
   - `VITE_AWS_ACCESS_KEY_ID`
   - `VITE_AWS_SECRET_ACCESS_KEY`
   - `VITE_AWS_S3_BUCKET_NAME`
4. 「Save」をクリック
5. 「Redeploy this version」をクリックして再デプロイ

### 2. ビルドコマンドのエラー

**エラーメッセージ:**
```
npm ERR! code ELIFECYCLE
npm ERR! errno 1
```

**解決方法:**
1. ビルドログを確認してエラーの詳細を確認
2. ローカルで以下を実行してエラーを再現:
   ```bash
   npm ci
   npm run build
   ```
3. エラーを修正
4. コミットしてプッシュ:
   ```bash
   git add .
   git commit -m "Fix build error"
   git push origin main
   ```

### 3. TypeScriptの型エラー

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
3. コミットしてプッシュ

### 4. 依存関係のインストールエラー

**エラーメッセージ:**
```
npm ERR! peer dep missing
```

**解決方法:**
1. `package.json`の依存関係を確認
2. 不足している依存関係を追加:
   ```bash
   npm install <package-name>
   ```
3. `package-lock.json`を更新
4. コミットしてプッシュ

### 5. ビルドタイムアウト

**エラーメッセージ:**
```
Build timeout after 30 minutes
```

**解決方法:**
1. `amplify.yml`でビルド時間を最適化
2. 不要な依存関係を削除
3. ビルドキャッシュを有効化（既に設定済み）

### 6. ファイルサイズ制限

**エラーメッセージ:**
```
File size exceeds limit
```

**解決方法:**
1. 大きなファイルを削除または圧縮
2. `.gitignore`で不要なファイルを除外
3. `node_modules`がコミットされていないか確認

## デプロイ前のチェックリスト

デプロイ前に以下を確認してください:

- [ ] ローカルで `npm run build` が成功する
- [ ] すべての環境変数がAmplifyに設定されている
- [ ] `amplify.yml`の設定が正しい
- [ ] TypeScriptのエラーがない（`npm run type-check`）
- [ ] 依存関係が正しくインストールされる（`npm ci`）

## 再デプロイの方法

### 方法1: 自動再デプロイ（推奨）

1. コードを修正
2. コミットしてプッシュ:
   ```bash
   git add .
   git commit -m "Fix deployment issue"
   git push origin main
   ```
3. Amplifyが自動的に再デプロイを開始

### 方法2: 手動再デプロイ

1. Amplifyコンソールでアプリを選択
2. 失敗したブランチをクリック
3. 「Redeploy this version」をクリック

### 方法3: 環境変数を変更した場合

1. 環境変数を更新
2. 「Save」をクリック
3. 「Redeploy this version」をクリック

## ビルドログの見方

### 重要なセクション

1. **preBuild**: 依存関係のインストール
2. **build**: アプリケーションのビルド
3. **postBuild**: ビルド後の処理（オプション）

### エラーの見つけ方

1. ログ内で「ERROR」や「FAILED」を検索
2. エラーメッセージの前後を確認
3. スタックトレースを確認

## よくある質問

### Q: 環境変数を変更したのに反映されない

A: 環境変数を変更した後は、再デプロイが必要です。「Redeploy this version」をクリックしてください。

### Q: ローカルでは動くのにAmplifyで失敗する

A: 環境変数が正しく設定されているか確認してください。また、ビルドログを確認してエラーの詳細を確認してください。

### Q: ビルドが遅い

A: `amplify.yml`でキャッシュを有効化しています。初回ビルドは時間がかかりますが、2回目以降はキャッシュが使用されます。

## サポート

問題が解決しない場合:

1. ビルドログを確認
2. ローカルでエラーを再現
3. GitHubのIssuesで報告

