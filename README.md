# Zsh Configuration (dotfiles)

Конфигурация zsh с Oh My Zsh, темой Powerlevel10k и плагинами.

## Состав

| Файл | Описание |
|---|---|
| `zshrc` | Основная конфигурация zsh (`~/.zshrc`) |
| `p10k.zsh` | Конфигурация темы Powerlevel10k (`~/.p10k.zsh`) |
| `install.sh` | Скрипт автоматической установки |
| `uninstall.sh` | Скрипт отката установки |

## Что устанавливается

- **Oh My Zsh** — фреймворк для управления конфигурацией zsh
- **Powerlevel10k** — быстрая и гибкая тема (lean стиль, 1 строка, transient prompt)
- **zsh-autosuggestions** — подсказки команд на основе истории
- **zsh-syntax-highlighting** — подсветка синтаксиса в реальном времени

## Установка на новый хост

```bash
# 1. Клонируем репозиторий
git clone https://github.com/xissah/zsh-configs.git ~/zsh_to_git

# 2. Запускаем установку
cd ~/zsh_to_git
chmod +x install.sh
./install.sh

# 3. Применяем изменения
exec zsh
```

Скрипт `install.sh` автоматически:
- Установит zsh, git и curl (если не установлены)
- Установит Oh My Zsh
- Установит тему Powerlevel10k
- Установит плагины (autosuggestions, syntax-highlighting)
- Создаст символические ссылки на конфиги (с бэкапом существующих файлов)
- Предложит установить zsh как оболочку по умолчанию

Если установлен SSH-доступ к GitHub, можно клонировать через SSH:

```bash
git clone git@github.com:xissah/zsh-configs.git ~/zsh_to_git
```

## Обновление конфигурации

После изменения конфигов на одном хосте:

```bash
cd ~/zsh_to_git
git add -A
git commit -m "update zsh config"
git push
```

На другом хосте:

```bash
cd ~/zsh_to_git
git pull
exec zsh   # перезагрузить оболочку
```

## Если установка прервалась

Если после `exec zsh` появляется ошибка вида:

```text
~/.zshrc:source: no such file or directory: ~/.oh-my-zsh/oh-my-zsh.sh
```

значит Oh My Zsh не был установлен полностью. Обновите репозиторий и запустите установку ещё раз:

```bash
cd ~/zsh_to_git
git pull
./install.sh
exec zsh
```

Новый `install.sh` сам установит недостающий `curl`, перенесёт неполный каталог `~/.oh-my-zsh` в бэкап и повторит установку.

## Откат установки

```bash
cd ~/zsh_to_git
./uninstall.sh
```

Скрипт удалит ссылки `~/.zshrc` и `~/.p10k.zsh`, если они указывают на этот репозиторий, восстановит последние бэкапы и предложит удалить Oh My Zsh, Powerlevel10k и плагины.

## Перенастройка Powerlevel10k

```bash
p10k configure
```

После перенастройки скопируйте обновлённый файл в репозиторий:

```bash
cp ~/.p10k.zsh ~/zsh_to_git/p10k.zsh
cd ~/zsh_to_git
git add p10k.zsh
git commit -m "update p10k config"
git push
```

> **Примечание:** Так как `install.sh` создаёт символические ссылки (`~/.zshrc` -> `~/zsh_to_git/zshrc`), то после первой установки изменения в `~/.zshrc` будут автоматически отражаться в репозитории. Однако `p10k configure` перезаписывает `~/.p10k.zsh` обычным файлом, поэтому после перенастройки темы нужно скопировать файл обратно вручную.
