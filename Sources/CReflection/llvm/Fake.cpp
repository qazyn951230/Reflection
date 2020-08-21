#include <llvm/Support/ErrorHandling.h>

namespace llvm {
int EnableABIBreakingChecks = 0;

void report_bad_alloc_error(const char *Reason, bool GenCrashDiag) {}
}

