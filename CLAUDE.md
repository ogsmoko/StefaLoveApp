# StefaLoveApp — Контекст проекта

## О проекте

Персональное web-приложение от Vasily (`ogsmoko`, `vasakrasava13@gmail.com`) для его девушки Стефании (Стефа).

**Репо:** `ogsmoko/StefaLoveApp` | **Хостинг:** GitHub Pages | **Ветка:** `main`

## Стек

| Слой | Технология |
|---|---|
| Frontend | Один файл `index.html` (CSS + JS inline). Шрифты: Playfair Display + Nunito (Google Fonts). Supabase JS CDN. |
| БД | Supabase PostgreSQL — `https://bzeublyracwozknwwzfi.supabase.co` |
| Auth | Supabase Auth (email + пароль). Пользователи создаются вручную. |
| AI | Gemini 2.0 Flash (основной) + Groq llama-3.3-70b (fallback) через Edge Function `ai-call` |

## Публичные значения в коде (не секреты)

```javascript
const SUPABASE_URL = 'https://bzeublyracwozknwwzfi.supabase.co';
const SUPABASE_KEY = 'eyJhbGci...'; // anon key — публичный
const ADMIN_EMAIL  = 'vasakrasava13@gmail.com';
```

**НИКОГДА не вставляй Gemini/Groq/GitHub tokens в index.html!** Только в Supabase Edge Function Secrets.

## БД (все таблицы без RLS)

| Таблица | Колонки |
|---|---|
| `wishes` | id, text, is_done (bool), created_at, user_id |
| `scores` | id, game (text), points (int), created_at, user_id |
| `used_trivia` | id, question, user_id, created_at |
| `used_words` | id, word, user_id, created_at |
| `love_messages` | id, recipient_id, title, content, emoji, show_after (timestamp), is_read (bool), created_at |
| `achievements` | id, user_id, badge_key (text), unlocked_at — UNIQUE(user_id, badge_key) |

> **Покупки в магазине** хранятся в `scores` как отрицательные очки (`game = 'Магазин: <название>'`, `points = -cost`). Таблица `purchases` не нужна.

## Дизайн-система

### 5 палитр × 2 темы

`body[data-palette="..."]` + `body.dark`. Сохраняются в `localStorage` (`'theme'`, `'palette'`).

| Ключ | Описание |
|---|---|
| (default) | розово-кремовый |
| `ocean` | голубой-бирюзовый |
| `lavender` | фиолетово-лавандовый |
| `mint` | мятно-зелёный |
| `sunset` | тёпло-оранжевый |

### CSS-переменные

`--rose`, `--rose-light`, `--rose-pale`, `--gold`, `--cream`, `--dark`, `--mid`, `--soft`, `--white`, `--shadow`, `--shadow-lg`

> Фоны блоков (`.compliment-box`, `.love-msg`) должны использовать `var(--rose-pale)` / `var(--white)` — не хардкодить hex.

### UI-элементы

- `🌙/☀️` (слева) — тема | `🎨` (рядом) — палитра dropdown | `↪ Выйти` (справа)
- score-bar: показывает `totalScore` + самый дорогой доступный товар из магазина

## Функциональность (текущее состояние)

### Навигация (6 вкладок)
`💬 Комплименты` | `✨ Хотелки` | `🎮 Игры` | `🛍️ Магазин` | `💌 Письма` | `🏅 Достижения`

### 💬 Комплименты
- 5 настроений: нежное, весёлое, страстное, вдохновляющее, игривое
- AI через `callAI()` → Edge Function

### ✨ Хотелки
- CRUD, привязано к `user_id`

### 🎮 4 мини-игры (актуальные очки)

| Игра | Очки |
|---|---|
| Викторина 🧠 | +5 за правильный ответ |
| Угадай слово 🔤 | +8 за слово |
| Тапалка 💗 | +1 за каждые 15 тапов (15 сек) |
| Мемори 🃏 | +10 за победу |

### 🛍️ Магазин подарков (заменил старые «Призы»)

4 категории, 19 товаров. Покупка = отрицательный `scores` ряд.

| Категория | Диапазон цен |
|---|---|
| 💋 Нежность | 10–95 очков |
| 🍬 Вкусняшки | 25–120 очков |
| 🎉 Активности | 90–270 очков |
| ✨ Особые | 85–1000 очков |

### 💌 Письма
- **Админ:** форма + список отправленных + удаление
- **Стефа:** только `show_after <= now()`, badge-счётчик непрочитанных

### 🏅 Достижения (13 бейджей)

| badge_key | Триггер |
|---|---|
| first_compliment | getCompliment() успех |
| all_moods | все 5 настроений (triedMoods в localStorage) |
| first_wish | addWish() |
| wish_done | toggleWish() → done |
| first_game | addScore() первый раз |
| trivia_correct | answerTrivia() верно |
| word_win | guessLetter() — всё угадано |
| memory_win | flipCard() — все пары |
| clicker_master | finishClicker() >= 50 тапов |
| pts_100 / pts_500 / pts_1000 | addScore() при достижении порога |
| first_letter | markMsgRead() |

Achievement toast: отдельный `#achievementToast` вылетает справа.

## Правила кода

1. **Один файл** — всё в `index.html`
2. **БД переменная** — `db` (не `supabase` — конфликт с `window.supabase` CDN)
3. **AI** — только через `callAI(prompt, jsonMode)` → Edge Function
4. **User binding** — все данные к `currentUser.id`
5. **escapeHtml()** — всегда для пользовательского ввода
6. **Нет секретов** в `index.html`

## Git workflow

```bash
git add index.html CLAUDE.md
git commit -m "описание"
git push
# GitHub Pages деплоит через ~30 сек
```

## Что осталось сделать

### Этап 4: Статистика 📊
- График очков за последние 30 дней
- Топ игр по очкам
- Общая статистика: всего игр, дней активности, комплиментов

## Инструкции для Claude

- **Планирование** сложных фич → используй `Plan` агент с `model: opus`
- **Реализация** → работай напрямую (Sonnet достаточно для правок `index.html`)
- **Читай файлы узко**: сначала `Grep` чтобы найти нужное место, потом `Read` с `offset`/`limit`
- **Не пересказывай** то что делаешь — показывай результат
- **Батчи**: независимые Edit-вызовы — в одном сообщении параллельно
- Перед большими изменениями структуры — прочитай актуальный `index.html` (worktree может отличаться от main)
