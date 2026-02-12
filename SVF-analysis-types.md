# Виды анализа в SVF (Pointer Analysis)

Документ описывает типы pointer/alias-анализа, поддерживаемые в SVF, соответствующие опции командной строки и инструменты (wpa, dvf, cfl, saber).

---

## 1. WPA — Whole Program Pointer Analysis (инструмент `wpa`)

Инструмент `wpa` выполняет whole-program points-to анализ. Выбор конкретного анализа задаётся одной из опций ниже (можно указать несколько).

| Опция      | Тип анализа (PTATY)        | Описание |
|-----------|-----------------------------|----------|
| **`-ander`**   | AndersenWaveDiff_WPA        | Andersen-style анализ с diff wave propagation (часто используется по умолчанию для базовых тестов). |
| **`-nander`**  | Andersen_WPA                | Стандартный inclusion-based анализ (базовый Andersen). |
| **`-sander`**  | AndersenSCD_WPA             | Inclusion-based с selective cycle detection. |
| **`-sfrander`**| AndersenSFR_WPA             | Stride-based field representation, inclusion-based. |
| **`-steens`**  | Steensgaard_WPA             | Анализ Стинсгаарда (unification-based). |
| **`-fspta`**   | FSSPARSE_WPA                | Sparse flow-sensitive pointer analysis (учитывает порядок инструкций). |
| **`-vfspta`**  | VFS_WPA                     | Versioned sparse flow-sensitive points-to analysis. |
| **`-type`**    | TypeCPP_WPA                 | Быстрый type-based анализ для Callgraph, SVFIR и CHA (в основном для C++). |

**Примеры:**
```bash
wpa -ander -stat=false program.bc
wpa -fspta -stat=false program.bc
wpa -nander -stat=false program.bc
```

**Примечание:** В коде есть комментарий, что `-fspta` и `-vfspta` могут быть отключены до доработки (`// Disabled till further work is done` в Options.cpp), но опции регистрируются и при сборке обычно доступны.

---

## 2. DVF — Demand-Driven Value-Flow Analysis (инструмент `dvf`)

Исполняемый файл собирается как **`dvf`**, исходный код — `svf-llvm/tools/DDA/dda.cpp` (Demand-Driven Analysis). Анализ выполняется по запросу (для конкретных пар указателей/запросов), а не для всей программы сразу.

| Опция   | Тип анализа (PTATY) | Описание |
|--------|---------------------|----------|
| **`-cxt`** | Cxt_DDA   | Demand-driven context- и flow-sensitive анализ (контекстно-чувствительный DDA). |
| **`-dfs`** | FlowS_DDA | Demand-driven flow-sensitive анализ (без контекстной чувствительности). |

**Примеры:**
```bash
dvf -cxt -print-pts=false -stat=false program.bc
dvf -dfs -print-pts=false -stat=false program.bc
```

**Типичное использование в Test-Suite:** для категории `cs_tests` (context-sensitive tests) используется именно **`dvf -cxt`**.

---

## 3. CFL — CFL Reachability Analysis (инструмент `cfl`)

Анализ на основе контекстно-свободной достижимости (Context-Free Language reachability). Запускается отдельным бинарником **`cfl`**.

Варианты (через опции и ветвления в коде):

- **CFLAlias** — по умолчанию (если не указаны специальные опции): flow/context-insensitive CFL-reachability alias анализ.
- **CFLVF** — при включённой опции `-cflsvfg`: CFL на графе value flow (SVFG).
- **POCRAlias** — при опции `-pocr-alias`.
- **POCRHybrid** — при опции `-pocr-hybrid`.

**Пример:**
```bash
cfl program.bc
cfl -cflsvfg program.bc
```

В текущем проекте для Test-Suite CFL по умолчанию не используется; основные сценарии — `wpa` и `dvf`.

---

## 4. SABER — Bug detection (инструмент `saber`)

**SABER** — инструмент для поиска ошибок (memory leak, double free и т.д.), поверх pointer analysis. Для него включаются свои проверки и, при необходимости, валидация тестов.

| Опция / сценарий | Описание |
|------------------|----------|
| **`-leak`**      | Memory leak detection. |
| **`-dfree`**     | Double free detection. |
| **`-valid-tests`** | Включение валидации тестов (для mem_leak/double_free и т.п.). |

**Примеры (из README, помечены как NOT SUP в текущем проекте):**
```bash
saber -leak -valid-tests -mempar=inter-disjoint -stat=false program.bc
saber -dfree -valid-tests -stat=false program.bc
```

В конфигурации репозитория категории `mem_leak` и `double_free` отмечены как неподдерживаемые (NOT SUP).

---

## 5. Соответствие категорий Test-Suite и опций SVF

По документации и скриптам проекта:

| Категория Test-Suite   | Инструмент | Опции SVF | Примечание |
|------------------------|------------|-----------|------------|
| **basic_c_tests**      | wpa        | `-ander -stat=false`  | Flow-insensitive, field-sensitive. |
| **fs_tests**          | wpa        | `-fspta -stat=false`  | Flow-sensitive тесты. |
| **cs_tests**          | dvf        | `-cxt -print-pts=false -stat=false` | Context-sensitive тесты. |
| **path_tests**        | wpa        | **`-vfspta -stat=false`** | Path-sensitive тесты; рекомендуется versioned flow-sensitive (`-vfspta`). `-fspta` даёт много FAILURE (нет path-sensitivity). |
| **complex_tests**     | wpa        | `-ander -stat=false`  | В проекте помечено как NOT SUP. |
| **mem_leak**          | saber      | `-leak -valid-tests -mempar=inter-disjoint -stat=false` | NOT SUP. |
| **double_free**       | saber      | `-dfree -valid-tests -stat=false` | NOT SUP. |
| **non_annotated_tests** | —        | —                     | Без аннотаций, NOT SUP. |

---

## 6. path_tests: почему -vfspta

Категория **path_tests** проверяет сценарии, где результат зависит от ветки (if/else): на одной ветке пары указателей NOALIAS, на другой MAYALIAS. Обычный **flow-sensitive** анализ (`-fspta`) в SVF при слиянии веток объединяет состояния и теряет различие путей, поэтому многие проверки NOALIAS дают **FAILURE** (SUCCESS=1, FAILURE=21 типично для -fspta).

Рекомендуемый режим для path_tests в текущем SVF:

- **`wpa -vfspta -stat=false`** — **Versioned flow-sensitive** анализ; хранит версии точек-к-точкам по путям и даёт более точные NOALIAS на тестах с ветвлениями.

Если `-vfspta` недоступен или падает на части тестов, можно оставить **`-fspta`** (меньше SUCCESS) или для сравнения запустить **`-ander`** (flow-insensitive; ещё консервативнее, SUCCESS по path_tests будет ещё меньше).

---

## 7. Общие опции (кратко)

- **`-stat=false`** — отключить вывод статистики (часто используется в скриптах и тестах).
- **`-print-pts=false`** — не печатать points-to множества (для dvf).
- **`-print-all-pts`** — печатать все points-to множества (для отладки/сравнения).
- **`--alias-check`** / **`--no-alias-check`** — включить/выключить проверку аннотаций Test-Suite (MAYALIAS/NOALIAS и т.д.); по умолчанию проверка включена.

---

## 8. Иерархия типов анализа в коде (PTATY)

Перечисление `PointerAnalysis::PTATY` в `svf/include/MemoryModel/PointerAnalysis.h`:

**Whole program:**
- Andersen_BASE, Andersen_WPA, AndersenSCD_WPA, AndersenSFR_WPA, AndersenWaveDiff_WPA  
- Steensgaard_WPA  
- CSCallString_WPA, CSSummary_WPA (context-sensitive WPA)  
- FSDATAFLOW_WPA, FSSPARSE_WPA, VFS_WPA, FSCS_WPA  
- CFLFICI_WPA, CFLFSCI_WPA, CFLFSCS_WPA  
- TypeCPP_WPA  

**Demand-driven (DDA):**
- FieldS_DDA, FlowS_DDA, PathS_DDA, Cxt_DDA  

В командной строке доступны не все эти типы; реально используются те, что привязаны к опциям в `Options::PASelected` (wpa) и `Options::DDASelected` (dvf), как в таблицах выше.

---

## Связанные файлы в репозитории

- `svf/svf/lib/Util/Options.cpp` — регистрация опций PASelected, DDASelected.
- `svf/svf/include/MemoryModel/PointerAnalysis.h` — перечисление PTATY.
- `svf/svf/lib/WPA/WPAPass.cpp` — выбор и запуск WPA-анализа (ander, fspta и т.д.).
- `svf/svf/lib/DDA/DDAPass.cpp` — выбор и запуск DDA (cxt, dfs).
- `svf/svf-llvm/tools/WPA/wpa.cpp` — точка входа wpa.
- `svf/svf-llvm/tools/DDA/dda.cpp` — точка входа dvf (бинарник собирается как `dvf`).
- `scripts/04_run_svf_tsuite.sh` — какие опции используются для каких категорий Test-Suite.
- `scripts/env.sh` — пути к `WPA_CLI` (wpa) и `DVF_CLI` (dvf).
