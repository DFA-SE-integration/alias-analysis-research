---
name: PhASAR Test-Suite validation patch
overview: Пропатчить PhASAR по аналогии с SVF: для каждого выбранного alias-анализа (cflanders, cflsteens и т.д.) после построения alias-модели выполнять один проход по ней и сверять с макросами aliascheck.h (MAYALIAS/NOALIAS/MUSTALIAS), с выводом SUCCESS/FAILURE и exit(1) при FAILURE. Без нового вида анализа; патчи хранить в patches/phasar/ и накладывать через scripts/apply_phasar_patches.sh.
todos: []
isProject: false
---

# Патч PhASAR: встраивание проверки aliascheck.h по образцу SVF

## Цель

**Встроить проверку как в SVF:** не вводить новый тип data-flow анализа, а для **каждого** выбранного alias-анализа после построения alias-модели выполнять один проход: обойти модуль, найти вызовы MAYALIAS/NOALIAS/MUSTALIAS из [aliascheck.h](tests/Test-Suite/aliascheck.h), для каждой пары аргументов запросить у **уже построенной** alias-модели результат, сравнить с ожиданием и вывести **SUCCESS** или **FAILURE**; при любой FAILURE — `exit(1)`.

- Какой анализ проверяется: тот, что выбран через `--alias-analysis` (cflanders, cflsteens, basic и т.д.). Модель уже построена в `HelperAnalyses` (HA); проверка просто итерирует модуль и дергает `HA.getAliasInfo().alias(V1, V2, I)`.
- Отдельного режима «только валидация» или нового типа анализа не добавляем: проверка всегда выполняется после построения HA, по аналогии с `validateTests()` в SVF.

**Хранение патчей:** все изменения PhASAR хранятся в `patches/phasar/` и накладываются скриптом `scripts/apply_phasar_patches.sh` после checkout, чтобы на другой машине процесс воспроизводился без потерь.

---

## Хранение и наложение патчей PhASAR

### Принцип

- В репозитории **alias-analysis-research** патчи для PhASAR не вносятся напрямую в каталог `phasar/`. Они лежат в **отдельной директории** (например `patches/phasar/`) в корне проекта.
- Наложение выполняется **специальным скриптом** (например `scripts/apply_phasar_patches.sh`). Скрипт вызывается после `01_checkout_sources.sh` и до `02_build_phasar.sh` (или внутри шага сборки PhASAR).
- На новой машине: клонирование репозитория → `checkout` (чистый PhASAR) → запуск скрипта наложения патчей → сборка PhASAR. Изменения воспроизводятся без ручного редактирования дерева phasar.

### Структура

- **Директория с патчами:** `patches/phasar/` в корне проекта.
  - Файлы: `001-validate-alias-tests.patch`, `002-… .patch` и т.д. (порядок в имени задаёт порядок применения, если скрипт применяет по сортировке).
  - Каждый патч создаётся из изменённого дерева phasar командой `git diff` / `git format-patch` относительно коммита, на который указывает checkout (например `055babd2f0a24597b9f2a9953b42dabe1fcb22ec`).
- **Скрипт наложения:** `scripts/apply_phasar_patches.sh`.
  - Входные данные: `ROOT` (корень репо), каталог PhASAR `$ROOT/phasar`, каталог патчей `$ROOT/patches/phasar`.
  - Действия: перейти в `phasar`, для каждого `.patch` из `patches/phasar/` (в заданном порядке) выполнить `git apply` (или `patch -p1`). При ошибке — вывести сообщение и выйти с ненулевым кодом.
  - Идемпотентность: если патч уже применён, `git apply` может отказываться; скрипт может проверять статус (`git apply --check`) и пропускать уже наложенные, либо применять с `--reverse` для проверки. Простой вариант: применять по порядку и при первой ошибке останавливаться.

### Интеграция в цепочку сборки

- **Вариант A:** Отдельный шаг в Makefile, например `apply-phasar-patches`, зависящий от `checkout`; цель `tools-phasar` зависит от `apply-phasar-patches`. Пользователь вызывает `make checkout`, затем `make apply-phasar-patches` (или один раз `make tools-phasar`, который тянет за собой checkout и apply).
- **Вариант B:** В [scripts/02_build_phasar.sh](scripts/02_build_phasar.sh) в начале вызвать `scripts/apply_phasar_patches.sh` (если каталог `patches/phasar` существует и не пуст). Тогда `make tools-phasar` после checkout автоматически наложит патчи и соберёт PhASAR.

Рекомендация: **Вариант B** — в начале `02_build_phasar.sh` вызывать скрипт наложения патчей; так на любой машине достаточно `make checkout` и `make tools-phasar`, без отдельной цели для apply.

### Создание патча после внесения изменений

1. Внести изменения в локальное дерево `phasar/` (как описано в разделах ниже).
2. Из корня репозитория: `cd phasar && git diff > ../patches/phasar/001-validate-alias-tests.patch` (или `git format-patch -1 --stdout > ...` для одного коммита). Убедиться, что пути в патче относительные от корня phasar (`a/tools/...`, `b/tools/...`).
3. Закоммитить только файлы в `patches/phasar/` и `scripts/apply_phasar_patches.sh`; каталог `phasar/` остаётся неподтверждённым (или в .gitignore, если он не коммитится). На другой машине после clone + checkout будет чистый phasar, затем apply при сборке наложит патч.

### Чеклист по патчам и скрипту

- Создать директорию `patches/phasar/` в корне проекта.
- Реализовать `scripts/apply_phasar_patches.sh`: обход `patches/phasar/*.patch`, применение из каталога `phasar/` (`git apply --whitespace=fix` или `patch -p1 < ...`), обработка ошибок.
- В начале `02_build_phasar.sh` вызывать `apply_phasar_patches.sh` (если есть `patches/phasar` и в нём есть .patch).
- После реализации функциональности валидации сгенерировать патч и положить в `patches/phasar/` (например `001-validate-alias-tests.patch`).
- При необходимости добавить в Makefile цель `apply-phasar-patches` и зависимость от неё для `tools-phasar` (если решите вызывать apply отдельно от сборки).

---

## Архитектура

```mermaid
flowchart TB
  subgraph main [phasar-cli main]
    A[Parse CLI]
    B[Build HelperAnalyses HA\nalias model for selected --alias-analysis]
    C[runValidateAliasTests(HA)]
    D{Validation OK?}
    E[exit 1]
    F[Create AnalysisController]
    G[Controller.run]
  end
  A --> B
  B --> C
  C --> D
  D -->|any FAILURE| E
  D -->|all SUCCESS| F
  F --> G
```

- **Как в SVF:** после построения alias-модели (HelperAnalyses) один раз выполняется проход по модулю: поиск вызовов MAYALIAS/NOALIAS/MUSTALIAS, запрос к построенной модели через `HA.getAliasInfo().alias(V1, V2, I)`, сравнение с ожиданием, вывод SUCCESS/FAILURE. Для какого анализа — определяется выбранным `--alias-analysis` (cflanders, cflsteens и т.д.); отдельного «вида анализа» не вводим.
- **Место вызова:** в [phasar-cli.cpp](phasar/tools/phasar-cli/phasar-cli.cpp) в main сразу после построения `HelperAnalyses` и проверки `isValid()`: вызвать `runValidateAliasTests(HA)`; при возврате `false` — `exit(1)`. Дальше как сейчас: создаётся AnalysisController и выполняется `Controller.run()`.

---

## Ключевые файлы и изменения

### 1. Функция валидации (проход по построенной alias-модели)

- **Файл:** новый [phasar/tools/phasar-cli/ValidateAliasTests.cpp](phasar/tools/phasar-cli/ValidateAliasTests.cpp) (и при необходимости .h), либо логика в [phasar-cli.cpp](phasar/tools/phasar-cli/phasar-cli.cpp).
- **Сигнатура:** `bool runValidateAliasTests(HelperAnalyses &HA)` — возвращает `false`, если была хотя бы одна FAILURE.
- **Логика:** обход модуля из `HA.getProjectIRDB()`, поиск вызовов MAYALIAS/NOALIAS/MUSTALIAS/PARTIALALIAS (и манглированных имён), запрос к **уже построенной** alias-модели: `HA.getAliasInfo().alias(V1, V2, CallInst)`, сравнение с ожиданием, вывод SUCCESS/FAILURE. Код самих анализаторов (CFLAnders, CFLSteens и т.д.) не меняется — используется только их результат в AliasInfo.

### 2. Встраивание в пайплайн (main, как в SVF)

- **Файл:** [phasar/tools/phasar-cli/phasar-cli.cpp](phasar/tools/phasar-cli/phasar-cli.cpp)
- После построения `HelperAnalyses HA(...)` и проверки `if (!HA.getProjectIRDB().isValid()) return 1;`: вызвать `runValidateAliasTests(HA)`; при возврате `false` — `exit(1)`. Условие по типу alias-анализа не ставим: проверка выполняется для **любого** выбранного `--alias-analysis` (cflanders, cflsteens, basic и т.д.), так как для каждого из них после построения HA имеется одна построенная alias-модель, по которой и делается проход.

### 3. Логика валидации (алгоритм runValidateAliasTests)

**Алгоритм:**

1. Взять модуль из `HA.getProjectIRDB().getModule()` (или обход по всем модулям IRDB, если их несколько).
2. Имена проверяемых функций (как в SVF):
  - Успех: `MAYALIAS`, `NOALIAS`, `MUSTALIAS`, `PARTIALALIAS`
  - Манглированные (C++): `_Z8MAYALIASPvS_`, `_Z7NOALIASPvS_`, `_Z9MUSTALIASPvS_`, `_Z12PARTIALALIASPvS_`
  - Опционально (фаза 2): `EXPECTEDFAIL_MAYALIAS`, `EXPECTEDFAIL_NOALIAS` и их манглированные имена — ожидаемая «неудача» (результат анализа должен не совпадать с именем аннотации).
3. Обход по всем функциям модуля → по всем базовым блокам → по всем инструкциям. Для каждой `CallInst`:
  - Получить вызываемую функцию (`getCalledFunction()` или через значение при косвенном вызове; для Test-Suite вызовы обычно прямые).
  - Если имя не из списка выше — пропустить.
  - Взять аргументы: `getArgOperand(0)`, `getArgOperand(1)` (два указателя).
  - Вызов: `AliasResult result = HA.getAliasInfo().alias(V1, V2, CallInst)` (третий аргумент — контекстная инструкция для чувствительных к контексту анализов).
4. Правила проверки (совпадают с SVF):
  - **MAYALIAS:** успех, если `result == MayAlias || result == MustAlias`
  - **NOALIAS:** успех, если `result == NoAlias`
  - **MUSTALIAS:** успех, если `result == MayAlias || result == MustAlias`
  - **PARTIALALIAS:** успех, если `result == MayAlias` (при желании можно учесть PartialAlias, если PhASAR его возвращает)
5. Вывод в stdout/stderr (единообразно с SVF):
  - При успехе: строка вида `\t SUCCESS :MAYALIAS check <...> at (SourceLoc)\n`
  - При неудаче: строка вида `\t FAILURE :NOALIAS check <...> at (SourceLoc)\n`
  - SourceLoc можно получить через `llvm::Instruction::getDebugLoc()` и форматировать (файл:строка:столбец) или использовать существующие утилиты PhASAR ([phasar/include/phasar/PhasarLLVM/Utils/LLVMIRToSrc.h](phasar/include/phasar/PhasarLLVM/Utils/LLVMIRToSrc.h) — `getDebugLocation(V)`).
6. По завершении обхода: вернуть `true`, если все проверки SUCCESS; `false` при хотя бы одной FAILURE. Вызывающий код (main) при `false` выполняет `exit(1)`.

### 4. Зависимости и API

- **AliasInfo:** уже есть метод `alias(Pointer1, Pointer2, AtInstruction)` → `AliasResult` ([phasar/include/phasar/Pointer/AliasInfo.h](phasar/include/phasar/Pointer/AliasInfo.h) — строки 110–115).
- **AliasResult:** в PhASAR есть `NoAlias`, `MayAlias`, `PartialAlias`, `MustAlias` ([phasar/include/phasar/Pointer/AliasResult.def](phasar/include/phasar/Pointer/AliasResult.def)).
- Итерация модуля: стандартный обход `Module::functions()` → `Function::basic_blocks()` → `BasicBlock::instructions()`; для каждой инструкции проверка `isa<CallInst>` и работа с `CallInst`.

### 5. Использование из командной строки

Проверка выполняется при **любом** запуске phasar-cli после построения alias-модели (для выбранного `--alias-analysis`):

```bash
phasar-cli -m module.bc --entry-points=__ALL__ --alias-analysis=cflanders
phasar-cli -m module.bc --entry-points=__ALL__ --alias-analysis=cflsteens -D ifds-solvertest
phasar-cli -m module.bc --entry-points=__ALL__ --alias-analysis=basic
```

Отдельного режима «только валидация» нет — как в SVF, валидация встроена в пайплайн после построения alias-модели.

### 6. Интеграция в скрипты репозитория (вне патча PhASAR)

- В [scripts/04_run_svf_tsuite.sh](scripts/04_run_svf_tsuite.sh) (или в отдельном скрипте для PhASAR) можно добавить ветку для категорий, которые решено гонять через PhASAR: вызывать `phasar-cli -m "$f" --entry-points=__ALL__ --alias-analysis=...` и перенаправлять вывод в тот же каталог результатов (например `results/Test-Suite/PhASAR/...`). Это можно оформить отдельным маленьким шагом после принятия патча.

---

## Ограничения и опциональные расширения

- **EXPECTEDFAIL_***: в первом варианте патча можно не реализовывать; при необходимости — отдельный проход по тем же вызовам с инвертированной проверкой и меткой «expected failure».
- **Косвенные вызовы:** если в Test-Suite все вызовы MAYALIAS/NOALIAS — прямые, достаточно проверять `getCalledFunction()`; иначе нужно разрешать указатель на функцию (по текущему alias-анализу) и проверять имена целевых функций.
- **Несколько модулей:** если IRDB содержит несколько модулей, обход нужно выполнять по всем модулям, в которых могут быть такие вызовы.

---

## Сводка: встраивание проверки по образцу SVF

- **Когда срабатывает:** при любом запуске phasar-cli после построения alias-модели (для выбранного `--alias-analysis`: cflanders, cflsteens, basic и т.д.).
- **Где вызывается:** в [phasar-cli.cpp](phasar/tools/phasar-cli/phasar-cli.cpp) в main, сразу после построения `HelperAnalyses` и проверки `isValid()`.
- **Что используется:** уже построенный `HA.getAliasInfo()` — один проход по модулю, запрос `alias(V1, V2, I)` для каждой пары из MAYALIAS/NOALIAS/MUSTALIAS; код самих анализаторов не меняется.
- **При FAILURE:** `exit(1)`, дальнейшие анализы не запускаются.
- **Отдельного режима «только валидация» или нового типа анализа нет** — проверка встроена в пайплайн, как `validateTests()` в SVF.


---

## Чеклист реализации

**Патчи и скрипт наложения (чтобы изменения не терялись при checkout на другой машине):**

1. Создать директорию `patches/phasar/` в корне репозитория.
2. Реализовать [scripts/apply_phasar_patches.sh](scripts/apply_phasar_patches.sh): применение всех `patches/phasar/*.patch` к дереву `phasar/` (например `git apply` из каталога phasar), обработка ошибок, ненулевой код выхода при сбое.
3. В начале [scripts/02_build_phasar.sh](scripts/02_build_phasar.sh) вызывать `apply_phasar_patches.sh` (если есть каталог `patches/phasar` и в нём есть .patch-файлы).

**Функциональность валидации (в дереве phasar, затем экспорт в патч):**

1. Реализовать `runValidateAliasTests(HelperAnalyses &HA)` (поиск вызовов MAYALIAS/NOALIAS/MUSTALIAS/PARTIALALIAS, запрос к построенной модели `HA.getAliasInfo().alias(V1,V2,I)`, печать SUCCESS/FAILURE, возврат bool) — в новом файле под phasar-cli или в phasar-cli.cpp.
2. В [phasar-cli.cpp](phasar/tools/phasar-cli/phasar-cli.cpp): после построения HA вызвать `runValidateAliasTests(HA)`; при возврате `false` — `exit(1)`. Условие по типу alias-анализа не ставить — проверка для любого выбранного `--alias-analysis`.
3. Хелпер для source location (getDebugLoc / getDebugLocation) при выводе.
4. Сгенерировать патч из изменённого дерева phasar и положить в `patches/phasar/` (например `001-validate-alias-tests.patch`).
5. Сборка и прогон на .bc из Test-Suite с `--alias-analysis=cflanders` и `--alias-analysis=cflsteens` (после apply патча).
6. (Опционально) Интеграция вызова phasar-cli в скрипты репозитория и обновление README.

