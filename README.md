# Alias analysis research

Исследование инструментов alias анализа для ВКР. Суть в том, чтобы взять инстрмуенты статического анализа с актуальными подходами и проверить их на размеченных тестах на предмет того, какое решение будет более удачное.

Проверяем инструменты(PhASAR, SeaDSA, SVF) на бенчмарках. В репозитории содержаться скрипты для прогона тестов и сборки инструментов. Используемые проекты: PTABen, Test-Suite. LLVM 14.

## Docker

В проекте присутствует **Dockerfile (Ubuntu 24 x86_64)**:

| Command | Description |
|--------|-------------|
| `make docker-image` | Build image alias-analysis-ubuntu24 (linux/amd64) |
| `make docker-shell` | Run interactive shell in container (repo mounted at /workspace) + mount ~/.ssh |
| `make docker-run target=T` | Run `make T` in container + mount ~/.ssh |

## Инструменты анализа

| Project | URL | Description|
|---------|-------------| -------------|
| `Phasar` | A LLVM-based Static Analysis Framework | https://github.com/secure-software-engineering/phasar |
| `SeaDsa` | A Points-to Analysis for Verification of Low-level C/C++ | https://github.com/seahorn/sea-dsa |
| `SVF` | Static value-flow analysis tool for LLVM-based languages | https://github.com/SVF-tools/SVF |

| Command       | Description                |
|---------------|----------------------------|
| `make phasar` | scripts/02_build_phasar.sh |
| `make seadsa` | scripts/02_build_seadsa.sh |
| `make svf`    | scripts/02_build_SVF.sh    |




