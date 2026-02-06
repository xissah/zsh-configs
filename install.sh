#!/usr/bin/env bash
#
# install.sh — Автоматическая установка zsh-конфигурации из этого репозитория.
#
# Использование:
#   git clone <repo-url> ~/zsh_to_git
#   cd ~/zsh_to_git
#   chmod +x install.sh
#   ./install.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# --------------------------------------------------------------------------- #
# 1. Проверка наличия zsh
# --------------------------------------------------------------------------- #
if ! command -v zsh &>/dev/null; then
    warn "zsh не найден. Попытка установки..."
    if command -v apt-get &>/dev/null; then
        sudo apt-get update && sudo apt-get install -y zsh
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y zsh
    elif command -v yum &>/dev/null; then
        sudo yum install -y zsh
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm zsh
    elif command -v brew &>/dev/null; then
        brew install zsh
    else
        error "Не удалось определить пакетный менеджер. Установите zsh вручную."
    fi
    info "zsh установлен."
fi

# --------------------------------------------------------------------------- #
# 2. Проверка наличия git
# --------------------------------------------------------------------------- #
if ! command -v git &>/dev/null; then
    error "git не установлен. Установите git и повторите попытку."
fi

# --------------------------------------------------------------------------- #
# 3. Установка Oh My Zsh (если ещё не установлен)
# --------------------------------------------------------------------------- #
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Установка Oh My Zsh..."
    RUNZSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    info "Oh My Zsh установлен."
else
    info "Oh My Zsh уже установлен — пропускаем."
fi

# --------------------------------------------------------------------------- #
# 4. Установка темы Powerlevel10k
# --------------------------------------------------------------------------- #
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    info "Установка Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
    info "Powerlevel10k установлен."
else
    info "Powerlevel10k уже установлен — обновляем..."
    git -C "$P10K_DIR" pull --ff-only 2>/dev/null || warn "Не удалось обновить Powerlevel10k."
fi

# --------------------------------------------------------------------------- #
# 5. Установка плагинов
# --------------------------------------------------------------------------- #
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# zsh-autosuggestions
AUTOSUGG_DIR="$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
if [ ! -d "$AUTOSUGG_DIR" ]; then
    info "Установка zsh-autosuggestions..."
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$AUTOSUGG_DIR"
    info "zsh-autosuggestions установлен."
else
    info "zsh-autosuggestions уже установлен — обновляем..."
    git -C "$AUTOSUGG_DIR" pull --ff-only 2>/dev/null || warn "Не удалось обновить zsh-autosuggestions."
fi

# zsh-syntax-highlighting
SYNHL_DIR="$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
if [ ! -d "$SYNHL_DIR" ]; then
    info "Установка zsh-syntax-highlighting..."
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$SYNHL_DIR"
    info "zsh-syntax-highlighting установлен."
else
    info "zsh-syntax-highlighting уже установлен — обновляем..."
    git -C "$SYNHL_DIR" pull --ff-only 2>/dev/null || warn "Не удалось обновить zsh-syntax-highlighting."
fi

# --------------------------------------------------------------------------- #
# 6. Создание символических ссылок (с бэкапом старых файлов)
# --------------------------------------------------------------------------- #
backup_and_link() {
    local src="$1"
    local dst="$2"

    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        local backup="${dst}.backup.$(date +%Y%m%d%H%M%S)"
        warn "Файл $dst уже существует — создаю бэкап: $backup"
        mv "$dst" "$backup"
    elif [ -L "$dst" ]; then
        rm -f "$dst"
    fi

    ln -sf "$src" "$dst"
    info "Создана ссылка: $dst -> $src"
}

backup_and_link "$SCRIPT_DIR/zshrc"    "$HOME/.zshrc"
backup_and_link "$SCRIPT_DIR/p10k.zsh" "$HOME/.p10k.zsh"

# --------------------------------------------------------------------------- #
# 7. Установка zsh как оболочки по умолчанию (опционально)
# --------------------------------------------------------------------------- #
CURRENT_SHELL="$(basename "$SHELL")"
if [ "$CURRENT_SHELL" != "zsh" ]; then
    ZSH_PATH="$(command -v zsh)"
    read -rp "Установить zsh ($ZSH_PATH) как оболочку по умолчанию? [y/N] " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        if command -v chsh &>/dev/null; then
            chsh -s "$ZSH_PATH"
            info "Оболочка по умолчанию изменена на zsh."
        else
            warn "Команда chsh не найдена. Измените оболочку вручную."
        fi
    fi
fi

# --------------------------------------------------------------------------- #
# Готово!
# --------------------------------------------------------------------------- #
echo ""
info "============================================"
info "  Установка завершена!"
info "============================================"
echo ""
info "Для применения изменений выполните:"
echo "    exec zsh"
echo ""
info "Для перенастройки темы Powerlevel10k:"
echo "    p10k configure"
echo ""
