# Дизайн-система HR Platform
## Полная спецификация UI/UX дизайна

**Дата создания:** 2025-11-12  
**Версия:** 1.0  
**Статус:** Production-Ready Design Specification

---

## 📋 ОГЛАВЛЕНИЕ

1. [Философия дизайна](#1-философия-дизайна)
2. [Цветовая система](#2-цветовая-система)
3. [Типографика](#3-типографика)
4. [Spacing & Layout](#4-spacing--layout)
5. [Компоненты](#5-компоненты)
6. [Темы (Light/Dark)](#6-темы-lightdark)
7. [Адаптивный дизайн](#7-адаптивный-дизайн)
8. [Анимации и переходы](#8-анимации-и-переходы)
9. [Иконография](#9-иконография)
10. [Дизайн страниц](#10-дизайн-страниц)
11. [Состояния интерфейса](#11-состояния-интерфейса)
12. [Accessibility](#12-accessibility)

---

## 1. ФИЛОСОФИЯ ДИЗАЙНА

### 1.1 Ключевые принципы

**"Профессиональная простота"**

Дизайн платформы строится на трех столпах:

1. **Минимализм** — ничего лишнего, только важное
2. **Ясность** — любой элемент понятен интуитивно
3. **Современность** — актуальные тренды без перебора

### 1.2 Визуальный язык

- **Чистота** — много белого пространства (или темного в dark mode)
- **Геометрия** — мягкие скругления (8px), четкие границы
- **Глубина** — тонкие тени для иерархии
- **Акценты** — цвет используется осознанно, для привлечения внимания

### 1.3 Эмоциональный тон

- **Для HR:** Уверенность, контроль, эффективность
- **Для кандидатов:** Дружелюбие, поддержка, оптимизм

---

## 2. ЦВЕТОВАЯ СИСТЕМА

### 2.1 Основная палитра (Slate)

Используем палитру **Slate** из Tailwind CSS как основу для нейтральных цветов.

#### Light Mode:

```css
/* Primary Colors (Slate) */
--primary-50: #f8fafc;   /* Самый светлый фон */
--primary-100: #f1f5f9;  /* Карточки, hover states */
--primary-200: #e2e8f0;  /* Borders, разделители */
--primary-300: #cbd5e1;  /* Disabled text, плейсхолдеры */
--primary-400: #94a3b8;  /* Иконки, вторичный текст */
--primary-500: #64748b;  /* Основной серый текст */
--primary-600: #475569;  /* Заголовки */
--primary-700: #334155;  /* Темные заголовки */
--primary-800: #1e293b;  /* Темнейший текст */
--primary-900: #0f172a;  /* Почти черный */

/* Background */
--background: #ffffff;           /* Основной фон страницы */
--background-secondary: #f8fafc; /* Фон для секций */

/* Foreground (текст) */
--foreground: #0f172a;           /* Основной текст */
--foreground-secondary: #64748b; /* Вторичный текст */
--foreground-tertiary: #94a3b8;  /* Третичный текст */

/* Borders */
--border: #e2e8f0;               /* Основные границы */
--border-strong: #cbd5e1;        /* Акцентные границы */
```

#### Dark Mode:

```css
/* Primary Colors (Slate) */
--primary-50: #0f172a;   /* Самый темный фон */
--primary-100: #1e293b;  /* Карточки */
--primary-200: #334155;  /* Borders */
--primary-300: #475569;  /* Disabled text */
--primary-400: #64748b;  /* Вторичный текст */
--primary-500: #94a3b8;  /* Основной текст */
--primary-600: #cbd5e1;  /* Заголовки */
--primary-700: #e2e8f0;  /* Яркие заголовки */
--primary-800: #f1f5f9;  /* Самый яркий текст */
--primary-900: #f8fafc;  /* Почти белый */

/* Background */
--background: #0a0e1a;           /* Основной фон (темнее slate-900) */
--background-secondary: #0f172a; /* Фон для секций */

/* Foreground (текст) */
--foreground: #f8fafc;           /* Основной текст */
--foreground-secondary: #94a3b8; /* Вторичный текст */
--foreground-tertiary: #64748b;  /* Третичный текст */

/* Borders */
--border: #1e293b;               /* Основные границы */
--border-strong: #334155;        /* Акцентные границы */
```

### 2.2 Акцентные цвета

#### Primary (Основной акцент - Blue)

```css
/* Light Mode */
--accent-primary: #3b82f6;       /* Blue-500 */
--accent-primary-hover: #2563eb; /* Blue-600 */
--accent-primary-active: #1d4ed8;/* Blue-700 */
--accent-primary-light: #dbeafe; /* Blue-100 для фона */

/* Dark Mode */
--accent-primary: #60a5fa;       /* Blue-400 */
--accent-primary-hover: #3b82f6; /* Blue-500 */
--accent-primary-active: #2563eb;/* Blue-600 */
--accent-primary-light: #1e3a8a; /* Blue-900 для фона */
```

#### Success (Зеленый)

```css
/* Light Mode */
--success: #10b981;       /* Green-500 */
--success-light: #d1fae5; /* Green-100 */

/* Dark Mode */
--success: #34d399;       /* Green-400 */
--success-light: #064e3b; /* Green-900 */
```

#### Warning (Желтый)

```css
/* Light Mode */
--warning: #f59e0b;       /* Amber-500 */
--warning-light: #fef3c7; /* Amber-100 */

/* Dark Mode */
--warning: #fbbf24;       /* Amber-400 */
--warning-light: #78350f; /* Amber-900 */
```

#### Error (Красный)

```css
/* Light Mode */
--error: #ef4444;       /* Red-500 */
--error-light: #fee2e2; /* Red-100 */

/* Dark Mode */
--error: #f87171;       /* Red-400 */
--error-light: #7f1d1d; /* Red-900 */
```

#### Info (Голубой)

```css
/* Light Mode */
--info: #06b6d4;       /* Cyan-500 */
--info-light: #cffafe; /* Cyan-100 */

/* Dark Mode */
--info: #22d3ee;       /* Cyan-400 */
--info-light: #164e63; /* Cyan-900 */
```

### 2.3 Семантические цвета

```css
/* Для графиков и визуализаций */
--chart-1: #3b82f6;  /* Blue */
--chart-2: #10b981;  /* Green */
--chart-3: #f59e0b;  /* Amber */
--chart-4: #ef4444;  /* Red */
--chart-5: #8b5cf6;  /* Violet */
--chart-6: #ec4899;  /* Pink */

/* Статусы кандидатов */
--status-invited: #6366f1;    /* Indigo */
--status-testing: #f59e0b;    /* Amber */
--status-tested: #10b981;     /* Green */
--status-analyzed: #3b82f6;   /* Blue */
--status-interview: #8b5cf6;  /* Violet */
--status-offer: #10b981;      /* Green */
--status-hired: #059669;      /* Green-600 */
--status-rejected: #ef4444;   /* Red */
--status-saved: #6b7280;      /* Gray */

/* Актуальность тестов */
--test-fresh: #10b981;   /* Зеленый - свежие */
--test-warning: #f59e0b; /* Желтый - скоро устареют */
--test-outdated: #ef4444;/* Красный - устарели */
```

### 2.4 Принципы использования цвета

1. **Контраст:** Всегда WCAG AA (4.5:1 для текста)
2. **Иерархия:** Primary > Secondary > Tertiary
3. **Акценты:** Не более 2-3 цветов одновременно
4. **Консистентность:** Одинаковые элементы = одинаковые цвета

---

## 3. ТИПОГРАФИКА

### 3.1 Шрифт

**Inter** — современный геометрический шрифт, отличная читаемость.

```css
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');

font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
```

### 3.2 Шкала размеров

```css
/* Mobile First (320px+) */
--text-xs: 0.75rem;    /* 12px - Метки, подписи */
--text-sm: 0.875rem;   /* 14px - Мелкий текст, описания */
--text-base: 1rem;     /* 16px - Основной текст */
--text-lg: 1.125rem;   /* 18px - Крупный текст */
--text-xl: 1.25rem;    /* 20px - Заголовки H4 */
--text-2xl: 1.5rem;    /* 24px - Заголовки H3 */
--text-3xl: 1.875rem;  /* 30px - Заголовки H2 */
--text-4xl: 2.25rem;   /* 36px - Заголовки H1 */
--text-5xl: 3rem;      /* 48px - Hero заголовки */

/* Desktop (1024px+) - увеличиваем на 10-20% */
@media (min-width: 1024px) {
  --text-base: 1.0625rem; /* 17px */
  --text-lg: 1.25rem;     /* 20px */
  --text-xl: 1.375rem;    /* 22px */
  --text-2xl: 1.75rem;    /* 28px */
  --text-3xl: 2.125rem;   /* 34px */
  --text-4xl: 2.625rem;   /* 42px */
  --text-5xl: 3.5rem;     /* 56px */
}
```

### 3.3 Веса шрифта

```css
--font-light: 300;    /* Для крупных заголовков */
--font-normal: 400;   /* Основной текст */
--font-medium: 500;   /* Акценты, кнопки */
--font-semibold: 600; /* Заголовки, labels */
--font-bold: 700;     /* Сильные акценты */
```

### 3.4 Высота строки

```css
--leading-tight: 1.25;   /* Для заголовков */
--leading-snug: 1.375;   /* Для подзаголовков */
--leading-normal: 1.5;   /* Для основного текста */
--leading-relaxed: 1.625;/* Для длинных текстов */
--leading-loose: 2;      /* Для коротких строк */
```

### 3.5 Типографская шкала

#### Заголовки

```css
/* H1 - Главные заголовки страниц */
.heading-1 {
  font-size: var(--text-4xl);
  font-weight: var(--font-bold);
  line-height: var(--leading-tight);
  letter-spacing: -0.02em;
}

/* H2 - Секции */
.heading-2 {
  font-size: var(--text-3xl);
  font-weight: var(--font-semibold);
  line-height: var(--leading-tight);
  letter-spacing: -0.01em;
}

/* H3 - Подсекции */
.heading-3 {
  font-size: var(--text-2xl);
  font-weight: var(--font-semibold);
  line-height: var(--leading-snug);
}

/* H4 - Карточки, блоки */
.heading-4 {
  font-size: var(--text-xl);
  font-weight: var(--font-medium);
  line-height: var(--leading-snug);
}
```

#### Тело текста

```css
/* Body Large - Важные параграфы */
.body-large {
  font-size: var(--text-lg);
  font-weight: var(--font-normal);
  line-height: var(--leading-relaxed);
}

/* Body Regular - Основной текст */
.body-regular {
  font-size: var(--text-base);
  font-weight: var(--font-normal);
  line-height: var(--leading-normal);
}

/* Body Small - Описания */
.body-small {
  font-size: var(--text-sm);
  font-weight: var(--font-normal);
  line-height: var(--leading-normal);
}

/* Caption - Метки, подписи */
.caption {
  font-size: var(--text-xs);
  font-weight: var(--font-medium);
  line-height: var(--leading-normal);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
```

---

## 4. SPACING & LAYOUT

### 4.1 Spacing Scale

Используем систему 4px (Tailwind по умолчанию):

```css
--space-0: 0;
--space-1: 0.25rem;  /* 4px */
--space-2: 0.5rem;   /* 8px */
--space-3: 0.75rem;  /* 12px */
--space-4: 1rem;     /* 16px */
--space-5: 1.25rem;  /* 20px */
--space-6: 1.5rem;   /* 24px */
--space-8: 2rem;     /* 32px */
--space-10: 2.5rem;  /* 40px */
--space-12: 3rem;    /* 48px */
--space-16: 4rem;    /* 64px */
--space-20: 5rem;    /* 80px */
--space-24: 6rem;    /* 96px */
```

### 4.2 Правила отступов

**Принцип:** Consistent spacing создает ритм

```css
/* Карточки */
.card-padding: var(--space-6);      /* 24px внутри карточек */
.card-gap: var(--space-4);          /* 16px между элементами */

/* Списки */
.list-gap: var(--space-4);          /* 16px между элементами списка */

/* Секции страниц */
.section-gap: var(--space-12);      /* 48px между секциями */

/* Формы */
.form-field-gap: var(--space-4);    /* 16px между полями */
.form-label-gap: var(--space-2);    /* 8px между label и input */

/* Модальные окна */
.modal-padding: var(--space-6);     /* 24px внутри модалок */
```

### 4.3 Layout Grid

#### Desktop (1024px+)

```css
.container {
  max-width: 1280px;
  margin: 0 auto;
  padding: 0 var(--space-6);
}

/* Sidebar Layout */
.dashboard-layout {
  display: grid;
  grid-template-columns: 280px 1fr; /* Sidebar 280px, контент flex */
  gap: 0;
  min-height: 100vh;
}
```

#### Tablet (768px - 1023px)

```css
.container {
  max-width: 100%;
  padding: 0 var(--space-4);
}

.dashboard-layout {
  grid-template-columns: 240px 1fr; /* Sidebar меньше */
}
```

#### Mobile (320px - 767px)

```css
.container {
  max-width: 100%;
  padding: 0 var(--space-4);
}

.dashboard-layout {
  grid-template-columns: 1fr; /* Sidebar скрыт, Sheet */
}
```

### 4.4 Border Radius

```css
--radius-none: 0;
--radius-sm: 0.25rem;   /* 4px - маленькие элементы */
--radius-md: 0.5rem;    /* 8px - кнопки, inputs */
--radius-lg: 0.75rem;   /* 12px - карточки */
--radius-xl: 1rem;      /* 16px - крупные карточки */
--radius-2xl: 1.5rem;   /* 24px - модальные окна */
--radius-full: 9999px;  /* Круглые элементы */
```

### 4.5 Shadows

```css
/* Light Mode */
--shadow-xs: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
--shadow-sm: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px -1px rgba(0, 0, 0, 0.1);
--shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.1);
--shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1);
--shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1);
--shadow-2xl: 0 25px 50px -12px rgba(0, 0, 0, 0.25);

/* Dark Mode - мягче */
--shadow-xs: 0 1px 2px 0 rgba(0, 0, 0, 0.3);
--shadow-sm: 0 1px 3px 0 rgba(0, 0, 0, 0.4), 0 1px 2px -1px rgba(0, 0, 0, 0.4);
--shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.4), 0 2px 4px -2px rgba(0, 0, 0, 0.4);
--shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.4), 0 4px 6px -4px rgba(0, 0, 0, 0.4);
--shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.4), 0 8px 10px -6px rgba(0, 0, 0, 0.4);
--shadow-2xl: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
```

---

## 5. КОМПОНЕНТЫ

### 5.1 Buttons (Кнопки)

#### Варианты

**1. Default (Основная кнопка)**

```css
.button-default {
  background: var(--accent-primary);
  color: white;
  padding: 0.625rem 1.25rem; /* 10px 20px */
  border-radius: var(--radius-md);
  font-weight: var(--font-medium);
  font-size: var(--text-sm);
  transition: all 150ms ease;
  box-shadow: var(--shadow-xs);
}

.button-default:hover {
  background: var(--accent-primary-hover);
  box-shadow: var(--shadow-md);
  transform: translateY(-1px);
}

.button-default:active {
  background: var(--accent-primary-active);
  transform: translateY(0);
}

.button-default:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none;
}
```

**2. Outline (Вторичная кнопка)**

```css
.button-outline {
  background: transparent;
  color: var(--accent-primary);
  border: 1px solid var(--accent-primary);
  padding: 0.625rem 1.25rem;
  border-radius: var(--radius-md);
  font-weight: var(--font-medium);
  font-size: var(--text-sm);
  transition: all 150ms ease;
}

.button-outline:hover {
  background: var(--accent-primary-light);
}
```

**3. Ghost (Третичная кнопка)**

```css
.button-ghost {
  background: transparent;
  color: var(--foreground);
  padding: 0.625rem 1.25rem;
  border-radius: var(--radius-md);
  font-weight: var(--font-medium);
  font-size: var(--text-sm);
  transition: all 150ms ease;
}

.button-ghost:hover {
  background: var(--primary-100);
}
```

**4. Destructive (Опасное действие)**

```css
.button-destructive {
  background: var(--error);
  color: white;
  padding: 0.625rem 1.25rem;
  border-radius: var(--radius-md);
  font-weight: var(--font-medium);
  font-size: var(--text-sm);
  transition: all 150ms ease;
}

.button-destructive:hover {
  background: #dc2626; /* Red-600 */
}
```

**5. Icon Button (Только иконка)**

```css
.button-icon {
  background: transparent;
  color: var(--foreground-secondary);
  width: 2.5rem;
  height: 2.5rem;
  padding: 0;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 150ms ease;
}

.button-icon:hover {
  background: var(--primary-100);
  color: var(--foreground);
}
```

#### Размеры

```css
/* Small */
.button-sm {
  padding: 0.5rem 1rem;
  font-size: var(--text-xs);
}

/* Default (уже описан) */
.button-md {
  padding: 0.625rem 1.25rem;
  font-size: var(--text-sm);
}

/* Large */
.button-lg {
  padding: 0.75rem 1.5rem;
  font-size: var(--text-base);
}
```

### 5.2 Inputs (Поля ввода)

```css
.input {
  width: 100%;
  padding: 0.625rem 0.75rem; /* 10px 12px */
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  background: var(--background);
  color: var(--foreground);
  font-size: var(--text-sm);
  line-height: var(--leading-normal);
  transition: all 150ms ease;
}

.input:focus {
  outline: none;
  border-color: var(--accent-primary);
  box-shadow: 0 0 0 3px var(--accent-primary-light);
}

.input:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  background: var(--primary-100);
}

.input::placeholder {
  color: var(--foreground-tertiary);
}

/* Error state */
.input.error {
  border-color: var(--error);
}

.input.error:focus {
  box-shadow: 0 0 0 3px var(--error-light);
}
```

### 5.3 Select (Dropdown)

```css
.select {
  width: 100%;
  padding: 0.625rem 2.5rem 0.625rem 0.75rem;
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  background: var(--background);
  color: var(--foreground);
  font-size: var(--text-sm);
  line-height: var(--leading-normal);
  appearance: none;
  cursor: pointer;
  transition: all 150ms ease;
  
  /* Custom arrow */
  background-image: url("data:image/svg+xml...");
  background-repeat: no-repeat;
  background-position: right 0.75rem center;
  background-size: 1rem;
}

.select:focus {
  outline: none;
  border-color: var(--accent-primary);
  box-shadow: 0 0 0 3px var(--accent-primary-light);
}
```

### 5.4 Checkbox & Radio

```css
.checkbox,
.radio {
  width: 1.25rem;
  height: 1.25rem;
  border: 2px solid var(--border);
  border-radius: var(--radius-sm); /* checkbox */
  background: var(--background);
  cursor: pointer;
  transition: all 150ms ease;
}

.radio {
  border-radius: var(--radius-full); /* круглый */
}

.checkbox:checked,
.radio:checked {
  background: var(--accent-primary);
  border-color: var(--accent-primary);
}

.checkbox:focus,
.radio:focus {
  outline: none;
  box-shadow: 0 0 0 3px var(--accent-primary-light);
}
```

### 5.5 Card (Карточка)

```css
.card {
  background: var(--background);
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  padding: var(--space-6);
  box-shadow: var(--shadow-sm);
  transition: all 200ms ease;
}

.card:hover {
  box-shadow: var(--shadow-md);
  transform: translateY(-2px);
}

/* Карточка без hover эффекта */
.card-static {
  background: var(--background);
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  padding: var(--space-6);
}

/* Header карточки */
.card-header {
  margin-bottom: var(--space-4);
  padding-bottom: var(--space-4);
  border-bottom: 1px solid var(--border);
}

.card-title {
  font-size: var(--text-xl);
  font-weight: var(--font-semibold);
  color: var(--foreground);
}

.card-description {
  font-size: var(--text-sm);
  color: var(--foreground-secondary);
  margin-top: var(--space-2);
}

/* Content */
.card-content {
  /* Контент карточки */
}

/* Footer */
.card-footer {
  margin-top: var(--space-4);
  padding-top: var(--space-4);
  border-top: 1px solid var(--border);
}
```

### 5.6 Badge (Бейдж)

```css
.badge {
  display: inline-flex;
  align-items: center;
  padding: 0.25rem 0.625rem;
  border-radius: var(--radius-full);
  font-size: var(--text-xs);
  font-weight: var(--font-medium);
  line-height: 1;
}

/* Варианты */
.badge-default {
  background: var(--primary-100);
  color: var(--primary-700);
}

.badge-success {
  background: var(--success-light);
  color: var(--success);
}

.badge-warning {
  background: var(--warning-light);
  color: var(--warning);
}

.badge-error {
  background: var(--error-light);
  color: var(--error);
}

.badge-info {
  background: var(--info-light);
  color: var(--info);
}
```

### 5.7 Avatar (Аватар)

```css
.avatar {
  width: 2.5rem;
  height: 2.5rem;
  border-radius: var(--radius-full);
  overflow: hidden;
  background: var(--primary-200);
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: var(--font-medium);
  color: var(--primary-600);
}

/* Размеры */
.avatar-sm { width: 2rem; height: 2rem; }
.avatar-md { width: 2.5rem; height: 2.5rem; }
.avatar-lg { width: 3rem; height: 3rem; }
.avatar-xl { width: 4rem; height: 4rem; }

.avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
```

### 5.8 Progress Bar

```css
.progress {
  width: 100%;
  height: 0.5rem;
  background: var(--primary-100);
  border-radius: var(--radius-full);
  overflow: hidden;
}

.progress-bar {
  height: 100%;
  background: var(--accent-primary);
  border-radius: var(--radius-full);
  transition: width 300ms ease;
}

/* С процентом */
.progress-with-label {
  display: flex;
  align-items: center;
  gap: var(--space-3);
}

.progress-label {
  font-size: var(--text-sm);
  font-weight: var(--font-medium);
  color: var(--foreground-secondary);
  min-width: 3rem;
  text-align: right;
}
```

### 5.9 Alert (Уведомление)

```css
.alert {
  padding: var(--space-4);
  border-radius: var(--radius-md);
  border: 1px solid;
  display: flex;
  gap: var(--space-3);
}

.alert-info {
  background: var(--info-light);
  border-color: var(--info);
  color: var(--info);
}

.alert-success {
  background: var(--success-light);
  border-color: var(--success);
  color: var(--success);
}

.alert-warning {
  background: var(--warning-light);
  border-color: var(--warning);
  color: var(--warning);
}

.alert-error {
  background: var(--error-light);
  border-color: var(--error);
  color: var(--error);
}

.alert-icon {
  flex-shrink: 0;
  width: 1.25rem;
  height: 1.25rem;
}

.alert-content {
  flex: 1;
}

.alert-title {
  font-weight: var(--font-semibold);
  margin-bottom: var(--space-1);
}

.alert-description {
  font-size: var(--text-sm);
  opacity: 0.9;
}
```

### 5.10 Dialog (Модальное окно)

```css
.dialog-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 50;
  backdrop-filter: blur(4px);
}

.dialog-content {
  position: fixed;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
  background: var(--background);
  border-radius: var(--radius-xl);
  box-shadow: var(--shadow-2xl);
  padding: var(--space-6);
  max-width: 32rem;
  width: calc(100% - 2rem);
  max-height: calc(100vh - 4rem);
  overflow-y: auto;
  z-index: 51;
}

.dialog-header {
  margin-bottom: var(--space-4);
}

.dialog-title {
  font-size: var(--text-2xl);
  font-weight: var(--font-semibold);
}

.dialog-description {
  font-size: var(--text-sm);
  color: var(--foreground-secondary);
  margin-top: var(--space-2);
}

.dialog-footer {
  margin-top: var(--space-6);
  display: flex;
  gap: var(--space-3);
  justify-content: flex-end;
}
```

### 5.11 Table (Таблица)

```css
.table-container {
  width: 100%;
  overflow-x: auto;
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
}

.table {
  width: 100%;
  border-collapse: collapse;
}

.table thead {
  background: var(--primary-50);
  position: sticky;
  top: 0;
  z-index: 10;
}

.table th {
  padding: var(--space-3) var(--space-4);
  text-align: left;
  font-size: var(--text-sm);
  font-weight: var(--font-semibold);
  color: var(--foreground);
  border-bottom: 1px solid var(--border);
}

.table td {
  padding: var(--space-3) var(--space-4);
  font-size: var(--text-sm);
  color: var(--foreground);
  border-bottom: 1px solid var(--border);
}

.table tbody tr:hover {
  background: var(--primary-50);
}

.table tbody tr:last-child td {
  border-bottom: none;
}
```

### 5.12 Tabs (Вкладки)

```css
.tabs {
  width: 100%;
}

.tabs-list {
  display: flex;
  gap: var(--space-1);
  border-bottom: 1px solid var(--border);
  margin-bottom: var(--space-6);
}

.tabs-trigger {
  padding: var(--space-3) var(--space-4);
  font-size: var(--text-sm);
  font-weight: var(--font-medium);
  color: var(--foreground-secondary);
  background: transparent;
  border: none;
  border-bottom: 2px solid transparent;
  cursor: pointer;
  transition: all 150ms ease;
}

.tabs-trigger:hover {
  color: var(--foreground);
}

.tabs-trigger[data-state="active"] {
  color: var(--accent-primary);
  border-bottom-color: var(--accent-primary);
}

.tabs-content {
  /* Контент вкладки */
}
```

---

## 6. ТЕМЫ (LIGHT/DARK)

### 6.1 Переключение тем

```typescript
// ThemeProvider управляет темой
const [theme, setTheme] = useState<'light' | 'dark'>('light');

// Применяем класс к HTML
document.documentElement.classList.toggle('dark', theme === 'dark');

// Сохраняем в localStorage
localStorage.setItem('theme', theme);
```

### 6.2 CSS переменные

Все переменные определены в разделе 2 для обеих тем.

```css
:root {
  /* Light mode variables */
}

.dark {
  /* Dark mode variables */
}
```

### 6.3 Принципы dark mode

1. **Не чисто черный** — используем темно-серый (#0a0e1a)
2. **Снижаем контраст** — более мягкие тени
3. **Инвертируем иерархию** — светлые элементы на темном фоне
4. **Сохраняем акценты** — цвета становятся ярче
5. **Тестируем читаемость** — контраст текста должен быть достаточным

### 6.4 Компонент переключателя темы

```tsx
// Переключатель (иконка солнца/луны)
<button onClick={toggleTheme} className="button-icon">
  {theme === 'light' ? <Moon size={20} /> : <Sun size={20} />}
</button>
```

**Позиция:** В Header справа, рядом с языком и аватаром.

---

## 7. АДАПТИВНЫЙ ДИЗАЙН

### 7.1 Breakpoints

```css
/* Mobile First */
/* 320px - 767px: базовые стили */

/* Tablet */
@media (min-width: 768px) {
  /* md: */
}

/* Laptop */
@media (min-width: 1024px) {
  /* lg: */
}

/* Desktop */
@media (min-width: 1280px) {
  /* xl: */
}

/* Large Desktop */
@media (min-width: 1536px) {
  /* 2xl: */
}
```

### 7.2 Адаптивная типографика

Размеры шрифтов растут с увеличением экрана (см. раздел 3.2).

### 7.3 Адаптивная навигация

#### Desktop (1024px+)

```
┌─────────────────────────────────────────┐
│  Header                                  │
├────────┬────────────────────────────────┤
│        │                                 │
│ Side   │  Main Content                  │
│ bar    │                                 │
│        │                                 │
│        │                                 │
└────────┴────────────────────────────────┘
```

**Sidebar:**
- Ширина: 280px
- Фиксированная позиция
- Логотип вверху
- Навигация списком
- Профиль внизу

#### Mobile (320px - 1023px)

```
┌─────────────────────────────┐
│  Header (с hamburger)       │
├─────────────────────────────┤
│                              │
│  Main Content (fullwidth)   │
│                              │
└─────────────────────────────┘
```

**Navigation:**
- Sheet (выдвижная панель) слева
- Открывается по hamburger меню
- Тот же контент что в Sidebar

### 7.4 Адаптивные карточки

#### Desktop: Grid 3 колонки

```css
.cards-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: var(--space-6);
}
```

#### Tablet: Grid 2 колонки

```css
@media (min-width: 768px) and (max-width: 1023px) {
  .cards-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}
```

#### Mobile: 1 колонка

```css
@media (max-width: 767px) {
  .cards-grid {
    grid-template-columns: 1fr;
    gap: var(--space-4);
  }
}
```

### 7.5 Адаптивные таблицы

**Desktop:** Обычная таблица

**Mobile:** Карточки вместо строк

```tsx
// На мобильных рендерим карточки
{isMobile ? (
  <div className="space-y-4">
    {data.map(item => (
      <Card key={item.id}>
        <div className="flex justify-between">
          <span className="font-medium">{item.name}</span>
          <Badge>{item.status}</Badge>
        </div>
        <p className="text-sm text-muted-foreground mt-2">
          {item.description}
        </p>
      </Card>
    ))}
  </div>
) : (
  <Table>...</Table>
)}
```

### 7.6 Touch-friendly элементы

**Минимальный размер touch target:** 44x44px (Apple HIG)

```css
/* Кнопки на мобильных */
@media (max-width: 767px) {
  .button {
    min-height: 2.75rem; /* 44px */
  }
  
  .button-icon {
    width: 2.75rem;
    height: 2.75rem;
  }
}
```

---

## 8. АНИМАЦИИ И ПЕРЕХОДЫ

### 8.1 Принципы

1. **Быстро, но заметно** — 150-300ms
2. **Ease кривые** — natural motion
3. **Минимализм** — не отвлекать
4. **Performance** — только transform и opacity

### 8.2 Transition Timings

```css
--transition-fast: 150ms;
--transition-base: 200ms;
--transition-slow: 300ms;
--transition-slower: 500ms;

--ease-in: cubic-bezier(0.4, 0, 1, 1);
--ease-out: cubic-bezier(0, 0, 0.2, 1);
--ease-in-out: cubic-bezier(0.4, 0, 0.2, 1);
```

### 8.3 Основные анимации

#### Fade In/Out

```css
@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes fadeOut {
  from { opacity: 1; }
  to { opacity: 0; }
}
```

#### Scale

```css
@keyframes scaleIn {
  from { 
    opacity: 0; 
    transform: scale(0.95); 
  }
  to { 
    opacity: 1; 
    transform: scale(1); 
  }
}
```

#### Slide

```css
@keyframes slideInFromLeft {
  from { transform: translateX(-100%); }
  to { transform: translateX(0); }
}

@keyframes slideInFromRight {
  from { transform: translateX(100%); }
  to { transform: translateX(0); }
}
```

### 8.4 Анимация переходов страниц

```css
.page-enter {
  animation: fadeIn var(--transition-fast) var(--ease-out);
}

.page-exit {
  animation: fadeOut var(--transition-fast) var(--ease-in);
}
```

### 8.5 Hover эффекты

```css
/* Кнопки */
.button:hover {
  transform: translateY(-1px);
  transition: all var(--transition-fast) var(--ease-out);
}

.button:active {
  transform: translateY(0);
}

/* Карточки */
.card:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
  transition: all var(--transition-base) var(--ease-out);
}

/* Ссылки */
.link {
  position: relative;
}

.link::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  width: 0;
  height: 2px;
  background: currentColor;
  transition: width var(--transition-base) var(--ease-out);
}

.link:hover::after {
  width: 100%;
}
```

### 8.6 Loading анимации

#### Spinner

```css
@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.spinner {
  animation: spin 1s linear infinite;
}
```

#### Skeleton (pulse)

```css
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

.skeleton {
  animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
  background: var(--primary-100);
  border-radius: var(--radius-md);
}
```

---

## 9. ИКОНОГРАФИЯ

### 9.1 Библиотека иконок

**Lucide React** — современные, консистентные иконки

```bash
npm install lucide-react
```

```tsx
import { User, Settings, LogOut, Menu } from 'lucide-react';

<User size={20} />
<Settings size={24} />
```

### 9.2 Размеры иконок

```css
--icon-xs: 14px;
--icon-sm: 16px;
--icon-md: 20px;
--icon-lg: 24px;
--icon-xl: 32px;
```

### 9.3 Использование

- **В кнопках:** 16-20px
- **В навигации:** 20-24px
- **Заголовки секций:** 24px
- **Hero секции:** 32px+

### 9.4 Цвет иконок

```css
/* По умолчанию - текущий цвет текста */
.icon {
  color: currentColor;
}

/* Вторичные иконки */
.icon-secondary {
  color: var(--foreground-secondary);
}

/* Акцентные */
.icon-primary {
  color: var(--accent-primary);
}
```

---

## 10. ДИЗАЙН СТРАНИЦ

### 10.1 Header (Шапка)

#### Структура

```
┌────────────────────────────────────────────────────────────────┐
│  [Logo + Name]          [Search]          [Tokens] [Lang] [Theme] [Avatar] │
└────────────────────────────────────────────────────────────────┘
```

#### Спецификация

```tsx
<header className="border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
  <div className="container flex h-16 items-center justify-between">
    {/* Left: Logo + Organization Name */}
    <div className="flex items-center gap-3">
      {isMobile && <HamburgerButton />}
      
      {logoUrl ? (
        <img src={logoUrl} alt={orgName} className="h-8 w-auto" />
      ) : (
        <Building2 className="h-8 w-8 text-primary" />
      )}
      
      <h1 className="text-xl font-semibold hidden md:block">
        {orgName}
      </h1>
    </div>
    
    {/* Center: Search (только для HR) */}
    {isHR && (
      <div className="flex-1 max-w-md mx-4 hidden lg:block">
        <SearchInput placeholder={t('search.placeholder')} />
      </div>
    )}
    
    {/* Right: Actions */}
    <div className="flex items-center gap-3">
      {isHR && (
        <TokenBalance balance={tokenBalance} />
      )}
      
      <LanguageSwitcher />
      <ThemeToggle />
      <UserMenu />
    </div>
  </div>
</header>
```

**Высота:** 64px (4rem)  
**Фон:** Слегка прозрачный с blur эффектом  
**Border:** Снизу, тонкая линия

#### Token Balance (Баланс токенов)

```tsx
<div className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-primary-50 dark:bg-primary-800">
  <Coins className="w-4 h-4 text-amber-500" />
  <span className="text-sm font-medium">
    {tokenBalance.toLocaleString()}
  </span>
</div>
```

### 10.2 Sidebar (Боковая панель)

#### Структура

```
┌─────────────────┐
│  Logo + Name    │
├─────────────────┤
│                 │
│  Navigation     │
│  - Dashboard    │
│  - Vacancies    │
│  - Candidates   │
│  - Talent Mkt   │
│  - Chat         │
│                 │
├─────────────────┤
│  User Profile   │
└─────────────────┘
```

#### Спецификация

```tsx
<aside className="w-[280px] border-r bg-background hidden lg:block">
  <div className="flex h-full flex-col">
    {/* Logo */}
    <div className="flex h-16 items-center border-b px-6">
      {/* Logo аналогично header */}
    </div>
    
    {/* Navigation */}
    <nav className="flex-1 space-y-1 p-4">
      <NavItem 
        icon={<LayoutDashboard />} 
        label={t('nav.dashboard')}
        href="/hr/dashboard"
        active={pathname === '/hr/dashboard'}
      />
      
      <NavItem 
        icon={<Briefcase />} 
        label={t('nav.vacancies')}
        href="/hr/vacancies"
        badge={activeVacancies}
      />
      
      <NavItem 
        icon={<Users />} 
        label={t('nav.candidates')}
        href="/hr/candidates"
        badge={totalCandidates}
      />
      
      <NavItem 
        icon={<Target />} 
        label={t('nav.talent_market')}
        href="/hr/talent-market"
      />
      
      <NavItem 
        icon={<MessageSquare />} 
        label={t('nav.chat')}
        href="/hr/chat"
        badge={unreadMessages}
        badgeVariant="primary"
      />
    </nav>
    
    {/* User Profile */}
    <div className="border-t p-4">
      <UserProfileCard />
    </div>
  </div>
</aside>
```

#### NavItem

```tsx
<Link 
  href={href}
  className={cn(
    "flex items-center gap-3 px-3 py-2 rounded-lg transition-colors",
    active 
      ? "bg-primary text-primary-foreground" 
      : "hover:bg-primary-50 dark:hover:bg-primary-800"
  )}
>
  {icon}
  <span className="flex-1 font-medium">{label}</span>
  {badge && (
    <Badge variant={badgeVariant}>{badge}</Badge>
  )}
</Link>
```

### 10.3 Dashboard (Дашборд)

#### HR Dashboard

**Layout:**

```
┌────────────────────────────────────────────┐
│  Stats Cards (Grid 4 col)                  │
├────────────────────────────────────────────┤
│  Tabs: Resume Analysis | Candidates | Vac  │
├────────────────────────────────────────────┤
│                                             │
│  Tab Content                                │
│                                             │
└────────────────────────────────────────────┘
```

**Stats Cards:**

```tsx
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
  <StatCard
    title={t('stats.total_candidates')}
    value={stats.totalCandidates}
    icon={<Users className="h-5 w-5" />}
    trend={+12}
    color="blue"
  />
  
  <StatCard
    title={t('stats.token_balance')}
    value={stats.tokenBalance}
    icon={<Coins className="h-5 w-5" />}
    color="amber"
  />
  
  <StatCard
    title={t('stats.active_vacancies')}
    value={stats.activeVacancies}
    icon={<Briefcase className="h-5 w-5" />}
    color="purple"
  />
  
  <StatCard
    title={t('stats.unread_messages')}
    value={stats.unreadMessages}
    icon={<MessageSquare className="h-5 w-5" />}
    color="green"
  />
</div>
```

**StatCard дизайн:**

```tsx
<Card className="relative overflow-hidden">
  <div className="absolute top-0 right-0 w-24 h-24 bg-{color}-50 dark:bg-{color}-900 rounded-full -mr-12 -mt-12 opacity-20" />
  
  <CardContent className="p-6">
    <div className="flex items-start justify-between">
      <div>
        <p className="text-sm font-medium text-muted-foreground">
          {title}
        </p>
        <p className="text-3xl font-bold mt-2">
          {value}
        </p>
        {trend && (
          <p className="text-sm text-green-600 mt-1 flex items-center gap-1">
            <TrendingUp className="w-4 h-4" />
            +{trend}% from last month
          </p>
        )}
      </div>
      
      <div className="p-3 bg-{color}-50 dark:bg-{color}-900 rounded-lg">
        {icon}
      </div>
    </div>
  </CardContent>
</Card>
```

#### Candidate Dashboard

**Layout:**

```
┌────────────────────────────────────────────┐
│  Welcome Banner                             │
├────────────────────────────────────────────┤
│  Profile Completeness Progress Bar          │
├────────────────────────────────────────────┤
│  Tests Grid (6 cards)                       │
├────────────────────────────────────────────┤
│  Recent Activity                            │
└────────────────────────────────────────────┘
```

**Welcome Banner:**

```tsx
<Card className="bg-gradient-to-r from-blue-500 to-blue-600 text-white">
  <CardContent className="p-6">
    <h2 className="text-2xl font-bold">
      {t('dashboard.welcome', { name: candidate.full_name })}
    </h2>
    <p className="mt-2 opacity-90">
      {t('dashboard.welcome_message')}
    </p>
  </CardContent>
</Card>
```

### 10.4 Vacancy Page (Страница вакансии)

**Layout:**

```
┌────────────────────────────────────────────┐
│  Back Button | Vacancy Title | Edit        │
├────────────────────────────────────────────┤
│  Info Card                   │ Funnel      │
│  - Description               │ (Sidebar)   │
│  - Requirements              │             │
│  - Skills                    │             │
│  - Ideal Profile             │             │
├──────────────────────────────┴─────────────┤
│  Candidates List                            │
│  (Cards or Table)                           │
└────────────────────────────────────────────┘
```

**Vacancy Funnel (Sidebar):**

```tsx
<Card className="sticky top-6">
  <CardHeader>
    <CardTitle>{t('vacancy.funnel')}</CardTitle>
  </CardHeader>
  <CardContent className="space-y-3">
    <FunnelStage
      label={t('status.invited')}
      count={15}
      active={filter === 'invited'}
      onClick={() => setFilter('invited')}
    />
    <FunnelStage label={t('status.registered')} count={12} />
    <FunnelStage label={t('status.testing')} count={10} />
    <FunnelStage label={t('status.tested')} count={8} />
    <FunnelStage label={t('status.interviewed')} count={3} />
    <FunnelStage label={t('status.offer')} count={1} />
    
    <Separator />
    
    <FunnelStage label={t('status.saved')} count={5} variant="secondary" />
    <FunnelStage label={t('status.rejected')} count={4} variant="destructive" />
  </CardContent>
</Card>
```

### 10.5 Candidate Profile (Профиль кандидата)

**Layout:**

```
┌────────────────────────────────────────────┐
│  Back | Candidate Name | Actions Dropdown  │
├────────────────────────────────────────────┤
│  Avatar & Info Card      │  Quick Stats    │
│  - Name, Category        │  - Tests: 6/6   │
│  - Contact               │  - Score: 87%   │
│  - Skills                │  - Status       │
├──────────────────────────┴─────────────────┤
│  Tabs:                                      │
│  - Tests Results                            │
│  - Full Analysis                            │
│  - Documents                                │
│  - Activity Log                             │
└────────────────────────────────────────────┘
```

**Actions Dropdown:**

```tsx
<DropdownMenu>
  <DropdownMenuTrigger>
    <Button variant="outline">
      {t('actions')}
      <ChevronDown className="ml-2 h-4 w-4" />
    </Button>
  </DropdownMenuTrigger>
  
  <DropdownMenuContent align="end" className="w-48">
    <DropdownMenuItem onClick={generateFullAnalysis}>
      <FileText className="mr-2 h-4 w-4" />
      {t('actions.full_analysis')}
    </DropdownMenuItem>
    
    <DropdownMenuItem onClick={generateInterview}>
      <Users className="mr-2 h-4 w-4" />
      {t('actions.interview_guide')}
    </DropdownMenuItem>
    
    <DropdownMenuItem onClick={sendInvitation}>
      <Mail className="mr-2 h-4 w-4" />
      {t('actions.send_invitation')}
    </DropdownMenuItem>
    
    <DropdownMenuItem onClick={sendOffer}>
      <Gift className="mr-2 h-4 w-4" />
      {t('actions.send_offer')}
    </DropdownMenuItem>
    
    <DropdownMenuSeparator />
    
    <DropdownMenuItem onClick={changeStatus}>
      <Tag className="mr-2 h-4 w-4" />
      {t('actions.change_status')}
    </DropdownMenuItem>
    
    <DropdownMenuItem onClick={openChat}>
      <MessageSquare className="mr-2 h-4 w-4" />
      {t('actions.open_chat')}
    </DropdownMenuItem>
    
    <DropdownMenuSeparator />
    
    <DropdownMenuItem onClick={sendRejection} className="text-red-600">
      <XCircle className="mr-2 h-4 w-4" />
      {t('actions.send_rejection')}
    </DropdownMenuItem>
  </DropdownMenuContent>
</DropdownMenu>
```

### 10.6 Talent Market (Рынок талантов)

**Layout:**

```
┌────────────────────────────────────────────┐
│  Info Alert                                 │
├────────────────────────────────────────────┤
│  Filters Sidebar    │  Candidates Grid     │
│  - Vacancy Select   │  - Card 1            │
│  - Category         │  - Card 2            │
│  - Skills           │  - Card 3            │
│  - Min Score        │  ...                 │
│  - Test Freshness   │                      │
└────────────────────┴────────────────────────┘
```

**Candidate Card (Talent Market):**

```tsx
<Card className="hover:shadow-lg transition-all cursor-pointer">
  <CardContent className="p-6">
    {/* Header */}
    <div className="flex items-start gap-4">
      <Avatar className="h-16 w-16">
        <AvatarImage src={candidate.avatar} />
        <AvatarFallback>{candidate.initials}</AvatarFallback>
      </Avatar>
      
      <div className="flex-1">
        <h3 className="font-semibold text-lg">{candidate.full_name}</h3>
        <p className="text-sm text-muted-foreground">
          {candidate.category}
        </p>
        <div className="flex items-center gap-2 mt-2">
          <Badge variant="outline">{candidate.tests_completed}/6 tests</Badge>
          <TestFreshnessIndicator freshness={candidate.test_freshness} />
        </div>
      </div>
      
      <div className="text-right">
        <div className="text-3xl font-bold text-primary">
          {candidate.compatibility_score}%
        </div>
        <p className="text-xs text-muted-foreground">match</p>
      </div>
    </div>
    
    {/* Compatibility Breakdown */}
    <div className="mt-4 space-y-2">
      <div className="flex items-center justify-between text-sm">
        <span className="text-muted-foreground">
          {t('talent_market.professional')}
        </span>
        <ProgressBar value={candidate.skills_score} variant="blue" />
        <span className="font-medium ml-3 min-w-[3rem] text-right">
          {candidate.skills_score}%
        </span>
      </div>
      
      <div className="flex items-center justify-between text-sm">
        <span className="text-muted-foreground">
          {t('talent_market.personality')}
        </span>
        <ProgressBar value={candidate.personality_score} variant="purple" />
        <span className="font-medium ml-3 min-w-[3rem] text-right">
          {candidate.personality_score}%
        </span>
      </div>
    </div>
    
    {/* Skills */}
    <div className="mt-4">
      <div className="flex flex-wrap gap-2">
        {candidate.top_skills.map(skill => (
          <Badge key={skill} variant="secondary">
            {skill}
          </Badge>
        ))}
      </div>
    </div>
    
    {/* Footer */}
    <div className="mt-4 pt-4 border-t flex items-center justify-between">
      <div className="flex items-center gap-2 text-sm text-muted-foreground">
        <Eye className="h-4 w-4" />
        <span>{t('talent_market.purchased_times', { count: candidate.times_purchased })}</span>
      </div>
      
      <Button size="sm" onClick={() => acquireCandidate(candidate.id)}>
        <Plus className="mr-2 h-4 w-4" />
        {t('talent_market.add_candidate')} (500)
      </Button>
    </div>
  </CardContent>
</Card>
```

### 10.7 Test Taking Page (Прохождение теста)

**Layout:**

```
┌────────────────────────────────────────────┐
│  Progress Bar (Question 5 of 50)           │
├────────────────────────────────────────────┤
│                                             │
│  Question Text (Large, centered)           │
│                                             │
│  [ ] Option A                              │
│  [ ] Option B                              │
│  [ ] Option C                              │
│  [ ] Option D                              │
│  [ ] Option E                              │
│                                             │
│  [Back]                    [Next/Finish]   │
└────────────────────────────────────────────┘
```

**Дизайн:**
- Минималистичный, ничего лишнего
- Крупный текст вопроса
- Большие clickable области для ответов
- Прогресс-бар вверху
- Автосохранение

```tsx
<div className="min-h-screen flex flex-col">
  {/* Progress */}
  <div className="border-b bg-background">
    <div className="container py-4">
      <div className="flex items-center justify-between mb-2">
        <span className="text-sm font-medium">
          {t('test.question_progress', { current, total })}
        </span>
        <span className="text-sm text-muted-foreground">
          {Math.round((current / total) * 100)}%
        </span>
      </div>
      <Progress value={(current / total) * 100} />
    </div>
  </div>
  
  {/* Question */}
  <div className="flex-1 container py-12">
    <div className="max-w-3xl mx-auto">
      <h2 className="text-2xl font-semibold text-center mb-12">
        {question.text}
      </h2>
      
      <div className="space-y-3">
        {question.options.map((option, index) => (
          <label 
            key={index}
            className={cn(
              "flex items-center gap-4 p-6 border-2 rounded-xl cursor-pointer transition-all",
              "hover:border-primary hover:bg-primary-50",
              selectedAnswer === index && "border-primary bg-primary-50"
            )}
          >
            <input
              type="radio"
              name="answer"
              value={index}
              checked={selectedAnswer === index}
              onChange={() => setSelectedAnswer(index)}
              className="w-5 h-5"
            />
            <span className="text-lg">{option}</span>
          </label>
        ))}
      </div>
    </div>
  </div>
  
  {/* Navigation */}
  <div className="border-t bg-background">
    <div className="container py-4 flex justify-between">
      <Button 
        variant="outline" 
        onClick={goBack}
        disabled={current === 1}
      >
        <ChevronLeft className="mr-2 h-4 w-4" />
        {t('test.back')}
      </Button>
      
      <Button 
        onClick={goNext}
        disabled={selectedAnswer === null}
      >
        {current === total ? t('test.finish') : t('test.next')}
        {current !== total && <ChevronRight className="ml-2 h-4 w-4" />}
      </Button>
    </div>
  </div>
</div>
```

### 10.8 Chat Page (Чат)

**Layout:**

```
┌────────────────────────────────────────────┐
│  Chats List (Sidebar)  │  Active Chat     │
│  - Chat 1              │  ┌─────────────┐ │
│  - Chat 2 (unread: 3)  │  │ Messages    │ │
│  - Chat 3              │  │             │ │
│                        │  │             │ │
│                        │  └─────────────┘ │
│                        │  [Input] [Send]  │
└────────────────────────┴──────────────────┘
```

**Chat List Item:**

```tsx
<button
  className={cn(
    "w-full p-4 flex items-start gap-3 hover:bg-primary-50 transition-colors",
    "border-b",
    active && "bg-primary-50 border-l-4 border-l-primary"
  )}
  onClick={() => selectChat(chat.id)}
>
  <Avatar className="h-12 w-12">
    <AvatarImage src={chat.avatar} />
    <AvatarFallback>{chat.initials}</AvatarFallback>
  </Avatar>
  
  <div className="flex-1 min-w-0">
    <div className="flex items-center justify-between mb-1">
      <p className="font-medium truncate">{chat.name}</p>
      <span className="text-xs text-muted-foreground">
        {formatTime(chat.last_message_at)}
      </span>
    </div>
    
    <p className="text-sm text-muted-foreground truncate">
      {chat.last_message_text}
    </p>
  </div>
  
  {chat.unread > 0 && (
    <Badge className="ml-2 bg-primary text-primary-foreground">
      {chat.unread}
    </Badge>
  )}
</button>
```

**Message Bubble:**

```tsx
{/* My message */}
<div className="flex justify-end mb-4">
  <div className="max-w-[70%] bg-primary text-primary-foreground rounded-2xl rounded-tr-sm px-4 py-3">
    <p className="text-sm">{message.text}</p>
    <span className="text-xs opacity-70 mt-1 block">
      {formatTime(message.created_at)}
    </span>
  </div>
</div>

{/* Their message */}
<div className="flex justify-start mb-4">
  <div className="flex items-start gap-2">
    <Avatar className="h-8 w-8">
      <AvatarImage src={sender.avatar} />
      <AvatarFallback>{sender.initials}</AvatarFallback>
    </Avatar>
    
    <div className="max-w-[70%] bg-secondary rounded-2xl rounded-tl-sm px-4 py-3">
      <p className="text-sm">{message.text}</p>
      <span className="text-xs text-muted-foreground mt-1 block">
        {formatTime(message.created_at)}
      </span>
    </div>
  </div>
</div>
```

---

## 11. СОСТОЯНИЯ ИНТЕРФЕЙСА

### 11.1 Loading States

#### Skeleton Loaders

```tsx
// Card Skeleton
<Card>
  <CardContent className="p-6">
    <Skeleton className="h-6 w-[200px] mb-4" />
    <Skeleton className="h-4 w-full mb-2" />
    <Skeleton className="h-4 w-[80%]" />
  </CardContent>
</Card>

// Table Skeleton
<div className="space-y-3">
  {Array.from({ length: 5 }).map((_, i) => (
    <Skeleton key={i} className="h-12 w-full" />
  ))}
</div>
```

#### Spinner

```tsx
<div className="flex items-center justify-center p-12">
  <Loader2 className="h-8 w-8 animate-spin text-primary" />
</div>
```

#### Progress Bar

```tsx
<div className="space-y-2">
  <p className="text-sm text-muted-foreground">
    {t('loading.analyzing')}
  </p>
  <Progress value={progress} />
  <p className="text-xs text-muted-foreground text-right">
    {progress}%
  </p>
</div>
```

### 11.2 Empty States

```tsx
<Card className="p-12">
  <div className="flex flex-col items-center text-center">
    <div className="h-16 w-16 rounded-full bg-primary-100 flex items-center justify-center mb-4">
      <Inbox className="h-8 w-8 text-primary" />
    </div>
    
    <h3 className="text-xl font-semibold mb-2">
      {t('empty.no_candidates')}
    </h3>
    
    <p className="text-muted-foreground mb-6 max-w-md">
      {t('empty.no_candidates_description')}
    </p>
    
    <Button>
      <Plus className="mr-2 h-4 w-4" />
      {t('actions.invite_candidate')}
    </Button>
  </div>
</Card>
```

### 11.3 Error States

```tsx
<Alert variant="destructive">
  <AlertCircle className="h-4 w-4" />
  <AlertTitle>{t('error.title')}</AlertTitle>
  <AlertDescription>
    {error.message}
  </AlertDescription>
  <Button 
    variant="outline" 
    size="sm" 
    className="mt-3"
    onClick={retry}
  >
    {t('actions.try_again')}
  </Button>
</Alert>
```

### 11.4 Success States

```tsx
// Toast Notification
toast({
  title: t('success.candidate_invited'),
  description: t('success.candidate_invited_description'),
  variant: "success",
  duration: 3000
});

// Success Banner
<Alert variant="success" className="mb-6">
  <CheckCircle2 className="h-4 w-4" />
  <AlertTitle>{t('success.title')}</AlertTitle>
  <AlertDescription>
    {t('success.description')}
  </AlertDescription>
</Alert>
```

---

## 12. ACCESSIBILITY

### 12.1 Принципы WCAG 2.1 Level AA

1. **Perceivable** — информация воспринимается
2. **Operable** — интерфейс управляем
3. **Understandable** — понятный контент
4. **Robust** — совместимость с assistive tech

### 12.2 Контраст

**Минимальные требования:**
- Обычный текст: 4.5:1
- Крупный текст (18px+): 3:1
- UI элементы: 3:1

**Тестирование:**
- Использовать инструмент контраста в DevTools
- Проверять оба режима (light/dark)

### 12.3 Keyboard Navigation

**Требования:**
- Все интерактивные элементы доступны с клавиатуры
- Видимый focus indicator
- Логичный порядок табуляции
- Escape закрывает модалки
- Enter/Space активирует кнопки

```css
/* Focus styles */
*:focus-visible {
  outline: 2px solid var(--accent-primary);
  outline-offset: 2px;
}

button:focus-visible,
a:focus-visible,
input:focus-visible {
  box-shadow: 0 0 0 3px var(--accent-primary-light);
}
```

### 12.4 ARIA Labels

```tsx
// Кнопки без текста
<button aria-label={t('actions.close')}>
  <X className="h-4 w-4" />
</button>

// Inputs
<label htmlFor="email">{t('form.email')}</label>
<input 
  id="email" 
  type="email"
  aria-describedby="email-hint"
  aria-invalid={!!errors.email}
/>
{errors.email && (
  <p id="email-error" role="alert" className="text-error text-sm">
    {errors.email.message}
  </p>
)}

// Loading states
<div role="status" aria-live="polite">
  {loading && <Spinner />}
  <span className="sr-only">{t('loading.message')}</span>
</div>
```

### 12.5 Screen Reader Support

```tsx
// Skip to main content
<a 
  href="#main-content" 
  className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 focus:z-50"
>
  {t('a11y.skip_to_content')}
</a>

// Visually hidden but readable by SR
<span className="sr-only">{description}</span>

// sr-only class
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border-width: 0;
}
```

### 12.6 Semantic HTML

```tsx
// Правильная структура заголовков
<h1>{pageTitle}</h1>
<section>
  <h2>{sectionTitle}</h2>
  <article>
    <h3>{articleTitle}</h3>
  </article>
</section>

// Использование правильных элементов
<nav aria-label="Main navigation">...</nav>
<main id="main-content">...</main>
<aside aria-label="Filters">...</aside>
<footer>...</footer>
```

---

## ЗАКЛЮЧЕНИЕ

Этот дизайн-документ определяет полную визуальную систему HR Platform — от цветов и типографики до конкретных компонентов и страниц.

**Ключевые характеристики дизайна:**

✅ **Современный** — актуальные тренды, gradients, smooth transitions  
✅ **Минималистичный** — ничего лишнего, фокус на контенте  
✅ **Профессиональный** — серьезный, но не скучный  
✅ **Адаптивный** — идеально работает от 320px до 4K  
✅ **Доступный** — WCAG 2.1 AA, keyboard navigation, screen readers  
✅ **Темы** — продуманный dark mode  
✅ **Консистентный** — единая система во всем приложении

**Технические детали:**

- Все размеры, отступы, цвета определены через CSS переменные
- Используется Tailwind CSS для быстрой разработки
- shadcn/ui как основа компонентов
- Lucide React для иконок
- Inter как шрифт
- Простые, но эффектные анимации

**Следующие шаги:**

1. Изучить дизайн-систему
2. Применять при разработке каждого компонента
3. Тестировать на разных устройствах
4. Проверять контрастность
5. Валидировать accessibility

Этот дизайн создаст впечатление профессионального, современного инструмента, которым приятно пользоваться! 🎨✨

---

**Документ подготовлен:** 2025-11-12  
**Версия:** 1.0  
**Статус:** Production-Ready Design System
