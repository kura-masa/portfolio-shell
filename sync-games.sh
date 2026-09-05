#!/bin/bash
# ゲームのビルド成果物を games/ に集める。
# festival-kiosk の sync-games.sh を、ポートフォリオ用に作り直したもの。
#
# 使い方: ./sync-games.sh [famicongameのパス] [animalVSのパス]
# 省略時は ../<名前> → ~/dev/<名前> の順で自動検出する。
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
DEST="$HERE/games"
mkdir -p "$DEST"

pick() {  # $1=引数 $2=リポジトリ名 $3=存在確認するパス
  if [ -n "${1:-}" ]; then echo "$1"; return; fi
  for base in "$HERE/../$2" "$HOME/dev/$2"; do
    [ -e "$base/$3" ] && { echo "$base"; return; }
  done
  echo "$HERE/../$2"
}

FAMICONGAME="$(pick "${1:-}" famicongame web/stg/index.html)"
ANIMALVS="$(pick "${2:-}" animalVS apps/game)"

echo "famicongame: $FAMICONGAME"
echo "animalVS   : $ANIMALVS"
echo

# --- famicongame（STG・ブロック崩し） -----------------------------------------
# Web版のビルドがリポジトリにコミットされているので、clone すればそのまま入っている。
# ビルドし直す必要はない（Godotエディタからエクスポートし直したときだけ）。
for g in stg breakout; do
  if [ ! -f "$FAMICONGAME/web/$g/index.html" ]; then
    echo "[警告] $FAMICONGAME/web/$g/index.html が見つかりません。"
    echo "       git clone https://github.com/medaka333/famicongame.git してください。"
  else
    echo "$g を同期中..."
    rsync -a --delete "$FAMICONGAME/web/$g/" "$DEST/$g/"
  fi
done

# --- animalVS（タワーバトル） -------------------------------------------------
# ⚠️ こちらはビルドが要る。しかも Vite は既定で /assets/... という絶対パスを吐くので、
#    そのまま置くと games/tower/ の下から読めず黒画面になる。
#    どこに置いても動くよう、ベースを相対にしてビルドすること:
#      npx vite build --config apps/game/vite.config.ts --base=./
#    ここでは成果物を検査して、絶対パスのままなら止める（黙って壊れた物を配らない）。
TOWER_DIST="$ANIMALVS/apps/game/dist"
if [ ! -f "$TOWER_DIST/index.html" ]; then
  echo "[未対応] タワーバトルのビルドが見つかりません: $TOWER_DIST"
  echo "         animalVS 側で次を実行してください:"
  echo "           npx vite build --config apps/game/vite.config.ts --base=./"
elif grep -qE '(src|href)="/games/tower/' "$TOWER_DIST/index.html"; then
  echo "tower を同期中... [注意] このビルドは /games/tower/ 直下でしか動きません"
  echo "         （サイトをサブディレクトリで配信するなら --base=./ で作り直すこと）"
  rsync -a --delete "$TOWER_DIST/" "$DEST/tower/"
elif grep -qE '(src|href)="/' "$TOWER_DIST/index.html"; then
  echo "[エラー] タワーバトルのビルドが、置き場所と合わない絶対パスで作られています。"
  echo "         そのまま配ると assets が読めず黒画面になるため、同期を中止します。"
  echo "         次のように作り直してください:"
  echo "           npx vite build --config apps/game/vite.config.ts --base=./"
else
  echo "tower を同期中..."
  rsync -a --delete "$TOWER_DIST/" "$DEST/tower/"
fi

echo
echo "同期完了。"
