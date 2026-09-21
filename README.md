# aerie

Claude Code プラグイン。リポジトリ直下がそのままプラグインルート。

## 構成

```
.claude-plugin/
  plugin.json       # プラグインのマニフェスト
  marketplace.json  # このリポジトリ自身を配布元にするための定義
hooks/
  hooks.json        # フックの設定
skills/
  <名前>/SKILL.md   # スキル
```

`skills/<名前>/SKILL.md` などを足す場合も、
すべて `.claude-plugin/` の中ではなくリポジトリ直下に置く。

## 段階

`sh skills/project-stage/scripts/stage.sh early` のように一度設定すると、
プロジェクト直下の `.aerie/stage.conf` に記録される。明示的な更新がない限り、
作業中は変えない。なければ `stable` とする。試作では長さ超過や危険な操作を
知らせるだけにし、互換性を作らない。安定化では既存の動きを保ち、運用では
利用者、データ、連携先を守る。方針はセッション開始と圧縮後に自動で注入する。

## 作業の流れ

変更作業では `task-loop` が目的、範囲、完了条件、実装物を正本にした検査を扱う。
最後に `sh skills/task-loop/scripts/close.sh` を実行する。説明や理解確認もこの流れに
含める。文章の方針は同梱の `always-clear-writing.md` で常に参照する。きまりの
重なりは `skills/rule-update/scripts/conflicts.sh` で見る。

ソース、試験、コメントを正本とし、内容を言い換えただけの設計書は作らない。

## 開発

```bash
claude --plugin-dir .        # インストールせずに読み込む
```

セッション中に編集したら `/reload-plugins` で反映。スキルは `/aerie:<名前>` と
名前空間付きで呼ぶ。

このリポジトリ直下で作業する場合、`.mcp.json` を置くと作業場所側の設定としても
読まれて `${CLAUDE_PLUGIN_ROOT}` が解けない。外から `--plugin-dir` で開くこと。

## 検証

```bash
claude plugin validate .
```

## インストール（配布）

```bash
claude plugin marketplace add owo-x-project/aerie
claude plugin install aerie@aerie
```
