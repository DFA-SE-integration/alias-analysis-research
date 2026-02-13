```bash
tests/Test-Suite/build/bc/basic_c_tests/branch-call.c.bc
root@bf134f0cbf37:/workspace# "$PHASAR_CLI" -m tests/Test-Suite/build/bc/basic_c_tests/branch-call.c.bc -D ifds-solvertest --entry-points=__ALL__ --alias-analysis=cflanders --emit-pta-as-json --emit-stats
PhASAR v2510
A LLVM-based static analysis framework

         SUCCESS :MAYALIAS check at (/workspace/tests/Test-Suite/src/basic_c_tests/branch-call.c:10:2)
{
    "AliasSets": [
        [
            "103",
            "118",
            "108",
            "104",
            "foo.0",
            "111",
            "foo.1",
            "115"
        ],
        [
            "98"
        ],
        [
            "97"
        ],
        [
            "LOCK.0"
        ],
        [
            "96"
        ],
        [
            "139",
            "145",
            "126"
        ],
        [
            "74"
        ],
        [
            "144",
            "138",
            "125",
            "124"
        ],
        [
            "95"
        ],
        [
            "INTERLEV_ACCESS.1",
            "INTERLEV_ACCESS.2"
        ],
        [
            "123"
        ],
        [
            "122"
        ],
        [
            "67"
        ],
        [
            "121"
        ],
        [
            "59"
        ],
        [
            "1",
            "2",
            "90",
            "PAUSE.0"
        ],
        [
            "87"
        ],
        [
            "CXT_THREAD.1"
        ],
        [
            "4"
        ],
        [
            "3"
        ],
        [
            "12"
        ],
        [
            "11"
        ],
        [
            "20"
        ],
        [
            "19"
        ],
        [
            "28"
        ],
        [
            "27"
        ],
        [
            "73"
        ],
        [
            "36"
        ],
        [
            "44"
        ],
        [
            "MUSTALIAS.0",
            "MUSTALIAS.1",
            "0",
            "EXPECTEDFAIL_NOALIAS.1",
            "EXPECTEDFAIL_NOALIAS.0",
            "NOALIAS.1",
            "EXPECTEDFAIL_MAYALIAS.1",
            "EXPECTEDFAIL_MAYALIAS.0",
            "MAYALIAS.1",
            "MAYALIAS.0",
            "NOALIAS.0",
            "PARTIALALIAS.0",
            "PARTIALALIAS.1"
        ],
        [
            "43"
        ],
        [
            "83"
        ],
        [
            "66"
        ],
        [
            "52"
        ],
        [
            "35"
        ],
        [
            "51"
        ],
        [
            "75"
        ],
        [
            "60"
        ],
        [
            "TCT_ACCESS.1"
        ]
    ],
    "AnalyzedFunctions": [
        "INTERLEV_ACCESS",
        "main",
        "CXT_THREAD",
        "RC_ACCESS",
        "TCT_ACCESS",
        "EXPECTEDFAIL_NOALIAS",
        "NOALIAS",
        "MAYALIAS",
        "PAUSE",
        "EXPECTEDFAIL_MAYALIAS",
        "LOCK",
        "PARTIALALIAS",
        "foo",
        "MUSTALIAS"
    ]
}
General LLVM IR Statistics
Module tests/Test-Suite/build/bc/basic_c_tests/branch-call.c.bc:
---------------------------------------
LLVM IR instructions:               146
Functions:                           17
External Functions:                  17
Function Definitions:                14
Address-Taken Functions:              0
Globals:                              3
Global Constants:                     3
Global Variables:                     0
External Globals:                     0
Global Definitions:                   3
Alloca Instructions:                 33
Call Sites:                          45
Indirect Call Sites:                  0
Inline Assemblies:                    0
Memory Intrinsics:                    0
Debug Intrinsics:                    32
Switches:                             0
GetElementPtrs:                       0
Loads:                               16
Stores:                              34
Phi Nodes:                            0
LandingPads:                          0
Basic Blocks:                        17
Branches:                             3
Avg #pred per BasicBlock:             0.24
Max #pred per BasicBlock:             2
Avg #succ per BasicBlock:             0.24
Max #succ per BasicBlock:             1
Avg #operands per Inst:               1.93
Max #operands per Inst:               4
Avg #uses per Inst:                   0.46
Max #uses per Inst:                   4
Insts with >1 uses:                   9
Non-void Insts:                      60
Insts used outside its BB:            5

Elapsed: 00:00:00:001091
root@bf134f0cbf37:/workspace# "$PHASAR_CLI" -m tests/Test-Suite/build/bc/path_tests/path -D ifds-solvertest -
-entry-points=__ALL__ --alias-analysis=cflanders --emit-pta-as-json --emit-stats
path1.c.bc   path12.c.bc  path15.c.bc  path18.c.bc  path20.c.bc  path3.c.bc   path6.c.bc   path9.c.bc
path10.c.bc  path13.c.bc  path16.c.bc  path19.c.bc  path21.c.bc  path4.c.bc   path7.c.bc   
path11.c.bc  path14.c.bc  path17.c.bc  path2.c.bc   path22.c.bc  path5.c.bc   path8.c.bc   
root@bf134f0cbf37:/workspace# "$PHASAR_CLI" -m tests/Test-Suite/build/bc/path_tests/path12.c.bc -D ifds-solve
rtest --entry-points=__ALL__ --alias-analysis=cflanders --emit-pta-as-json --emit-stats
PhASAR v2510
A LLVM-based static analysis framework

         FAILURE :NOALIAS check at (/workspace/tests/Test-Suite/src/path_tests/path12.c:14:5)
         FAILURE :NOALIAS check at (/workspace/tests/Test-
```