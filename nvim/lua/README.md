# Neovim Lua 設定

このディレクトリには Neovim の Lua 設定ファイルが含まれています。

## ディレクトリ構成

```
lua/
├── README.md           # このファイル
├── core/               # コア設定（プラグインに依存しない基本設定）
│   ├── autocmds.lua    # 自動コマンド（ファイルタイプ別の設定など）
│   ├── base.lua        # 基本設定
│   ├── keymaps.lua     # キーマップ設定
│   └── options.lua     # Vim オプション設定
└── plugins/            # プラグイン設定（lazy.nvim で管理）
    ├── colorscheme.lua # カラースキーム (iceberg)
    ├── lualine.lua     # ステータスライン
    ├── toggleterm.lua  # フローティングターミナル
    ├── claudecode.lua  # Claude Code 連携
    ├── oil.lua         # ファイラー
    ├── telescope.lua   # ファジーファインダー
    ├── comment.lua     # コメントトグル
    ├── treesitter.lua  # シンタックスハイライト
    ├── lsp.lua         # LSP サポート
    ├── cmp.lua         # 自動補完
    ├── gitsigns.lua    # Git 変更表示
    ├── indent-blankline.lua  # インデントガイド
    ├── hop.lua         # モーションジャンプ
    ├── markview.lua    # Markdown インエディタプレビュー
    ├── markdown-preview.lua  # Markdown ブラウザプレビュー
    └── loam.lua        # Zettelkasten ノート管理（開発中）
```

## プラグイン一覧

### 見た目・UI

| プラグイン | 説明 | 遅延読み込み |
|-----------|------|-------------|
| [iceberg.vim](https://github.com/cocopon/iceberg.vim) | 青を基調としたダークカラースキーム | ❌ (即時) |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | 高機能ステータスライン | VeryLazy |
| [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) | インデントガイド表示 | BufRead |

### エディタ機能

| プラグイン | 説明 | 遅延読み込み |
|-----------|------|-------------|
| [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | フローティングターミナル | `<C-\>` キー |
| [oil.nvim](https://github.com/stevearc/oil.nvim) | バッファ編集式ファイラー | `-` キー |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | ファジーファインダー | `<leader>f*` キー |
| [Comment.nvim](https://github.com/numToStr/Comment.nvim) | コメントトグル | `gc`, `gb` キー |
| [hop.nvim](https://github.com/smoka7/hop.nvim) | モーションジャンプ | VeryLazy |

### Markdown

| プラグイン | 説明 | 遅延読み込み |
|-----------|------|-------------|
| [markview.nvim](https://github.com/OXY2DEV/markview.nvim) | インエディタプレビュー（見出し、リスト等を装飾表示） | ❌ (即時) |
| [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) | ブラウザプレビュー（KaTeX 数式、Mermaid 対応） | ft: markdown |

### Zettelkasten

| プラグイン | 説明 | 遅延読み込み |
|-----------|------|-------------|
| telescope-loam | Zettelkasten ノート管理（開発中） | `<leader>z*` キー |

### 開発支援

| プラグイン | 説明 | 遅延読み込み |
|-----------|------|-------------|
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | 高精度シンタックスハイライト | BufRead |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP クライアント設定 | BufRead |
| [mason.nvim](https://github.com/williamboman/mason.nvim) | LSP サーバー管理 | (lsp.lua 内) |
| [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | 自動補完エンジン | InsertEnter |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git 変更表示 | BufRead |
| [claudecode.nvim](https://github.com/coder/claudecode.nvim) | Claude Code 連携 | VeryLazy |

## 主要キーマップ

### 一般

| キー | 説明 |
|------|------|
| `<C-\>` | ターミナルをトグル |
| `-` | 親ディレクトリを開く (oil.nvim) |
| `m` | 単語の先頭にジャンプ (hop.nvim) |

### ウィンドウ

| キー | 説明 |
|------|------|
| `<C-h/j/k/l>` | ウィンドウ間を移動 |
| `<C-S-h/j/k/l>` | ウィンドウサイズを調整 |
| `<leader>w=` | 全ウィンドウのサイズを均等化 |
| `<leader>wm` | 現在のウィンドウを最大化 |

※ ターミナルサイズ変更時は自動でウィンドウサイズが均等化されます

### ファイル検索 (Telescope)

| キー | 説明 |
|------|------|
| `<leader>ff` | ファイル名で検索 |
| `<leader>fg` | ファイル内容で検索 (grep) |
| `<leader>fb` | バッファ一覧 |
| `<leader>fh` | ヘルプタグ検索 |
| `<leader>fr` | 最近開いたファイル |

### コメント (Comment.nvim)

| キー | 説明 |
|------|------|
| `gcc` | 現在行をコメントトグル |
| `gc{motion}` | モーション範囲をコメントトグル |
| (Visual) `gc` | 選択範囲をコメントトグル |

### Markdown

| キー | 説明 |
|------|------|
| `<leader>mp` | インエディタプレビューをトグル (markview) |
| `<leader>ms` | 分割ビューをトグル (markview) |
| `<leader>mb` | ブラウザプレビューをトグル (markdown-preview) |

### Zettelkasten (telescope-loam)

| キー | 説明 |
|------|------|
| `gd` | リンク先へジャンプ（Markdown ファイルのみ） |
| `<leader>zn` | ノートを検索 |
| `<leader>zg` | ノート内を grep |
| `<leader>zc` | 新規ノートを作成 |
| `<leader>zb` | バックリンクを表示 |
| `<leader>zi` | インデックスを表示 |
| `<leader>zj` | ジャーナルを表示 |
| `<leader>zt` | タグでフィルター |
| `<leader>zT` | タイプでフィルター |
| `<leader>zf` | カーソル下のリンクをフォロー |
| `<leader>zd` | 今日のジャーナルを開く |

### LSP

| キー | 説明 |
|------|------|
| `gd` | 定義へジャンプ |
| `gr` | 参照一覧 |
| `K` | ホバードキュメント |
| `<leader>rn` | リネーム |
| `<leader>ca` | コードアクション |
| `<leader>f` | フォーマット |
| `[d` / `]d` | 前/次の診断へ移動 |

### Git (gitsigns.nvim)

| キー | 説明 |
|------|------|
| `]c` / `[c` | 次/前の変更箇所へ移動 |
| `<leader>hs` | 変更をステージ |
| `<leader>hr` | 変更をリセット |
| `<leader>hp` | 変更をプレビュー |
| `<leader>hb` | Git blame 表示 |

### 補完 (nvim-cmp)

| キー | 説明 |
|------|------|
| `<Tab>` / `<S-Tab>` | 候補を選択 |
| `<CR>` | 候補を確定 |
| `<C-Space>` | 補完を手動で開く |
| `<C-e>` | 補完をキャンセル |

## インストールされる LSP サーバー

mason-lspconfig により以下の言語サーバーが自動インストールされます：

| サーバー | 言語 | 用途 |
|---------|------|------|
| pyright | Python | 型チェック、補完 |
| ruff | Python | リンター、フォーマッター |
| lua_ls | Lua | Neovim 設定用 |

## 設定のカスタマイズ

### カラースキームを変更する

`plugins/colorscheme.lua` を編集して、iceberg の代わりに solarized を使用できます。
ファイル内のコメントに代替設定が記載されています。

### 新しいプラグインを追加する

`plugins/` ディレクトリに新しい Lua ファイルを作成します。
ファイルはプラグイン設定のテーブルを `return` する必要があります。

```lua
-- plugins/example.lua
return {
  "author/plugin-name",
  event = "VeryLazy",  -- 遅延読み込みトリガー
  config = function()
    require("plugin-name").setup({})
  end,
}
```

### LSP サーバーを追加する

`plugins/lsp.lua` の `ensure_installed` リストにサーバー名を追加し、
`lspconfig.xxx.setup()` で設定を追加します。

## トラブルシューティング

### プラグインが読み込まれない

```vim
:Lazy
```
で lazy.nvim の UI を開き、プラグインの状態を確認してください。

### LSP が動作しない

```vim
:LspInfo
```
で現在の LSP 状態を確認してください。

```vim
:Mason
```
で LSP サーバーのインストール状態を確認してください。

### Treesitter パーサーのエラー

```vim
:TSUpdate
```
でパーサーを更新してください。

