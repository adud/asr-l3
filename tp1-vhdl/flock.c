#define _GNU_SOURCE
#include <dlfcn.h>
#include <sys/file.h>

int flock(int fd, int operation)
{
  int (*original_flock)(int _fd, int _operation);
  original_flock = dlsym(RTLD_NEXT, "flock");
  (*original_flock)(fd, operation);
  return 0;
}
