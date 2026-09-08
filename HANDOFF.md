# 三人目のAI向け引き継ぎ — portfolio-shell

最終整理: 2026-09-08 JST。担当: 二人目から三人目へ。
この文書は最新状態の要約。過去の試行は [作業履歴](docs/HANDOFF_HISTORY.md) に分離した。

## 0. 最初に知ること

- 3人の作品を紹介する静的ポートフォリオ。現在13作品・全13作品にデモ動画あり。
- PC・スマホ共通表示への改修、作品追加、提供動画4本の編集と組み込みは完了。
- 最新の実装コミットは `daaf850`。ローカル `master` に保存済み。初回pushは403で失敗したが、2026-09-08にAPIで **push権限あり** を確認。引き継ぎ資料と合わせて通常pushする。受領時にはGit履歴とremoteの一致を確認する。
- **STG・ブロックくずしの本体をこのPCへ導入しない。** 一人目のPCで正常動作済み。一人目がホストする公開URLを受け取り、リンクを差し替える方針。
- 本サイト自体は、このセッションではデプロイしていない。ローカル起動とGitHubへのpush、Web公開は別の状態として扱う。
- この資料と `.project-manager.json` もGit保存対象。実際の保存・送信状態は `git status` とremoteの最新コミットで確認する。

## 1. 読む順番と作業場所

1. この `HANDOFF.md`。
2. `index.html`（唯一の画面実装、作品データ、イベント処理）。
3. `demos/README.md`（録画の採用区間・変換条件）。
4. 必要に応じて `README.md`、`docs/architecture.json`、`docs/HANDOFF_HISTORY.md`。

| 項目 | 値 |
|---|---|
| リポジトリ | https://github.com/kura-masa/portfolio-shell |
| 二人目の作業場所 | `D:\開発\portfolio` |
| ブランチ | `master` |
| 二人目の開始コミット | `a5149aa` |
| 最新の実装コミット | `daaf850` — Improve responsive portfolio and add project demos |
| 確認時のremote追跡状態 | `origin/master` より1コミット先行（今後fetchして再確認） |
| 接続済みGitHubアカウント | `ninnzinn3bonn-creator`。初回pushは403。2026-09-08にAPIでpush権限ありを確認済み |
| ローカルURL | http://127.0.0.1:4173/ |
| 台帳ID | `portfolio-shell` |
| 台帳URL（このPC） | http://127.0.0.1:4170/#/project/portfolio-shell |

## 2. 確定事項 — 元に戻さないこと

- ヘッダーは「ポートフォリオ（仮）」でよい、という前任時点の決定を維持。
- PCは761px以上で左一覧＋右詳細、スマホは760px以下で選択メニュー＋詳細。長い一覧の下までスクロールさせる旧モバイル構成は廃止。
- クリック／タップは選択のみ。外部サイトはリンクボタンから開く。ホバー選択・2回目タップ即遷移には戻さない。
- 作品名・本文・ボタンは通常ゴシック。ブランドとカーソルだけ美咲ゴシックを8の倍数で使う。
- プレビュー枠は共通16:9、`object-fit: contain`で素材全体を表示。縦長ゲームの左右余白は意図したもの。
- ゲーム本体をプレビュー用iframeで先読みしない。選択中の動画だけ再生し、非選択は停止。
- タワーバトルは `https://human-stack-battle-game.pages.dev/` を使う。`human-stack-battle-20260715` は既存タワーバトルと同一作品なので重複追加しない。
- STG・ブロックくずしは制作クレジットなし。タワーバトルは「制作: 谷口」。ゲームのソースリンクは前任決定のmedaka333リポジトリを維持。
- 追加したGIJIRO・ゆるり・開発台帳の制作者は未指定。推測で付けない。
- 開発台帳はローカルアプリ。訪問者にlocalhostを案内せず、公開GitHubへリンクする。

## 3. 実装の見取り図

| 場所 | 役割 |
|---|---|
| `index.html` のstyle | レスポンシブ配置、書体、メディア枠 |
| `PRODUCTS` | 13作品のid・名前・説明・demo・poster・actions。リンク修正の主な編集箇所 |
| `buildList()` | PC一覧とスマホselectを同じデータで生成 |
| `buildStack()` | 動画要素と動画エラー時の静止画／SVG代替 |
| `render()` | 選択・詳細・件数を同期、動画再生／停止、段落・リンク生成 |
| `selectProduct()` / `move()` | 選択と前後循環、一覧のフォーカス移動 |
| `preview.html` | index.htmlへの転送専用。別のUI実装ではない |
| `demos/` | 既存WebM9本＋編集MP4 4本 |
| `previews/` | 追加4作品の代替JPEG |
| `sync-games.sh` | 前任の自前ゲーム配置用スクリプト。現在の担当作業には不要 |

専用バックエンド・DB・npmビルド・テストランナーはない。作品の外部アプリは別プロジェクト。

## 4. 次の作業 — 優先順と完了条件

| 優先 | 作業 | 現状／完了条件 |
|---|---|---|
| 1 | 最新状態を三人目へ渡す | daaf850と引き継ぎ文書の両方を受け取る。書き込み権限は確認済み。fetchしてremoteと最新コミットが一致することを確認。force push不要 |
| 2 | STG・ブロックくずしのURL差し替え | 一人目の公開URL待ち。PRODUCTSの `./games/stg/index.html` / `./games/breakout/index.html` を受領URLへ変更しブラウザで確認 |
| 3 | ソースリンク4件の404対応 | 下表参照。非公開・削除・移転は未確定。公開URLの確認またはソースボタン非表示の方針を決めてから修正 |
| 4 | 公開前確認 | スマホ実機、最終掲載内容・クレジット、本サイトのホスティング先と配信を確認。未確認を完了扱いしない |

未認証HTTP GETで404だったソースリンク（2026-09-07確認、まだ修正していない）:

| 作品 | URL |
|---|---|
| LOCA AIチャットボット | https://github.com/kura-masa/loca-the-junpu-ai-chatbot |
| 旅館ダッシュボード | https://github.com/kura-masa/junpu-dashboard |
| 保険営業支援 | https://github.com/kura-masa/bird_hoken_app |
| Ideas & Knowledges | https://github.com/kura-masa/IdeasAndKnowledgesArticle |

## 5. 起動・最小検証

PowerShellでプロジェクトルートから実行。既存の4173サーバーがある場合は再起動不要。別PCではパスを読み替える。

```powershell
Set-Location -LiteralPath 'D:\開発\portfolio'
git status --short --branch
git log -3 --oneline
python -m http.server 4173 --bind 127.0.0.1
```

http://127.0.0.1:4173/ を開く。静的HTMLなので編集後はブラウザ再読み込みが必要。
`file://`ではなくHTTP経由で確認する。起動済みサーバーが次セッションにも生きているとは仮定しない。

表示変更後の最小確認:

- PCと390px幅で作品を選び、タイトル・リンク・映像が一致する。
- 長いタイトル、縦長タワーバトル、最後の作品から先頭への前後移動を確認。
- 一覧内の矢印・Home/End、Tab移動とボタンのEnterを確認。
- 動画がミュート・ループで再生し、非表示動画が停止する。
- `git diff --check`。JavaScript変更時はscript部分の構文も検査。

## 6. 実施済み検証と限界

- 10作品の時点で320 / 390 / 760 / 768 / 1024 / 1440px × 全作品を確認。横はみ出しなし、選択の同期と一覧行の高さを確認。
- 追加後は指定4作品をPCと390px幅で確認（全13作品を6幅で再テストしたわけではない）。
- 提供動画4本は全デコード、寸法・長さ・音声なしを確認。サイトでもPCと390px幅でreadyState=4、paused=false、横はみ出しなし。
- 全22リンク先を重複除去してHTTP GET: 16件200、既知のゲームローカルリンク2件404、上記GitHub4件404。
- 外部アプリ10件はHTTP 200。旅館ダッシュボードは/loginへ移動。全アプリの内部機能を試したわけではない。
- スマホ実機のSafari/Chrome、公開環境での配信、元からあった9本の動画内容の全編精査は未検証。
- 2026-09-08の保存前にJS構文とdiff検査が成功。最新コードの変更があれば再検証する。

## 7. 動画・原本の扱い

| 作品 | 配信用ファイル | 尺 |
|---|---|---|
| タワーバトル | `demos/human-stack-battle-20260715.mp4` | 17秒 |
| GIJIRO | `demos/gijiro-winwinreco.mp4` | 21.5秒 |
| 台帳 | `demos/local-project-register.mp4` | 20.2秒 |
| ゆるり | `demos/yururi-landing-page.mp4` | 19.5秒 |

4本合計約2.8MB、無音H.264。代替画像はpreviewsの同名JPEG。
原本 `GIJIRO.mp4` / `PJ.mp4` / `たわーばとる.mp4` / `ゆるりLP.mp4` と `.work-video/` はGit対象外で、このPCに保持。
**別PCへcloneしても原本・中間ファイルは来ない。** 再編集が必要な場合だけユーザーから受け取る。通常のサイト起動には配信版だけでよい。

## 8. 台帳と概念図

- 台帳 `portfolio-shell` を新規登録済み。状態 `testing`、進捗85%。これは二人目の評価であり、公開済みという意味ではない。
- 概念図は適用済み、5グループ・7コンポーネント・6エッジ・1フロー。2026-09-08にAPIでready / hasValidDocument=trueを再確認。
- [.project-manager.json](.project-manager.json) は登録ランナーが生成したローカル台帳への関連付け。Git保存対象。
- [docs/architecture.json](docs/architecture.json) は適用した概念図JSONのコピー。別PCでも構成を読める。
- localhost:4170はこのPCの台帳。別PCの台帳に同じレコードがあるとは仮定しない。
- 台帳データファイルを直接編集せず、利用可能な台帳スキル／正規ランナーで更新する。

## 9. セッション限定の取り決め

ユーザーは **二人目のこのセッションだけ** サブエージェントを使わず単体で作業するよう指定した。
この制約はリポジトリ全体や三人目の別セッションへ自動適用しない。AGENTS.md等へ恒久ルールとして追加していない。

## 10. 読み違えやすい過去情報

- 「ゲーム本体をローカル導入する」→撤回済み。公開URL受領待ち。
- 「10作品」「動画9本」「追加4本は未収録」→現在は13作品・動画13本。
- 「preview.htmlは用途不明の別版」→現在は本体への転送。
- 「全画面ドット書体」「タップ2回で外部へ遷移」→共通UI改修で変更済み。
- 「全変更が未コミット」→実装はdaaf850にコミット済み。初回push失敗後に権限付与を確認済み。送信状況はGitで確認。

## 権限付与の確認（2026-09-08）

GitHub APIで現在のアカウントにpull=true / push=trueを確認。資料の過去ログには初回403の経緯を残す。台帳の85%・概念図は登録時点の状態で、台帳側の権限不足課題はまだ更新していない。
