/*--------------------------------------------------------------------*/
/*                                                                    */
/* nth -- Print lines from the middle of a text file.                 */
/* Alex Samuel, November 2002                                         */
/*                                                                    */
/*--------------------------------------------------------------------*/

/*--------------------------------------------------------------------*/
/* includes                                                           */
/*--------------------------------------------------------------------*/

#include <errno.h>
#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

/*--------------------------------------------------------------------*/
/* constants                                                          */
/*--------------------------------------------------------------------*/

/* Command-line options, short form.  */
const char* 
short_options = "hl:n:";

/* Command-line options, long form.  */
const struct option
long_options[] = {
  { "help", 0, NULL, 'h' },
  { "line", 1, NULL, 'l' },
  { "number", 1, NULL, 'n' },
  { NULL, 0, NULL, 0 }
};

/* A description of how to invoke this program.  */
const char*
usage_summary = 
"Usage: %s [OPTION] [FILE]\n"
"\n"
"Options:\n"
"  -h, --help               Show usage information.\n"
"  -l, --line=NUMBER        Start printing from line NUMBER.\n"
"  -n, --number=NUMBER      Print NUMBER lines instead of 1.\n"
"\n"
"If FILE is omitted, reads from standard input.\n"
"\n"
;

/*--------------------------------------------------------------------*/
/* main program                                                       */
/*--------------------------------------------------------------------*/

/* Store the path to the program, as specified by the user, here.  */
const char* 
program_path;


/* Print usage information and exit.

   If 'is_error' is non-zero, prints the usage information to 'stderr'
   and exits with a failure code.  Otherwise, prints the usage
   information to 'stdout' and exits with a success code.
*/
void
print_usage_and_exit(int is_error)
{
  FILE* out = is_error ? stderr : stdout;
  fprintf(out, usage_summary, program_path);
  exit(is_error ? 1 : 0);
}


/* Print lines from a file.

   Print lines from 'in_file' to 'out_file'.  Printing starts at the
   line from 'in_file' specified by 'first_line'; 'lines' gives the
   number of (consecutive) lines to print.

   Returns zero on success, -1 if there aren't enough lines in
   'in_file', or the value of 'errno' if another error occurs.
*/
int
print_lines(FILE* in_file,
	    int first_line,
	    int lines,
	    FILE* out_file)
{
  /* Keep count of which line we're on.  */
  int current_line = 0;

  while (1) {
    /* Get the next character.  */
    int c = getc(in_file);
    if (c == EOF)
      /* End of file, or perhaps an error.  */
      break;

    /* If we're in the range of lines we want to print, send the
       character out.  */
    if (current_line >= first_line)
      putc(c, out_file);

    /* Newline?  */
    if (c == '\n') {
      /* Yes.  Bump up the line number.  */
      ++current_line;
      /* If we passed the last line we need to print, bail out now
	 instead of reading through he rest of the file.  */
      if (current_line >= first_line + lines)
	break;
    }
  }

  /* Did we break out with an error?  */
  if (errno != 0)
    /* Yes.  Return it.  */
    return errno;

  /* Return success if we passed all the lines we needed to print.  */
  return (current_line >= first_line + lines) ? 0 : -1;
}


int
main(int argc,
     char* const argv[])
{
  int done_with_options = 0;
  const char* input_file_name;
  int error = 0;

  /* The first line to start printing.  */
  int first_line = 0;
  /* The number of lines to print.  */
  int lines = 1;

  /* Remember the program path, for use in diagnostics.  */
  program_path = argv[0];

  /* Loop over options.  */
  while (! done_with_options) {
    int next_option = 
      getopt_long(argc, argv, short_options, long_options, NULL);
    
    switch (next_option) {
    case -1:
      done_with_options = 1;
      break;

    case 'h':
      print_usage_and_exit(0);
      break;

    case 'l':
      if (sscanf(optarg, "%d", &first_line) != 1)
	print_usage_and_exit(1);
      break;

    case 'n':
      if (sscanf(optarg, "%d", &lines) != 1)
	print_usage_and_exit(1);
      break;

    default:
      print_usage_and_exit(1);
      break;
    }
  }

  /* Were the right number of options specified?  */
  if (optind != argc && optind != argc - 1)
    /* No.  */
    print_usage_and_exit(1);

  if (optind == argc - 1) {
    FILE* input_file;

    /* One argument specified.  That's the name of a file.  Use it for
       input.  */
    input_file_name = argv[optind];
    /* Open the input file.  */
    input_file = fopen(input_file_name, "r");
    if (input_file == NULL) {
      perror(input_file_name);
      return EXIT_FAILURE;
    }
    /* Print lines.  */
    error = print_lines(input_file, first_line, lines, stdout);
    /* Close the input file.  */
    fclose(input_file);
  }

  else /* (optind == argc) */ {
    input_file_name = "(stdin)";
    /* No argument specified; read lines from standard input.  */
    error = print_lines(stdin, first_line, lines, stdout);
  }

  if (error == 0)
    return EXIT_SUCCESS;
  else if (error == -1) {
    fprintf(stderr, "%s: Not enough lines.\n", input_file_name);
    return EXIT_FAILURE;
  }
  else {
    fprintf(stderr, "%s: %s.\n", input_file_name, strerror(error));
    return EXIT_FAILURE; 
  }
}
