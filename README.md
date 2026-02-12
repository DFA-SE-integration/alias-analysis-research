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

Предполага, одинаковую направленность инструментов, по крайней мере они так декларируют. Следовательно, можно взять несколько
***размеченных*** проектов и затем сравнить результаты прогонов. Предполагаю, что recall у них должен быть примерно одинаковый,
но precision из-за разных алгоритмов alias анализа может отличаться в случае (интерпроцедурных тестов, override дальше по control flow, 
read after write при большой косвенности).

### [PointerBench](https://github.com/secure-software-engineering/PointerBench)

Разрабатывается вместе с проектом Phasar.

Репозиторий является набором самописных тестов для проверки precision и soundness инструментов pointer анализа. Тесты задизайнены так, чтобы проверять **Field, Flow or Context-Senstivity**.

Происходит это по средствам **the ground truth**. Это такая информация о том, 1) где (мог/должен был) **быть создан объект** и 2) с кем он (может/обязан) **алиасится**.

Инструкции задающие **the ground truth** определены в benchmark.internal.

Пример инструкции:
```
Benchmark.test("a.f", "{allocId:1, mayAlias:[b,a.f], notMayAlias:[], mustAlias:[b,x], notMustAlias:[]}, {allocId:2, mayAlias:[a,d], notMayAlias:[c], mustAlias:[a], notMustAlias:[c,d]}");
```

Как тестировать alias analysis?
```
Алиас-анализ
Запрос: в операторе s, являются ли a и b алиасами?

1. Рассматривать только оператор внутри Benchmark.test().

2. Распарсить информацию mayAlias и notMayAlias (или информацию must — в зависимости от того, что проверяется). 

3. Если информация даётся отдельно по разным сайтам выделения памяти, взять объединение (union) по всем таким сайтам.

4. Для каждой переменной, которая попала в mayAlias, удалить её возможные “дубликаты” из mayNotAlias (т.е. если один и тот же кандидат оказался и там и там — оставить его только в mayAlias).

5. Для каждого элемента из mayAlias проверить, что он алиасится с тестовым access path: "a.f".

6. Для каждого элемента из notMayAlias проверить, что он не алиасится с тестовым access path: "a.f".

```

### [Test-Suite](https://github.com/SVF-tools/Test-Suite)

Разрабатывается вместе с проектом SVF.

Включает 400 самописных программ и код сниппетов для проверки инструментов pointer analysis.

Взяты следующие категории:
| Folder  | Description | SVF options |
|---------|-------------| -------------|
| `basic_c_tests` | basic test cases for C programs (flow-insensitive and field-sensitive analysis) | wpa -ander -stat=false |
| `fs_tests` | flow-sensitive tests | 	wpa -fspta -stat=false |
| `cs_tests` | context-sensitive tests | dvf -cxt -print-pts=false -stat=false |
| `complex_tests` | complex test cases simplified from real programs | wpa -ander -stat=false **(NOT SUP)**| 
| `mem_leak` | memory leak test cases | saber -leak -valid-tests -mempar=inter-disjoint -stat=false **(NOT SUP)** |
| `double_free` | double free test cases | saber -dfree -valid-tests -stat=false **(NOT SUP)** |
| `path_tests` | path-sensitive tests | **(TODO)** |
| `non_annotated_tests` | not annotated | **(TODO)** **(NOT SUP)** |
