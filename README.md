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
rules/
  <効き方>-<名前>.md # 作業のしかたのきまり
```

`skills/<名前>/SKILL.md` などを足す場合も、
すべて `.claude-plugin/` の中ではなくリポジトリ直下に置く。

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
