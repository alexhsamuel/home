//------------------------------------------------------------------------------
// TO DO:
// - Use better data structure for arr.
// - Use better data structure for obj.
// - Use wchar_t instead of char* to support Unicode strings.
//------------------------------------------------------------------------------

#include <assert.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "json.h"

// Not sure why Linux's string.h doesn't define this.
extern char* strdup(const char*);

//------------------------------------------------------------------------------

struct json_val;

struct json_arr_ent {
  struct json_val* val;
  struct json_arr_ent* next;
};

struct json_obj_ent {
  char* name;
  struct json_val* val;
  struct json_obj_ent* next;
};

typedef struct json_obj_ent json_obj_ent;

struct json_val {
  JSON_TYPE type;
  union {
    char* str;
    double num;
    struct json_arr_ent* arr;
    struct json_obj_ent* obj;
  } val;
};

// Singletons.
static struct json_val JSON_TRU = { JSON_TYPE_TRU };
static struct json_val JSON_FAL = { JSON_TYPE_FAL };
static struct json_val JSON_NUL = { JSON_TYPE_NUL };

//------------------------------------------------------------------------------

static inline void* xmalloc(size_t size)
{
  void* mem = malloc(size);
  if (mem == NULL) {
    perror("malloc");
    exit(2);
  }
  return mem;
}


static inline void* xstrdup(const char* str)
{
  assert(str != NULL);
  void* dup = strdup(str);
  if (dup == NULL) {
    perror("strdup");
    exit(2);
  }
  return dup;
}

//------------------------------------------------------------------------------

json_val json_new_str(const char* str)
{
  json_val val = xmalloc(sizeof(struct json_val));
  val->type = JSON_TYPE_STR;
  val->val.str = xstrdup(str);
  return val;
}


extern json_val json_new_num(double num)
{
  json_val val = xmalloc(sizeof(struct json_val));
  val->type = JSON_TYPE_NUM;
  val->val.num = num;
  return val;
}


extern json_val json_new_obj()
{
  json_val val = xmalloc(sizeof(struct json_val));
  val->type = JSON_TYPE_OBJ;
  val->val.obj = NULL;
  return val;
}


extern json_val json_new_arr() 
{
  json_val val = xmalloc(sizeof(struct json_val));
  val->type = JSON_TYPE_ARR;
  val->val.arr = NULL;
  return val;
}


extern json_val json_new_tru()
{
  return &JSON_TRU;
}


extern json_val json_new_fal()
{
  return &JSON_FAL;
}


extern json_val json_new_nul()
{
  return &JSON_NUL;
}


extern inline void json_free_val(json_val val)
{
  assert(val != NULL);

  switch (val->type) {
  case JSON_TYPE_TRU:
  case JSON_TYPE_FAL:
  case JSON_TYPE_NUL:
    // Don't free singleton instances.
    break;

  default:
    free(val);
    break;
  }
}


extern void json_free(json_val val)
{
  switch (val->type) {
  case JSON_TYPE_STR:
    free(val->val.str);
    break;

  case JSON_TYPE_OBJ: 
    {
      struct json_obj_ent* ent = val->val.obj;
      while (ent != NULL) {
        free(ent->name);
        json_free(ent->val);
        struct json_obj_ent* next = ent->next;
        free(ent);
        ent = next;
      }
    }
    break;

  case JSON_TYPE_ARR:
    {
      struct json_arr_ent* ent = val->val.arr;
      while (ent != NULL) {
        json_free(ent->val);
        struct json_arr_ent* next = ent->next;
        free(ent);
        ent = next;
      }
    }
    break;

  default:
    break;
  }

  json_free_val(val);
}


//------------------------------------------------------------------------------

inline JSON_TYPE json_get_type(json_val val)
{
  assert(val != NULL);
  return val->type;
}


inline const char* json_get_str(json_val str)
{
  assert(str != NULL);
  assert(str->type == JSON_TYPE_STR);
  return str->val.str;
}


inline double json_get_num(json_val num)
{
  assert(num != NULL);
  assert(num->type == JSON_TYPE_NUM);
  return num->val.num;
}


inline size_t json_arr_length(json_val arr)
{
  assert(arr != NULL);
  assert(arr->type == JSON_TYPE_ARR);

  size_t length = 0;
  for (struct json_arr_ent* ent = arr->val.arr; ent != NULL; ent = ent->next)
    ++length;
  return length;
}


inline void json_arr_add(json_val arr, json_val val)
{
  assert(arr != NULL);
  assert(arr->type == JSON_TYPE_ARR);
  assert(val != NULL);

  struct json_arr_ent* new = xmalloc(sizeof(struct json_arr_ent));
  new->val = val;
  new->next = NULL;

  struct json_arr_ent** ent;
  for (ent = &arr->val.arr; *ent != NULL; ent = &(*ent)->next)
    ;
  *ent = new;
}


json_val json_arr_get(json_val arr, size_t i)
{
  assert(arr != NULL);
  assert(arr->type == JSON_TYPE_ARR);

  struct json_arr_ent* ent = arr->val.arr;
  for (; i > 0; --i) {
    assert(ent != NULL);
    ent = ent->next;
  }
  assert(ent != NULL);
  return ent->val;
}


size_t json_obj_length(json_val obj)
{
  assert(obj != NULL);
  assert(obj->type == JSON_TYPE_OBJ);

  size_t length = 0;
  for (struct json_obj_ent* ent = obj->val.obj; ent != NULL; ent = ent->next)
    ++length;
  return length;
}


void json_obj_set(json_val obj, const char* name, json_val val)
{
  assert(obj != NULL);
  assert(obj->type == JSON_TYPE_OBJ);
  assert(val != NULL);

  json_obj_ent** ent;
  for (ent = &obj->val.obj; *ent != NULL; ent = &(*ent)->next) 
    assert(strcmp((*ent)->name, name) != 0);
  struct json_obj_ent* new = xmalloc(sizeof(struct json_obj_ent));
  new->name = xstrdup(name);
  new->val = val;
  new->next = NULL;
  *ent = new;
}


json_val json_obj_get(json_val obj, const char* name)
{
  assert(obj != NULL);
  assert(obj->type == JSON_TYPE_OBJ);

  for (json_obj_ent* ent = obj->val.obj; ent != NULL; ent = ent->next)
    if (strcmp(ent->name, name) == 0)
      return ent->val;
  return NULL;
}


//------------------------------------------------------------------------------

// Forard declaration.
static void _print_val(json_val, FILE*, int, size_t);

static void _print_str(char* str, FILE* out)
{
  putc('"', out);
  for (char* c = str; *c != '\0'; ++c)
    switch (*c) {
    case '"':
    case '\\':
      putc('\\', out);
      putc(*c, out);
      break;

    case '\b':
      putc('\\', out);
      putc('b', out);
      break;

    case '\f':
      putc('\\', out);
      putc('f', out);
      break;

    case '\n':
      putc('\\', out);
      putc('n', out);
      break;

    case '\r':
      putc('\\', out);
      putc('r', out);
      break;

    case '\t':
      putc('\\', out);
      putc('t', out);
      break;

    default:
      assert(isprint(*c));
      putc(*c, out);
      break;
    }
  putc('"', out);
}


static void _print_num(json_val num, FILE* out)
{
  fprintf(out, "%lg", num->val.num);
}


static inline void _sep(int indent, size_t level, FILE* out)
{
  if (indent == JSON_FORMAT_MIN)
    ;
  else if (indent == JSON_FORMAT_ONE_LINE) 
    putc(' ', out);
  else {
    putc('\n', out);
    for (size_t i = 0; i < indent * level; ++i)
      putc(' ', out);
  }
}


static void _print_obj(json_val obj, FILE* out, int indent, size_t level)
{
  putc('{', out);
  for (struct json_obj_ent* ent = obj->val.obj; ent != NULL; ent = ent->next) {
    _sep(indent, level + 1, out);
    _print_str(ent->name, out);
    putc(':', out);
    if (indent != JSON_FORMAT_MIN)
      putc(' ', out);
    _print_val(ent->val, out, indent, level + 1);
    if (ent->next != NULL)
      putc(',', out);
  }
  _sep(indent, level, out);
  putc('}', out);
}


static void _print_arr(json_val arr, FILE* out, int indent, size_t level)
{
  putc('[', out);
  for (struct json_arr_ent* ent = arr->val.arr; ent != NULL; ent = ent->next) {
    _sep(indent, level + 1, out);
    _print_val(ent->val, out, indent, level + 1);
    if (ent->next != NULL)
      putc(',', out);
  }
  _sep(indent, level, out);
  putc(']', out);
}


static void _print_val(json_val val, FILE* out, int indent, size_t level)
{
  switch (val->type) {
  case JSON_TYPE_STR:
    _print_str(val->val.str, out);
    break;

  case JSON_TYPE_NUM:
    _print_num(val, out);
    break;

  case JSON_TYPE_OBJ:
    _print_obj(val, out, indent, level);
    break;

  case JSON_TYPE_ARR:
    _print_arr(val, out, indent, level);
    break;

  case JSON_TYPE_TRU:
    fputs("true", out);
    break;

  case JSON_TYPE_FAL:
    fputs("false", out);
    break;

  case JSON_TYPE_NUL:
    fputs("null", out);
    break;
  }
}


void json_print(json_val val, FILE* out, int indent)
{
  assert(val != NULL);
  assert(
       indent == JSON_FORMAT_MIN 
    || indent == JSON_FORMAT_ONE_LINE 
    || indent >= 0);

  _print_val(val, out, indent, 0);
  if ((val->type == JSON_TYPE_OBJ || val->type == JSON_TYPE_ARR) && indent >= 0)
    putc('\n', out);
}


//------------------------------------------------------------------------------

static json_val _parse_val(const char**);

static inline int _eat(const char** json, char c)
{
  if (**json == c) {
    ++*json;
    return 1;
  }
  else
    return 0;
}


static inline void _skip_space(const char** json)
{
  while (isspace(**json))
    ++*json;
}


static char* _parse_str(const char** json)
{
  const char* j = *json;

  // Start with a double quote.
  if (! _eat(&j, '"'))
    return NULL;

  // Count the length of the string.
  size_t length = 0;
  for (const char* c = j; *c != '"'; ++c) {
    if (*c == '\0') 
      // Hit the end of string inside a quoted string.  Leave the position to
      // the start of the string.
      return NULL;
    // Don't count an escape character.
    _eat(&c, '\\');
    ++length;
  }

  // Now go back and build the string.
  char* str = xmalloc(length + 1);
  char* d = str;
  while (1) {
    if (_eat(&j, '"'))
      break;
    // Skip over the escape character, but treat the next character specially.
    else if (_eat(&j, '\\')) 
      switch (*j) {
      case '"':
      case '\\':
      case '/':
        *d = *j;
        break;

      case 'b':
        *d = '\b';
        break;
        
      case 'f':
        *d = '\f';
        break;

      case 'n':
        *d = '\n';
        break;

      case 'r':
        *d = '\r';
        break;

      case 't':
        *d = '\t';
        break;

      default:
        // Unknown escape sequence.
        free(str);
        *json = j;
        return NULL;
      }
    else 
      // Normal character; copy it.
      *d = *j;
    ++j;
    ++d;
  }
  *json = j;
  *d++ = '\0';
  assert(d - str == length + 1);
  return str;
}


static json_val _parse_obj(const char** json)
{
  // Start with a left curly.
  if (! _eat(json, '{'))
    return NULL;
  _skip_space(json);

  json_val obj = json_new_obj();

  if (_eat(json, '}'))
    return obj;
  
  while (1) {
    _skip_space(json);
    char* name = _parse_str(json);
    if (name == NULL) {
      json_free(obj);
      return NULL;
    }

    _skip_space(json);
    if (! _eat(json, ':')) {
      free(name);
      json_free(obj);
      return NULL;
    }

    _skip_space(json);
    json_val val = _parse_val(json);
    if (val == NULL) {
      free(name);
      json_free(obj);
      return NULL;
    }

    // FIXME: Detect duplicates.
    json_obj_set(obj, name, val);

    _skip_space(json);
    if (_eat(json, ','))
      continue;
    else if (_eat(json, '}'))
      break;
    else {
      json_free(obj);
      return NULL;
    }
  }

  return obj;
}


static json_val _parse_arr(const char** json)
{
  // Start with a left bracket;
  if (! _eat(json, '['))
    return NULL;

  json_val arr = json_new_arr();

  _skip_space(json);
  if (_eat(json, ']'))
    return arr;
  
  while (1) {
    _skip_space(json);
    json_val val = _parse_val(json);
    if (val == NULL) {
      json_free(arr);
      return NULL;
    }

    // FIXME: Detect duplicates.
    json_arr_add(arr, val);

    _skip_space(json);
    if (_eat(json, ','))
      continue;
    else if (_eat(json, ']'))
      break;
    else {
      json_free(arr);
      return NULL;
    }
  }

  return arr;
}


static json_val _parse_num(const char** json)
{
  double num;
  int chars;
  if (sscanf(*json, "%lg%n", &num, &chars) == 1) {
    *json += chars;
    return json_new_num(num);
  }
  else
    return NULL;
}


static json_val _parse_val(const char** json)
{
  json_val val;

  _skip_space(json);
  if (**json == '"') {
    char* str = _parse_str(json);
    val = str == NULL ? NULL : json_new_str(str);
  }
  else if (**json == '{')
    val = _parse_obj(json);
  else if (**json == '[')
    val = _parse_arr(json);
  else if (**json == '-' || isdigit(**json))
    val = _parse_num(json);
  else if (strncmp(*json, "true", 4) == 0) {
    *json += 4;
    val = json_new_tru();
  }
  else if (strncmp(*json, "false", 5) == 0) {
    *json += 5;
    val = json_new_fal();
  }
  else if (strncmp(*json, "null", 4) == 0) {
    *json += 4;
    val = json_new_nul();
  }
  else 
    val = NULL;
  return val;
}


json_val json_parse(const char* json, const char** end)
{
  json_val val = _parse_val(&json);
  if (end != NULL)
    *end = json;
  return val;
}


