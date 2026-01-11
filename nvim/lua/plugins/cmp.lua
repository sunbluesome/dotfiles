-- =============================================================================
-- 自動補完設定 (nvim-cmp)
-- =============================================================================
-- nvim-cmp は Neovim のための高機能な補完エンジンです。
-- LSP、バッファ、パス、スニペットなど複数のソースから補完候補を提供します。
--
-- キーマップ:
--   - Tab / Shift+Tab : 候補の選択 (上下移動)
--   - Ctrl+Space      : 補完メニューを手動で開く
--   - Enter           : 選択した候補を確定
--   - Ctrl+e          : 補完をキャンセル
--   - Ctrl+b / Ctrl+f : ドキュメントをスクロール
--
-- 参考: https://github.com/hrsh7th/nvim-cmp
-- =============================================================================

return {
  -- プラグイン: hrsh7th/nvim-cmp
  "hrsh7th/nvim-cmp",

  -- 遅延読み込み: インサートモードまたはコマンドラインに入ったときに読み込む
  event = { "InsertEnter", "CmdlineEnter" },

  -- 依存プラグイン (補完ソース)
  dependencies = {
    -- LSP からの補完ソース
    "hrsh7th/cmp-nvim-lsp",

    -- バッファ内のテキストからの補完ソース
    "hrsh7th/cmp-buffer",

    -- ファイルパスの補完ソース
    "hrsh7th/cmp-path",

    -- コマンドラインの補完ソース
    "hrsh7th/cmp-cmdline",

    -- スニペットエンジン (補完時のスニペット展開に必要)
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",  -- 安定版を使用
      -- jsregexp をビルドして正規表現スニペットをサポート
      build = "make install_jsregexp",
    },

    -- LuaSnip と nvim-cmp の連携
    "saadparwaiz1/cmp_luasnip",

    -- LSP シグネチャのハイライト
    "hrsh7th/cmp-nvim-lsp-signature-help",
  },

  -- プラグイン読み込み後に実行される設定
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    -- LuaSnip の設定
    luasnip.config.setup({
      -- スニペットを抜けるときの動作
      history = true,
      -- 動的なスニペットの更新
      updateevents = "TextChanged,TextChangedI",
    })

    -- nvim-cmp のセットアップ
    cmp.setup({
      -- スニペットの展開方法
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },

      -- 補完ウィンドウの外観
      window = {
        -- 補完候補のウィンドウ
        completion = cmp.config.window.bordered({
          border = "rounded",
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
        }),
        -- ドキュメントのウィンドウ
        documentation = cmp.config.window.bordered({
          border = "rounded",
        }),
      },

      -- キーマッピング
      mapping = cmp.mapping.preset.insert({
        -- ドキュメントのスクロール
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),

        -- 補完メニューを手動で開く
        ["<C-Space>"] = cmp.mapping.complete(),

        -- 補完をキャンセル
        ["<C-e>"] = cmp.mapping.abort(),

        -- 選択した候補を確定
        -- select = true: 候補が選択されていなくても最初の候補を選択
        ["<CR>"] = cmp.mapping.confirm({ select = true }),

        -- Tab で候補を選択 / スニペットのジャンプ
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            -- 補完メニューが開いている場合: 次の候補を選択
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            -- スニペット内でジャンプ可能な場合: 次のプレースホルダーへ
            luasnip.expand_or_jump()
          else
            -- それ以外: 通常の Tab 動作
            fallback()
          end
        end, { "i", "s" }),  -- インサートモードと選択モードで有効

        -- Shift+Tab で逆方向の候補選択 / スニペットジャンプ
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),

      -- 補完ソースの設定
      -- 配列の順序が優先度を決定 (前にあるものが優先)
      sources = cmp.config.sources({
        -- グループ 1: 高優先度
        { name = "nvim_lsp" },                -- LSP からの補完
        { name = "nvim_lsp_signature_help" }, -- 関数シグネチャ
        { name = "luasnip" },                 -- スニペット
      }, {
        -- グループ 2: 低優先度 (グループ 1 で候補がない場合に使用)
        { name = "buffer" },                  -- バッファ内のテキスト
        { name = "path" },                    -- ファイルパス
      }),

      -- 補完候補の表示形式
      formatting = {
        -- 候補の各フィールドの順序
        fields = { "abbr", "kind", "menu" },

        -- 表示形式のカスタマイズ
        format = function(entry, vim_item)
          -- 補完アイテムの種類 (関数、変数、クラスなど) のアイコン
          local kind_icons = {
            Text = "󰉿",
            Method = "󰆧",
            Function = "󰊕",
            Constructor = "",
            Field = "󰜢",
            Variable = "󰀫",
            Class = "󰠱",
            Interface = "",
            Module = "",
            Property = "󰜢",
            Unit = "󰑭",
            Value = "󰎠",
            Enum = "",
            Keyword = "󰌋",
            Snippet = "",
            Color = "󰏘",
            File = "󰈙",
            Reference = "󰈇",
            Folder = "󰉋",
            EnumMember = "",
            Constant = "󰏿",
            Struct = "󰙅",
            Event = "",
            Operator = "󰆕",
            TypeParameter = "",
          }

          vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind] or "", vim_item.kind)

          -- 補完ソースの表示
          vim_item.menu = ({
            nvim_lsp = "[LSP]",
            luasnip = "[Snippet]",
            buffer = "[Buffer]",
            path = "[Path]",
          })[entry.source.name]

          return vim_item
        end,
      },

      -- 実験的機能
      experimental = {
        -- ゴーストテキスト (カーソル位置に候補をプレビュー)
        ghost_text = false,
      },
    })

    -- コマンドラインの補完設定 (/)
    -- 検索時にバッファ内のテキストを補完
    cmp.setup.cmdline("/", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })

    -- コマンドラインの補完設定 (:)
    -- コマンドとパスを補完
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "path" },
      }, {
        { name = "cmdline" },
      }),
    })
  end,
}

