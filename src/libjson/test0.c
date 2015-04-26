#include <stdio.h>

#include "json.h"

int main()
{
  json_val v0 = json_new_obj();
  json_obj_set(v0, "foo", json_new_num(42));
  json_obj_set(v0, "bar", json_new_tru());
  json_val v1 = json_new_obj();
  json_obj_set(v0, "baz", v1);
  json_obj_set(v1, "Mercury", json_new_nul());
  json_obj_set(v1, "Venus", json_new_num(0.000000000004));
  json_obj_set(v1, "Earth", json_new_obj());
  json_val v2 = json_new_obj();
  json_obj_set(v1, "Mars", v2);
  json_obj_set(v2, "Wyoming", json_new_str("Hello, world!"));
  json_obj_set(v2, "Montana", json_new_str("Hi.\nThis is a test.\n"));
  json_obj_set(v2, "Idaho", json_new_nul());
  json_obj_set(v1, "Saturn", json_new_arr());
  json_val v3 = json_new_arr();
  json_obj_set(v0, "bif", v3);
  json_arr_add(v3, json_new_num(-1));
  json_arr_add(v3, json_new_num(3.14159265));
  json_arr_add(v3, json_new_num(0));
  json_arr_add(v3, json_new_nul());
  json_arr_add(v3, json_new_obj());

  json_print(v0, stdout, JSON_FORMAT_MIN);
  
  json_free(v0);
}


