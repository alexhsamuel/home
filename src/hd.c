/***********************************************************************

  Hex dump program.

  Copyright 2000 Alex Samuel.

***********************************************************************/

#include <ctype.h>
#include <stdio.h>
#include <string.h>

#define ROW_MAX 64

static int g_rowLength = 16;
static char g_nonprintableChar = '.';

int dump(FILE* pFile);


int main(int argc, char* argv[])
{
  char* pFilename = 0;

  while(*(++argv))
  {
    if(*argv[0] == '-')
    {
      char* pOption = (*argv) + 1;
      while(pOption)
      {
	switch(*pOption)
	{
	case 'h':
	  printf("Usage:  hexdump [-hv] filename\n");
	  return 0;
	  break;
		    
	case 'v':
	  printf("Hexdump version 0.1\n");
	  return 0;
		    
	default:
	  fprintf(stderr, "Unknown option %s\n", *argv);
	  return 1;
	}

	pOption++;
      }
    }

    else
    {
      pFilename = *argv;
      break;
    }
  }

  if(pFilename == 0 || strlen(pFilename) == 0)
  {
    return dump(stdin);
  }
  else
  {
    FILE* pFile = fopen(pFilename, "r");

    if(pFile == 0)
    {
      fprintf(stderr, "Could not open \"%s\"", pFilename);
      return 1;
    }

    return dump(pFile);
  }
}


int dump(FILE* pFile)
{
  int addr = 0;

  while(!feof(pFile))
  {
    int row[ROW_MAX];
    int i, j;

    printf("%08x | ", addr);

    for(i=0; i<g_rowLength; i++)
    {
      row[i] = fgetc(pFile);
      if(feof(pFile))
	break;
    }

    for(j=0; j<g_rowLength; j++)
    {
      char c;

      c = j >= i ? ' ' : 
	isprint(row[j]) ? (char) row[j] : g_nonprintableChar;
      printf("%c", c);
    }

    printf(" | ");
    for(j=0; j<g_rowLength; j++)
    {
      if(j < i)
	printf("%02x ", row[j]);
      else
	printf("   ");
    }

    printf("\n");

    addr += g_rowLength;
  }

  return 0;
}

