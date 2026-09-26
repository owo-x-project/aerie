この repo は aerie
一つ入れるだけでハーネスの役割を果たすプラグイン

## ルール

- 造語を使わない
- \*\* \*\* など強調表現を使わない
- H1 ヘッダーは書かない
- 日本語の中で英語が使いたい場合はカタカナ英語にする
- 記録やメモは残さない
- 返答は手短かに簡潔にする
- 専門用語を使わない
- フックなどのスクリプトは POSIX sh と awk で書く
- スクリプトは hooks/ かスキルごとの scripts/ に置く

## 両方で使えるもの

- スキル `skills/<名前>/SKILL.md`
- フック `hooks/hooks.json`
- 目録 `.claude-plugin/plugin.json`
- 配布の一覧 `.claude-plugin/marketplace.json`

MCP は中身が同じで名前だけ違う。Claude は `.mcp.json`、Codex は `mcp.json`。

共通で使えるフックのきっかけは PreToolUse、PostToolUse、SessionStart、SessionEnd、
UserPromptSubmit、Stop、PreCompact、PostCompact。

中身はスキルとフックで組み立てる。

## Claude だけのもの

エージェント、コマンド、ワークフロー、出力スタイル、LSP、色テーマ、見張り、
実行ファイル置き場、初期設定、利用者ごとの設定。

利用者ごとの設定は `plugin.json` の `userConfig` に書くと入力画面が出る。値は
`CLAUDE_PLUGIN_OPTION_名前` にも入る。両方で動かすなら環境変数で受けとる形に寄せる。

## どちらでも使えないもの

- ルールはプラグインに入れられない。Claude はリポジトリの `.claude/rules`、Codex は `AGENTS.md`。
- MCP の画面つきの仕組みは端末に出ない。机上版や編集ソフト側だけ。
