# aliases
alias ll='ls -al'
alias la='ls -a'

# for iTerm2
export CLICOLOR=1
export TERM=xterm-256color

# shell
export PS1='%n@%m:%c %# '

# XDG Base Directory Specification
export XDG_CONFIG_HOME=$HOME/.config
mkdir -p $XDG_CONFIG_HOME

# starship
eval "$(starship init zsh)"
export PATH="$HOME/.local/bin:$PATH"

# ghostty
# open today's journal
function memo() {
    local dir="$HOME/Projects/personal-knowledge/journal"
    mkdir -p "$dir"  # create directory if not exists
    nvim "$dir/$(TZ=Asia/Tokyo date +%Y%m%d).md"
}

# DevContainer内でNeovimを起動する関数
dcnvim() {
  # カレントディレクトリ名からコンテナ名を推測
  local project_name=$(basename "$(pwd)")
  local container_name="${project_name}_devcontainer-app-1"
  
  # コンテナが起動しているか確認
  if ! docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
    echo "Error: Container '$container_name' is not running" >&2
    echo "Start DevContainer first using Cursor/VSCode" >&2
    return 1
  fi

  # プロジェクトルートにNeovim用ディレクトリを作成
  mkdir -p .local/share/nvim
  mkdir -p .local/state/nvim

  # アーキテクチャに応じたNeovimパスを使用
  docker exec -it "$container_name" bash -c '
    if [ -x /opt/nvim-linux-arm64/bin/nvim ]; then
      /opt/nvim-linux-arm64/bin/nvim "$@"
    else
      /opt/nvim-linux-x86_64/bin/nvim "$@"
    fi
  ' -- "$@"
}
