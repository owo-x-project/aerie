---
name: rule-update
description: 作業のしかたのきまりを作る、書き直す、やめる。いつも守ってほしいこと、ある形のファイルを触るときだけのこと、ある道具を使うときだけのことを、決まった形のファイルにして残す。利用者が「これからはこうして」「今のやり方をきまりにして」と言ったときに使う。
---

## 置き場と名前

同梱のものはこのスキルの `assets/`、この案件のものは `.aerie/rules/` に入る。同じ名前なら
案件のほうが勝ち、違う名前なら足される。

名前は効き方で始める。

- `always-*.md` いつも効く
- `path-*.md` 合う形のファイルを触るときだけ効く
- `tool-*.md` その道具を使うときだけ効く

頭には `name` と `description` を持たせる。`description` は注入時の節名になるので、そのきまりが何を扱うかを短く一つだけ書く。`path` と `tool` には `match` も持たせる。

段階による安全策は `.aerie/stage.conf` で切り替える。きまりに段階別の例外を重ねず、段階が変わるときは設定を変える。

## 作る、書き直す

本文を流しこむ。頭の `name`、`description`、`match` は引数から自動で付くので書かない。

```sh
scripts/write.sh always reply-style '返答の形式' <<'RULE'
- 返答は短くする
RULE

scripts/write.sh path shell-script '*.sh' 'シェルの書き方' <<'RULE'
- bash だけの書きかたは使わない
RULE

scripts/write.sh tool commit commit 'コミットの作り方' <<'RULE'
- 一つの区切りに一つのことだけ入れる
RULE
```

書き直すときも同じ。show.sh で前の中身を読んでから、直した全文を流しこむ。

## やめる

```sh
scripts/drop.sh always reply-style
```

## 見る

```sh
scripts/list.sh
scripts/show.sh always reply-style
scripts/conflicts.sh
```

list.sh で今あるものを並べ、show.sh で中身を見る。新しく作る前に必ず見て、近いものがあればそれを書き直す。conflicts.sh で同じ範囲のきまりを確認する。

## 書きかたのきまり

- 箇条書きだけにする。見出しや説明の文章は入れない
- 一つのファイルに一つのことだけ入れる
- ほかのルールと重ならないようにする
- 守れたかどうかが見て分かることだけ書く
- その場の判断が要ることは書かない
- 短くする。長いと保存できない
- ソース、試験、コメントを正本とし、再説明の設計書を増やさない
