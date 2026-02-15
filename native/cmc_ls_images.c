#include <dirent.h>
#include <errno.h>
#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sysexits.h>

int main(const int argc, const char* argv[]) {
  const char* inputDir = (argc >= 2) ? argv[1] : ".";
  DIR* dir;
  struct dirent* entry;
  char absolutePath[PATH_MAX];

  if (!(dir = opendir(inputDir))) {
    if (errno == ENOENT || errno == ENOTDIR) {
      fprintf(stderr, "Directory not found: '%s'\n", inputDir);
      return EX_NOINPUT;
    } else if (errno == EACCES) {
      fprintf(stderr, "Permission denied: '%s'\n", inputDir);
      return EX_NOPERM;
    } else {
      perror("Failed to open directory");
      return EX_OSERR;
    }
  }

  while ((entry = readdir(dir)) != NULL) {
    if (entry->d_name[0] == '.') continue;
    if (entry->d_type != DT_REG) continue;

    realpath(entry->d_name, absolutePath);
    printf("%s\n", absolutePath);
  }

  if (closedir(dir) == -1) {
    perror("Failed to close directory.");
    return EX_OSERR;
  }
  return EX_OK;
}
