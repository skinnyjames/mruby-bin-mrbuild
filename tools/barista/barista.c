#include <mruby.h>
#include <mruby/hash.h>
#include <mruby/compile.h>
#include <mruby/array.h>

#include <string.h>
#include <stdio.h>
#include "../../src/mrb_barista.h"

#define OPTPARSE_IMPLEMENTATION
#define OPTPARSE_API static
#include "optparse.h"

int main(int argc, char *argv[])
{
  mrb_state* mrb = mrb_open();
  mrb_mruby_bin_barista_gem_init(mrb);

  char* directory;
  char* arg;
  int option;
  struct optparse options;
  optparse_init(&options, argv);

  arg = optparse_arg(&options);
  if (!arg)
  {
    fprintf(stderr, "Need a directory to run\n");
    return 1;
  } 

  directory = arg;
  char filename[strlen(directory) + 20];
  sprintf(filename, "%s/gemspec.rb", directory);

  FILE* file = fopen(filename, "r");
  if (file == NULL)
  {
    fprintf(stderr, "Gemspec %s could not be loaded.\n", filename);
    return 1;
  }

  mrb_value gemspec = mrb_load_file(mrb, file);
  if (mrb->exc) {
    mrb_print_error(mrb);
    return 1;
  }
  fclose(file);
  mrb_funcall(mrb, gemspec, "execute", 0, NULL);

  mrb_mruby_bin_barista_gem_final(mrb);
  mrb_close(mrb);

  return 0;
}