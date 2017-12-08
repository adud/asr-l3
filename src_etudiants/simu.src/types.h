#include<inttypes.h>

#if WORDSIZE==32
typedef uint32_t uword;
typedef int32_t sword;
typedef uint64_t doubleword;
#endif

#if WORDSIZE==64
typedef uint64_t uword;
typedef int64_t sword;
typedef __uint128_t doubleword;
#endif
