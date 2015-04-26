#include <stdio.h>

#define JSON_FORMAT_MIN (-2)
#define JSON_FORMAT_ONE_LINE (-1)

typedef enum {
  JSON_TYPE_STR,
  JSON_TYPE_NUM,
  JSON_TYPE_OBJ,
  JSON_TYPE_ARR,
  JSON_TYPE_TRU,
  JSON_TYPE_FAL,
  JSON_TYPE_NUL,
}
JSON_TYPE;

typedef struct json_val* json_val;

extern json_val json_new_str(const char*);
extern json_val json_new_num(double);
extern json_val json_new_obj();
extern json_val json_new_arr();
extern json_val json_new_tru();
extern json_val json_new_fal();
extern json_val json_new_nul();

extern void json_free_val(json_val);
extern void json_free(json_val);

extern JSON_TYPE json_get_type(json_val);
extern const char* json_get_str(json_val);
extern double json_get_num(json_val);

extern size_t json_arr_length(json_val);
extern void json_arr_add(json_val, json_val);
extern json_val json_arr_get(json_val, size_t);

extern size_t json_obj_length(json_val);
extern void json_obj_set(json_val, const char*, json_val);
extern json_val json_obj_get(json_val, const char*);

extern void json_print(json_val, FILE*, int);

extern json_val json_parse(const char*, const char**);

