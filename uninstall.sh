#!/usr/bin/env bash
#
# uninstall.sh — Откат установки zsh-конфигурации из этого репозитория.
#
# Что делает:
#   - удаляет ссылки ~/.zshrc и ~/.p10k.zsh, если они указывают на файлы этого репозитория;
#   - восстанавливает последние бэкапы ~/.zshrc.backup.* и ~/.p10k.zsh.backup.*;
#   - по желанию удаляет Oh My Zsh, Powerlevel10k и плагины.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

confirm() {
    local prompt="$1"
    local answer

    read -rp "$prompt [y/N] " answer
    [[ "$answer" =~ ^[Yy]$ ]]
}

latest_backup_for() {
    local dst="$1"
    local latest=""
    local backup

    for backup in "$dst".backup.*; do
        [ -e "$backup" ] || continue
        latest="$backup"
    done

    printf '%s\n' "$latest"
}

restore_linked_config() {
    local src="$1"
    local dst="$2"
    local backup
    local target

    if [ -L "$dst" ]; then
        target="$(readlink "$dst")"
        if [ "$target" = "$src" ]; then
            rm -f "$dst"
            info "Удалена ссылка: $dst -> $src"
        else
            warn "$dst является ссылкой, но указывает не на этот репозиторий: $target"
            warn "Пропускаю, чтобы не удалить чужую настройку."
            return
        fi
    elif [ -e "$dst" ]; then
        warn "$dst существует, но это не ссылка. Пропускаю."
        return
    else
        info "$dst уже отсутствует."
    fi

    backup="$(latest_backup_for "$dst")"
    if [ -n "$backup" ]; then
        mv "$backup" "$dst"
        info "Восстановлен бэкап: $backup -> $dst"
    else
        info "Бэкап для $dst не найден, оставляю файл отсутствующим."
    fi
}

remove_dir_if_confirmed() {
    local dir="$1"
    local label="$2"

    if [ ! -d "$dir" ]; then
        info "$label не найден: $dir"
        return
    fi

    if confirm "Удалить $label ($dir)?"; then
        rm -rf "$dir"
        info "Удалено: $dir"
    else
        info "Оставлено без изменений: $dir"
    fi
}

echo ""
info "Откат zsh-конфигурации из: $SCRIPT_DIR"
echo ""

restore_linked_config "$SCRIPT_DIR/zshrc" "$HOME/.zshrc"
restore_linked_config "$SCRIPT_DIR/p10k.zsh" "$HOME/.p10k.zsh"

echo ""
warn "Следующие каталоги могли быть созданы install.sh, но в них могли появиться и ваши изменения."
warn "Удаляйте их только если точно хотите убрать установленное окружение Oh My Zsh."
echo ""

ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
remove_dir_if_confirmed "$ZSH_CUSTOM_DIR/themes/powerlevel10k" "Powerlevel10k"
remove_dir_if_confirmed "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions" "zsh-autosuggestions"
remove_dir_if_confirmed "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting" "zsh-syntax-highlighting"
remove_dir_if_confirmed "$HOME/.oh-my-zsh" "Oh My Zsh"

echo ""
warn "Если во время установки вы меняли shell через chsh, этот скрипт не знает предыдущую оболочку."
warn "При необходимости смените её вручную, например: chsh -s /bin/zsh или chsh -s /bin/bash"
echo ""
info "Откат завершён. Чтобы применить изменения в текущем терминале, выполните:"
echo "    exec zsh"
echo ""
