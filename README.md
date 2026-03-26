# Alias analysis research

Исследование инструментов alias анализа для ВКР. Суть в том, чтобы взять инстрмуенты статического анализа с актуальными подходами и проверить их на размеченных тестах на предмет того, какое решение будет более удачное.

Проверяем инструменты(PhASAR, SeaDSA, SVF) на бенчмарках. В репозитории содержаться скрипты для прогона тестов и сборки инструментов. Используемые проекты: Test-Suite. LLVM 14.

## Docker

В проекте присутствует **Dockerfile (Ubuntu 24 x86_64)**:

| Command | Description |
|--------|-------------|
| `make docker-image` | Build image alias-analysis-ubuntu24 (linux/amd64) |
| `make docker-shell` | Run interactive shell in container (repo mounted at /workspace) + mount ~/.ssh |
| `make docker-run target=T` | Run `make T` in container + mount ~/.ssh |

## Инструменты анализа

| Project | Description | URL |
|---------|-------------| -------------|
| `Phasar` | A LLVM-based Static Analysis Framework | https://github.com/secure-software-engineering/phasar |
| `SeaDsa` | A Points-to Analysis for Verification of Low-level C/C++ | https://github.com/seahorn/sea-dsa |
| `SVF` | Static value-flow analysis tool for LLVM-based languages | https://github.com/SVF-tools/SVF |

| Command       | Description                |
|---------------|----------------------------|
| `make phasar` | scripts/02_build_phasar.sh |
| `make seadsa` | scripts/02_build_seadsa.sh |
| `make svf`    | scripts/02_build_SVF.sh    |

## Тестируемые проекты

Предполагаю, одинаковую направленность инструментов, по крайней мере они так декларируют. Следовательно, можно взять несколько ***размеченных*** проектов и затем сравнить результаты прогонов. Предполагаю, что recall у них должен быть примерно одинаковый, но precision из-за разных алгоритмов alias анализа может отличаться в случае (интерпроцедурных тестов, override дальше по control flow, read after write при большой косвенности).

### ~~[PointerBench](https://github.com/secure-software-engineering/PointerBench)~~ (удалён)

PointerBench исключён из исследования. Причины:

- **Слишком малая выборка** — 41 тест-пара против 768 у Test-Suite. Разница в 4 ложных срабатывания меняет F1 на 0.06, что делает результаты статистически ненадёжными.
- **Смещение состава** — 25% тестов (7/28) относятся к классу `flow+field+context+heap`, нативной специализации Sea-DSA. При этом 7 из 15 классов Test-Suite не представлены вовсе.
- **Инверсия рейтинга** — Sea-DSA F1=0.94 на PointerBench против F1=0.71 на Test-Suite. Это артефакт несбалансированного состава, а не реальная разница в качестве инструментов.
- **Java-происхождение** — бенчмарк разработан для Java; C-версии являются портированными стабами, многие из которых дублируют один сценарий (Parameter1/2, ReturnValue1/2, FieldSensitivity1/2 и т.д.).

### [Test-Suite](https://github.com/SVF-tools/Test-Suite)

Разрабатывается вместе с проектом SVF.

Включает 400 самописных программ и код сниппетов для проверки инструментов pointer analysis.

Тесты сгруппированы по комбинациям требуемых чувствительностей анализа (директории под `tests/Test-Suite/src/`):

| Категория | Описание | Файлов |
|-----------|----------|-------:|
| `flow` | Базовые flow-sensitive тесты: переприсвоения, глобалы, циклы, функциональные указатели | 28 |
| `flow+context` | + межпроцедурная контекстная чувствительность (разные call sites) | 20 |
| `flow+field` | + чувствительность к полям структур | 32 |
| `flow+field+context` | + поля + контекст | 20 |
| `flow+field+heap` | + поля + heap-объекты (malloc) | 10 |
| `flow+field+context+heap` | + поля + контекст + heap | 2 |
| `flow+heap` | + heap-объекты без поля | 4 |
| `flow+index` | + чувствительность к индексам массивов | 4 |
| `flow+path` | + path-sensitive (ветки, условия) | 32 |
| `flow+path+context` | + path + контекст (рекурсия) | 15 |
| `flow+path+context+heap` | + path + контекст + heap | 2 |
| `flow+path+field` | + path + поля | 9 |
| `flow+path+field+context` | + path + поля + контекст | 9 |
| `flow+path+field+heap` | + path + поля + heap (SPEC-стиль) | 3 |
| `flow+path+field+context+heap` | Все измерения (Mesa-стиль) | 3 |
| **Итого** | | **193** |
