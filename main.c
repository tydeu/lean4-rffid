#include <stdio.h>
#include <lean/lean.h>

extern lean_obj_arg my_char(lean_obj_arg, lean_obj_arg);

// see https://leanprover.github.io/lean4/doc/dev/ffi.html#initialization
extern void lean_initialize_runtime_module();
extern void lean_initialize();
extern void lean_io_mark_end_initialization();
extern lean_object * initialize_RFFID(uint8_t builtin, lean_object *);

int main() {
  lean_initialize_runtime_module();
  lean_object * res;
  // use same default as for Lean executables
  uint8_t builtin = 1;
  res = initialize_RFFID(builtin, lean_io_mk_world());
  if (lean_io_result_is_ok(res)) {
      lean_dec_ref(res);
  } else {
      lean_io_result_show_error(res);
      lean_dec(res);
      return 1;  // do not access Lean declarations if initialization failed
  }
  lean_io_mark_end_initialization();

  // actual program

  lean_object * s = lean_mk_string("hello!");
  uint32_t c = lean_unbox_uint32(lean_ctor_get(my_char(s, lean_box(0)), 0));
  printf("output: %lc\n", c);
}
