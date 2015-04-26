#include <stdio.h>

#include "json.h"

int main()
{
  char buffer[1024 * 1024];
  fread(buffer, 1, sizeof(buffer), stdin);

  const char* end;
  json_val val = json_parse(buffer, &end);
  printf("parsed %ld chars\n", end - buffer);
  
  json_print(val, stdout, 2);
  json_free(val);
}

