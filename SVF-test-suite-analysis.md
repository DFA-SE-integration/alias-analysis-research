# Анализ механизма работы SVF с Test-Suite

## Обзор

SVF автоматически проверяет тесты из Test-Suite, используя специальные функции-аннотации, определенные в `aliascheck.h`. Механизм валидации включен по умолчанию и работает автоматически при запуске анализа.

## Механизм работы

### 1. Функции-аннотации в Test-Suite

В каждом тесте используются специальные функции из `tests/Test-Suite/aliascheck.h`:

```c
void MAYALIAS(void* p, void* q);      // Ожидается, что p и q могут быть алиасами
void NOALIAS(void* p, void* q);      // Ожидается, что p и q НЕ являются алиасами
void MUSTALIAS(void* p, void* q);    // Ожидается, что p и q должны быть алиасами
void PARTIALALIAS(void* p, void* q); // Частичный алиас
void EXPECTEDFAIL_MAYALIAS(void* p, void* q);  // Ожидается неудача для MAYALIAS
void EXPECTEDFAIL_NOALIAS(void* p, void* q);  // Ожидается неудача для NOALIAS
```

**Пример использования в тесте** (`path4.c`):
```c
MAYALIAS(p, &a);    // Проверка: p и &a могут быть алиасами
MAYALIAS(p, &x1);   // Проверка: p и &x1 могут быть алиасами
NOALIAS(m, &a1);    // Проверка: m и &a1 НЕ являются алиасами
NOALIAS(m, &x1);    // Проверка: m и &x1 НЕ являются алиасами
MUSTALIAS(n, m);    // Проверка: n и m должны быть алиасами
```

### 2. Процесс валидации в SVF

#### Шаг 1: Включение валидации

Валидация включается автоматически при выполнении анализа:

**Код:** `svf/svf/lib/MemoryModel/PointerAnalysis.cpp:76`
```cpp
alias_validation = (alias_check && Options::EnableAliasCheck());
```

Аннотации указаны хардкодом чуть выше:
**Код:** `svf/svf/lib/MemoryModel/PointerAnalysis.cpp:52`
```cpp
const std::string PointerAnalysis::aliasTestMayAlias            = "MAYALIAS";
const std::string PointerAnalysis::aliasTestMayAliasMangled     = "_Z8MAYALIASPvS_";
const std::string PointerAnalysis::aliasTestNoAlias             = "NOALIAS";
const std::string PointerAnalysis::aliasTestNoAliasMangled      = "_Z7NOALIASPvS_";
const std::string PointerAnalysis::aliasTestPartialAlias        = "PARTIALALIAS";
const std::string PointerAnalysis::aliasTestPartialAliasMangled = "_Z12PARTIALALIASPvS_";
const std::string PointerAnalysis::aliasTestMustAlias           = "MUSTALIAS";
const std::string PointerAnalysis::aliasTestMustAliasMangled    = "_Z9MUSTALIASPvS_";
const std::string PointerAnalysis::aliasTestFailMayAlias        = "EXPECTEDFAIL_MAYALIAS";
const std::string PointerAnalysis::aliasTestFailMayAliasMangled = "_Z21EXPECTEDFAIL_MAYALIASPvS_";
const std::string PointerAnalysis::aliasTestFailNoAlias         = "EXPECTEDFAIL_NOALIAS";
const std::string PointerAnalysis::aliasTestFailNoAliasMangled  = "_Z20EXPECTEDFAIL_NOALIASPvS_";
```

- `alias_check` по умолчанию `true` (конструктор `Andersen` и других PTA)
- `Options::EnableAliasCheck()` по умолчанию `true` (`svf/lib/Util/Options.cpp:305`)

**Условие выполнения валидации** (`PointerAnalysis.cpp:204`):
```cpp
if(!pag->isBuiltFromFile() && alias_validation)
    validateTests();
```

Валидация выполняется только если:
- PAG не был построен из файла (`!pag->isBuiltFromFile()`)
- Валидация включена (`alias_validation == true`)

#### Шаг 2: Поиск функций-аннотаций

**Код:** `svf/svf/lib/MemoryModel/PointerAnalysis.cpp:214-229`
```cpp
void PointerAnalysis::validateTests()
{
    validateSuccessTests(aliasTestMayAlias);      // "MAYALIAS"
    validateSuccessTests(aliasTestNoAlias);       // "NOALIAS"
    validateSuccessTests(aliasTestMustAlias);     // "MUSTALIAS"
    validateSuccessTests(aliasTestPartialAlias);   // "PARTIALALIAS"
    validateExpectedFailureTests(aliasTestFailMayAlias);  // "EXPECTEDFAIL_MAYALIAS"
    validateExpectedFailureTests(aliasTestFailNoAlias); // "EXPECTEDFAIL_NOALIAS"
    // ... также для mangled версий (C++)
}
```

SVF ищет вызовы этих функций в биткоде и проверяет каждую.

#### Шаг 3: Проверка каждой аннотации

**Код:** `svf/svf/lib/MemoryModel/PointerAnalysis.cpp:503-563`

Для каждой найденной функции-аннотации:

1. **Извлечение аргументов:**
   ```cpp
   const SVFVar* V1 = callNode->getArgument(0);  // Первый указатель
   const SVFVar* V2 = callNode->getArgument(1);  // Второй указатель
   ```

2. **Выполнение alias-анализа:**
   ```cpp
   AliasResult aliasRes = alias(V1->getId(), V2->getId());
   ```

3. **Проверка результата в зависимости от типа аннотации:**

   **MAYALIAS:**
   ```cpp
   if (aliasRes == AliasResult::MayAlias || aliasRes == AliasResult::MustAlias)
       checkSuccessful = true;
   ```

   **NOALIAS:**
   ```cpp
   if (aliasRes == AliasResult::NoAlias)
       checkSuccessful = true;
   ```

   **MUSTALIAS:**
   ```cpp
   if (aliasRes == AliasResult::MayAlias || aliasRes == AliasResult::MustAlias)
       checkSuccessful = true;  // Примечание: пока что принимает MayAlias
   ```

4. **Вывод результата:**

   **SUCCESS:**
   ```cpp
   if (checkSuccessful)
       outs() << sucMsg("\t SUCCESS :") << fun << " check <id:" << id1 << ", id:" << id2 
              << "> at (" << callNode->getSourceLoc() << ")\n";
   ```

   **FAILURE:**
   ```cpp
   else {
       SVFUtil::errs() << errMsg("\t FAILURE :") << fun << " check <id:" << id1 
                       << ", id:" << id2 << "> at (" << callNode->getSourceLoc() << ")\n";
       assert(false && "test case failed!");  // Программа завершается с ошибкой
   }
   ```

### 3. Определение SUCCESS/FAILURE

#### SUCCESS (успешный тест):
- Все аннотации в тесте прошли проверку
- Программа завершилась без `assert(false)`
- В логе есть только строки `SUCCESS` или файл не пустой и не содержит индикаторы ошибок

#### FAILURE (неудачный тест):
- Хотя бы одна аннотация не прошла проверку
- Выполняется `assert(false && "test case failed!")`
- Программа завершается с сигналом `SIGABRT` (Aborted)
- В логе есть строки `FAILURE` или `Assertion.*failed`

### 4. Примеры логов

**Успешный тест** (`CI-local.c.log`):
```
sh: 1: npm: not found
sh: 1: npm: not found
[AndersenWPA] Checking MAYALIAS
	 SUCCESS :MAYALIAS check <id:223, id:225> at (CallICFGNode: { "ln": 10, "cl": 2, "fl": "tests/Test-Suite/src/basic_c_tests/CI-local.c" })
```

**Неудачный тест** (`path4.c.log`):
```
sh: 1: npm: not found
sh: 1: npm: not found
[FlowSensitive] Checking MAYALIAS
	 SUCCESS :MAYALIAS check <id:275, id:276> at (CallICFGNode: { "ln": 24, "cl": 5, "fl": "tests/Test-Suite/src/path_tests/path4.c" })
	 SUCCESS :MAYALIAS check <id:279, id:280> at (CallICFGNode: { "ln": 25, "cl": 5, "fl": "tests/Test-Suite/src/path_tests/path4.c" })
[FlowSensitive] Checking NOALIAS
	 SUCCESS :NOALIAS check <id:287, id:288> at (CallICFGNode: { "ln": 27, "cl": 5, "fl": "tests/Test-Suite/src/path_tests/path4.c" })
	 FAILURE :NOALIAS check <id:283, id:284> at (CallICFGNode: { "ln": 26, "cl": 5, "fl": "tests/Test-Suite/src/path_tests/path4.c" })
wpa: /workspace/svf/svf/lib/MemoryModel/PointerAnalysis.cpp:558: virtual void SVF::PointerAnalysis::validateSuccessTests(std::string): Assertion `false && "test case failed!"' failed.
```

### 5. Запуск анализа

**Команды для разных категорий тестов:**

```bash
# basic_c_tests - Andersen WaveDiff анализ
wpa -ander -stat=false file.bc

# fs_tests - Flow-Sensitive анализ
wpa -fspta -stat=false file.bc

# cs_tests - Context-Sensitive анализ
dvf -cxt -print-pts=false -stat=false file.bc

# path_tests - Flow-Sensitive анализ
wpa -fspta -stat=false file.bc
```

**Опции:**
- `-stat=false` - отключает вывод статистики
- Валидация включена по умолчанию (можно отключить через `--no-alias-check`)

## Выводы

1. **Автоматическая валидация:** SVF автоматически проверяет все аннотации в тестах без необходимости дополнительных флагов
2. **Строгая проверка:** При первой же неудачной проверке тест завершается с ошибкой (`assert(false)`)
3. **Детальный вывод:** Каждая проверка выводит SUCCESS или FAILURE с указанием ID переменных и местоположения в коде
4. **Определение результата:** 
   - SUCCESS = нет FAILURE в логе и нет "Aborted"/"Assertion failed"
   - FAILURE = есть FAILURE в логе или есть "Aborted"/"Assertion failed"

## Связанные файлы

- `svf/svf/lib/MemoryModel/PointerAnalysis.cpp` - основная логика валидации
- `svf/svf/lib/MemoryModel/PointerAnalysis.h` - определения функций-аннотаций
- `tests/Test-Suite/aliascheck.h` - определения функций-аннотаций для тестов
- `svf/svf/lib/Util/Options.cpp` - опция `EnableAliasCheck` (по умолчанию `true`)
