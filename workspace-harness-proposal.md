# Workspace Harness 企画書

## 1. 概要

### 1.1 名称

**Workspace Harness**

Workspace Harness は、複数の独立したソフトウェアプロジェクトをひとつのワークスペースで扱いながら、AI CLI に共通の開発能力・認知機能・作業管理・正本アクセスを提供するための開発基盤である。

Workspace Harness 自体が新しいAIエージェントやオーケストレータになることは目的としない。

既存の成熟したツールを組み合わせ、Codex / Claude Code などのAI CLIを唯一の実行主体として利用する。

---

## 2. 背景

AI駆動開発では、プロジェクトごとに以下の情報や設定が分散しやすい。

- AI向けinstructions
- Skills
- MCP
- CLIツール
- Project固有の正本
- 作業中のTask
- 過去の経験や判断
- Context最適化設定
- 開発環境
- Git repository

複数プロジェクトを並行して扱うと、さらに以下の問題が発生する。

- Project Aの知識がProject Bへ混入する
- global設定が増え、環境の再現性が失われる
- AIが大量のログ・コード・履歴を読みすぎる
- 長い作業で現在地を失う
- 過去の失敗を何度も繰り返す
- TaskとProjectの本来の目的が乖離する
- 人間が「何を覚えておくべきか」を背負う
- AI CLIごとにSkillsやMCP設定を二重管理する
- 導入ツールが増えるほど管理ツールそのものの保守が必要になる

Workspace Harness はこれらを、独自の管理ランタイムを作らずに解決する。

---

## 3. 目的

Workspace Harness の目的は、次の状態を実現することである。

> **複数の独立したProjectをひとつのWorkspaceから扱いながら、AIが現在のProjectだけに集中し、必要な正本・Task・経験・Contextへ最小コストで到達できる開発環境を提供する。**

Workspace Harness は以下を重視する。

1. **既存ツールの最大活用**
2. **Project間の独立性**
3. **global環境の最小化**
4. **AI CLI中心**
5. **人間とAIを信頼した運用**
6. **少ないContext消費**
7. **長時間・複数Sessionにまたがる継続性**
8. **人間の認知負荷削減**
9. **経験からの継続的な成長**
10. **ツールの追加・削除容易性**
11. **チーム共有の容易さ**
12. **正本と派生知識の厳密な分離**

---

## 4. 非目標

Workspace Harness では以下を作らない。

- 独自AI Agent Runtime
- 独自Agent Orchestrator
- 独自Task Manager
- 独自Memory Database
- 独自Context Engine
- 独自Skill Format
- 独自MCP Protocol
- 独自Multi-repo Manager
- 独自Environment Manager
- 独自Permission System
- 独自Workspace CLI
- Project固有toolchainの統一強制

Workspace Harnessは「新しい巨大ツール」ではなく、**既存ツールのComposition Root** とする。

---

# 5. 設計思想

## 5.1 WorkspaceはComposition Root

WorkspaceはProjectの中身を所有しない。

Workspaceが所有するものは以下のみとする。

- 共通AI能力
- 共通AI設定
- Workspace共通CLI
- Multi-repo一覧
- Workspaceレベルの運用規範

Project固有の正本、ソースコード、開発環境、verificationはProject自身が所有する。

## 5.2 ProjectはSovereignty Root

各Projectは独立したGit repositoryとする。

Projectは最低限、以下を自身で決定できる。

- 開発言語
- runtime
- compiler
- build system
- test
- verification
- Project固有AI instructions
- Project固有Skills
- Owlspec version
- Nix / Flox / mise などの環境方式

WorkspaceはProject固有環境へ介入しない。

## 5.3 AI CLIを唯一の実行主体とする

Workspace Harness自身はAI Workerを持たない。

以下のAI CLIが直接作業する。

- Codex
- Claude Code
- 将来的なAgent Skills対応CLI

LeanCTX、Beads、OwlspecなどはAIの補助能力として利用する。

---

# 6. 最終アーキテクチャ

```text
                       ┌─────────────────────┐
                       │       Owlspec       │
                       │ Canonical Truth     │
                       │ Intent / Constraint │
                       │ Decision / Evidence │
                       └──────────┬──────────┘
                                  │
                                  ▼
                       ┌─────────────────────┐
                       │        Beads        │
                       │    Current Work     │
                       │ Task / Dependency   │
                       │ Ready / Blocked     │
                       └──────────┬──────────┘
                                  │
                                  ▼
                       ┌─────────────────────┐
                       │      LeanCTX        │
                       │     Cognition       │
                       │ Context / Memory    │
                       │ Search / Attention  │
                       └──────────┬──────────┘
                                  │
                                  ▼
                       ┌─────────────────────┐
                       │ Codex / Claude Code │
                       │ Reasoning / Action  │
                       └──────────┬──────────┘
                                  │
                                  ▼
                       ┌─────────────────────┐
                       │   Verification      │
                       │ Tests / Proofs      │
                       │ Owlspec Evidence    │
                       └─────────────────────┘

     ┌───────────────────────────────────────────────────────┐
     │                Workspace Infrastructure               │
     │                                                       │
     │  Flox      APM        vcs2l        Git               │
     │  Tools     AI deps    Repositories History/Sharing   │
     └───────────────────────────────────────────────────────┘
```

---

# 7. 採用スタック

| 責務 | 採用技術 |
|---|---|
| Workspace共通CLI環境 | Flox |
| Project固有環境 | Project自身が選択 |
| Multi-repo管理 | vcs2l |
| AI設定・依存管理 | Microsoft APM |
| AI Skill標準 | Agent Skills |
| Context Engine | LeanCTX |
| 短期記憶 | LeanCTX |
| 長期経験・Knowledge | LeanCTX |
| Code graph / Context探索 | LeanCTX |
| Task管理 | Beads |
| Canonical Truth | Owlspec |
| Verification | Project tests / proofs / Owlspec |
| Repository履歴 | Git |
| AI実行主体 | Codex / Claude Code |

---

# 8. Workspace共通環境

Workspace rootにFlox environmentを配置する。

```text
workspace/
├── .flox/
├── apm.yml
├── apm.lock.yaml
├── workspace.repos
├── AGENTS.md
└── projects/
```

Flox environmentには **Workspace Harness専用のバイナリだけ** を含める。

例:

```text
lean-ctx
bd
apm
vcs
codex
claude
```

原則として以下はWorkspace環境へ入れない。

```text
rust
node
python
java
postgres
clang
project-specific compiler
```

これらはProject固有環境が所有する。

---

# 9. Environment Layering

利用時はWorkspace Harness環境を最初にactivateする。

```bash
flox activate
```

その後Projectへ移動する。

```bash
cd projects/owlspec
nix develop
```

概念上は次の構造になる。

```text
OS
 │
 ▼
Workspace Flox
 │
 │ lean-ctx
 │ bd
 │ apm
 │ vcs
 │ codex
 │ claude
 │
 ▼
Project Environment
 │
 │ rust
 │ cargo
 │ verus
 │ project-specific tools
 │
 ▼
AI CLI
```

ProjectがFloxを利用している場合はFlox Compositionも利用可能とする。

ProjectがNix、mise、devcontainer等を利用していてもWorkspace Harnessは制限しない。

---

# 10. Multi-repo管理

Multi-repo管理には `vcs2l` を利用する。

Workspaceにはrepository一覧だけを保持する。

```yaml
repositories:
  owlspec:
    type: git
    url: git@github.com:owo-x-project/owlspec.git
    version: develop

  project-a:
    type: git
    url: git@github.com:example/project-a.git
    version: main
```

Workspaceはrepositoryの取得・一覧・横断操作を提供するが、各repositoryの日常的なbranch管理には介入しない。

Git worktreeは各Project内部での並行作業用途として利用する。

```text
Workspace
 └ Project A
      ├ main checkout
      ├ feature-a worktree
      └ feature-b worktree
```

---

# 11. AI設定管理

AI向け設定の唯一の所有者を **APM** とする。

APMが管理するもの:

- instructions
- Agent Skills
- MCP declarations
- hooks
- Codex設定
- Claude Code設定
- dependency version
- lockfile

LeanCTXやBeads自身のsetup commandにAI設定を書かせない。

原則:

> **AGENTS.md / CLAUDE.md / MCP / Skillsを書き換えてよいのはAPMだけ。**

これにより複数ツールが同一設定ファイルを奪い合う状態を防ぐ。

---

# 12. LeanCTX

LeanCTXをWorkspace Harnessの **Cognition Layer** として扱う。

## 12.1 責務

LeanCTXは以下を担当する。

- Context消費最適化
- shell output圧縮
- code retrieval
- code graph
- impact analysis
- short-term session memory
- long-term knowledge
- past findings
- decisions
- negative knowledge
- Context Budget
- relevance ranking
- task-aware context selection
- session continuation
- handoff
- multi-repo context
- attention control
- context prefetch
- repeated-read削減

LeanCTXは「正本」ではない。

## 12.2 Headless運用

LeanCTX自身にはAI設定を書かせない。

APMからstdio MCPとして起動する。

```text
APM
 └ LeanCTX MCP
      └ Cognition Runtime
```

LeanCTXのrule injection、CLAUDE.md変更、hook自動設定等は利用しない。

## 12.3 Project Isolation

Project directoryからAI CLIを起動した場合:

```text
projects/project-a
        ↓
LeanCTX Project A Context
```

Workspace rootから起動した場合:

```text
workspace
   ↓
LeanCTX Multi-repo Context
```

原則として通常作業はProject rootから開始する。

Workspace rootからの横断Contextは、本当に複数Projectを扱うTaskだけで利用する。

## 12.4 Authority

LeanCTXが保存する情報はすべてderived knowledgeとする。

優先順位:

```text
Owlspec / Source / Verification
            >
LeanCTX Knowledge
            >
Past Session
```

LeanCTXのKnowledgeがOwlspecと矛盾した場合はOwlspecを優先する。

---

# 13. Beads

Beadsは **Work Layer** として利用する。

## 13.1 責務

Beadsが担当するもの:

- Goalに紐づくTask
- Subtask
- dependency
- blocked state
- ready state
- priority
- current work
- deferred work
- scope外で発見したTask

AIが作業中に本筋から外れる改善点を発見した場合、その場で実装せずBeadとして記録する。

これにより、

> 忘れないが、脱線もしない

状態を作る。

## 13.2 BeadsをMemoryとして使わない

以下はLeanCTXへ任せる。

- past experience
- findings
- decisions
- session memory
- learned knowledge

BeadsはWorkだけを担当する。

---

# 14. Owlspec

Owlspecは **Canonical Truth Layer** とする。

## 14.1 Authority

Project内の以下をOwlspecが扱う。

- outcome
- constraint
- decision
- design
- verification
- evidence
- fact

Owlspec管理下のProjectでは、

```text
owlspec context
```

を正本へのread surfaceとする。

書き込みは、

```text
owlspec change
```

を利用する。

## 14.2 LeanCTXとの関係

```text
Owlspec
   = What is true

Beads
   = What are we doing now

LeanCTX
   = What have we seen / learned / need now
```

この責務を混ぜない。

LeanCTXがOwlspecの出力内容を意味的に変更しないよう、必要に応じてOwlspec commandをLeanCTXのshell compression対象外にする。

---

# 15. AIの認知アーキテクチャ

Workspace Harnessは、AI開発を以下の認知ループとして扱う。

```text
Canonical Truth
      │
      ▼
Current Goal
      │
      ▼
Current Task
      │
      ▼
Relevant Context
      │
      ▼
Reasoning
      │
      ▼
Action
      │
      ▼
Verification
      │
      ▼
Experience
      │
      ▼
Knowledge
      │
      └─────→ 次回のRelevant Context
```

対応ツール:

```text
Canonical Truth → Owlspec
Current Work     → Beads
Context          → LeanCTX
Reasoning        → Codex / Claude Code
Verification     → tests / proofs / Owlspec
Experience       → LeanCTX
Knowledge        → LeanCTX
```

---

# 16. 成長モデル

Workspace HarnessはAIが勝手に正本を書き換える自己学習システムにはしない。

Knowledge maturityを段階化する。

```text
Observation
    ↓
Session Finding
    ↓
Repeated Experience
    ↓
LeanCTX Knowledge
    ↓
Human / AI review
    ↓
Stable Practice
    ↓
Skill / Instruction / Owlspec
```

つまり、

- 生の経験 → LeanCTX
- 現在の仕事 → Beads
- 安定した手順 → Agent Skill
- 正式なProjectの真実 → Owlspec

とする。

---

# 17. Context最適化

AIは原則として「全部読む」のではなく、LeanCTXを通して必要な情報だけ取得する。

例:

```text
Task
 ↓
LeanCTX relevance selection
 ↓
Code signatures
 ↓
必要なsymbol
 ↓
必要なlines
```

巨大command outputも可能な限りLeanCTX経由で縮約する。

ただし以下はrawを優先する。

- machine-readable output
- 正確なbyte/line formatが必要な診断
- Owlspec CLIのcanonical response
- Beadsの状態更新結果
- 小さなoutput

---

# 18. 人間の認知負荷削減

人間が以下を記憶し続ける必要をなくす。

- 今何をしていたか
- 次に何をするか
- 何にblockedされているか
- 以前何を試したか
- なぜその判断をしたか
- どのfileを見たか
- どのProjectに何があるか
- どのTaskが本筋から外れたか

責務:

```text
現在地      → Beads
経験        → LeanCTX
正式判断    → Owlspec
履歴        → Git
```

---

# 19. 脱線防止

AIが現在のTask外の改善点を発見した場合:

```text
Discovery
   │
   ├ Current Taskに必要
   │      ↓
   │    続行
   │
   └ Scope外
          ↓
       Bead作成
          ↓
       Current Taskへ戻る
```

「気づいたから今やる」を避ける。

---

# 20. 矛盾の扱い

情報のAuthority Orderを固定する。

```text
1. Canonical Truth
2. Source / Proof / Verification
3. Current Work
4. LeanCTX Knowledge
5. Session History
```

矛盾を発見した場合、AIが便利な方を選んではならない。

例:

```text
Owlspec:
Session Cookieを使う

LeanCTX:
以前JWTで実装した

↓

Driftとして報告
```

LeanCTXの過去Knowledgeを正本へ自動昇格しない。

---

# 21. Team共有

共有対象を2種類に分ける。

## Git共有

必ず共有するもの:

- Workspace repository
- `.flox/`
- `apm.yml`
- `apm.lock.yaml`
- `workspace.repos`
- AGENTS / generated harness files
- Skills
- Owlspec records
- Beadsの共有対象データ

## Local中心

原則localにするもの:

- LeanCTX session state
- temporary context
- raw experience cache
- local indexes

成熟したKnowledgeのみ、Skill / Owlspec / instructionへ昇格してGit共有する。

---

# 22. 想定Workspace構造

```text
workspace/
├── .flox/
│   └── Workspace Harness binaries
│
├── .state/
│   └── lean-ctx/
│
├── .gitignore
│
├── apm.yml
├── apm.lock.yaml
├── workspace.repos
├── AGENTS.md
│
└── projects/
    ├── owlspec/
    │   ├── .git/
    │   ├── flake.nix
    │   ├── .owlspec/
    │   ├── apm.yml
    │   └── ...
    │
    ├── project-a/
    │   ├── .git/
    │   ├── mise.toml
    │   └── ...
    │
    └── project-b/
        ├── .git/
        ├── .flox/
        └── ...
```

---

# 23. 通常の利用イメージ

Workspaceへ入る。

```bash
cd workspace
flox activate
```

Projectを選ぶ。

```bash
cd projects/owlspec
```

Project環境へ入る。

```bash
nix develop
```

AI CLIを起動する。

```bash
codex
```

AIは以下を利用する。

```text
Owlspec → canonical truth
Beads   → current task
LeanCTX → relevant context / experience
APM     → skills / instructions / MCP
```

---

# 24. Workspace横断作業

複数Projectを扱う必要がある場合のみWorkspace rootからAI CLIを起動する。

```bash
cd workspace
codex
```

この場合LeanCTXのmulti-repo能力を利用する。

例:

- Owlspecの変更が複数consumerへ与える影響調査
- 共通library変更
- repository横断migration
- Workspace Harness自身の改善

Project単独TaskではWorkspace-wide contextを使わない。

---

# 25. ツール追加・削除

新しいツールを追加する場合、責務を1つだけ割り当てる。

採用条件:

1. 既存ツールで代替できないか
2. 既存責務と重複しないか
3. Project isolationを壊さないか
4. global stateを要求しないか
5. APM/Floxから管理可能か
6. Context surfaceを不必要に増やさないか
7. 削除してもProjectの正本が失われないか

削除時にProjectのcanonical dataが失われるツールは採用しない。

---

# 26. セキュリティと権限

複雑なPermission Layerは構築しない。

基本思想:

> 人間とAIを信頼し、誤操作を防ぐための構造とVerificationを重視する。

Project isolationはsandboxによる強制ではなく、以下で実現する。

- Project root
- cwd
- repository境界
- LeanCTX project identity
- Project-local Beads
- Project-local Owlspec
- APM instructions

必要以上のdeny ruleやapproval flowは追加しない。

---

# 27. 成功条件

Workspace Harnessが成功している状態は以下。

## 導入

- 新しいWorkspaceを短時間で再現できる
- global installがほぼ不要
- Project既存環境を変更せず導入できる

## AI

- AI CLIを直接利用できる
- Project A作業時にProject BのKnowledgeを不用意に参照しない
- 長いsessionでも現在Taskを失わない
- sessionを跨いでも作業を再開できる
- 過去の失敗を再利用できる
- 大量outputによるContext浪費が減る

## 人間

- Taskを頭で保持する必要が減る
- 作業の現在地が明確
- scope外の改善点を忘れず保留できる
- Projectの「何が正しいか」を迷わない

## 保守

- Harness独自コードがほぼ存在しない
- 各toolを単独で交換できる
- AI CLIを交換してもProject正本が残る
- LeanCTXを削除してもProjectのTruthが残る
- Beadsを削除してもProjectのTruthが残る
- APMを交換してもProjectのTruthが残る

---

# 28. 最重要原則

Workspace Harnessでは、次の境界を崩さない。

```text
Owlspec = Truth
Beads   = Work
LeanCTX = Cognition
AI CLI  = Reasoning / Action
APM     = AI Capabilities
Flox    = Workspace Tool Environment
vcs2l   = Repository Composition
Git     = History / Sharing
```

どのツールにも、自分の責務以上のAuthorityを持たせない。

---

# 29. まとめ

Workspace Harnessは、新しい巨大な開発プラットフォームではない。

複数のProjectをまたいで共通利用できる、

> **AI CLIのための再現可能な認知・作業・正本アクセス基盤**

である。

中心となる構造は以下。

```text
Truth     → Owlspec
Work      → Beads
Cognition → LeanCTX
Action    → Codex / Claude Code
```

その周囲を、

```text
AI dependencies → APM
Workspace tools → Flox
Repositories    → vcs2l
History         → Git
```

で支える。

独自ランタイムを作らず、それぞれの分野で強い既存ツールをCompositionすることで、

- シンプル
- 強力
- Project独立
- AI CLI非依存
- 長期運用可能
- 自己成長可能
- Context効率が高い
- チーム共有しやすい

Workspace Harnessを実現する。
