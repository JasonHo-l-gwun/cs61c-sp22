#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "snake_utils.h"
#include "state.h"

/* Helper function definitions */
static char get_board_at(game_state_t* state, int x, int y);
static void set_board_at(game_state_t* state, int x, int y, char ch);
static bool is_tail(char c);
static bool is_snake(char c);
static char body_to_tail(char c);
static int incr_x(char c);
static int incr_y(char c);
static void find_head(game_state_t* state, int snum);
static char next_square(game_state_t* state, int snum);
static void update_tail(game_state_t* state, int snum);
static void update_head(game_state_t* state, int snum);

/* Helper function to get a character from the board (already implemented for you). */
static char get_board_at(game_state_t* state, int x, int y) {
  return state->board[y][x];
}

/* Helper function to set a character on the board (already implemented for you). */
static void set_board_at(game_state_t* state, int x, int y, char ch) {
  state->board[y][x] = ch;
}

/* Task 1 */
game_state_t* create_default_state() {
  // TODO: Implement this function.
  game_state_t *state = (game_state_t*) malloc(sizeof(game_state_t));
  if (!state) return NULL;
  state->num_snakes = 1;
  state->snakes = (snake_t*) malloc(state->num_snakes * sizeof(snake_t));
  if (!state->snakes) {
    free(state);
    return NULL;
  }
  snake_t *snake = (snake_t*) malloc(sizeof(snake_t));
  if (!snake) {
    free(state->snakes);
    free(state);
    return NULL;
  }

  // 初始化蛇
  snake->live = true;
  snake->head_x = 5;
  snake->head_y = 4;
  snake->tail_x = 4;
  snake->tail_y = 4;

  // 初始化棋盘状态
  int row = 10;
  int col = 14;
  state->x_size = col;
  state->y_size = row;
  state->snakes[0] = *snake;

  // 创建棋盘
  state->board = (char**) malloc(row * sizeof(char*));
  if (!state->board) {
    free(state);
    return NULL;
  }
  for (int i = 0; i < row; i++) {
    state->board[i] = malloc(col + 1 * sizeof(char));
    if (!state->board[i]) {
      for (int j = 0; j < i; j++) free(state->board[j]);
      free(state->board);
      free(state);
      return NULL;
    }
  }

  // 给棋盘赋值
  for (int i = 0; i < row; i++) {
    if (i == 0 || i == row - 1) strcpy(state->board[i], "##############");
    else strcpy(state->board[i], "#            #");
  }

  state->board[2][9] = '*';
  state->board[4][4] = 'd';
  state->board[4][5] = '>';
  return state;
}

/* Task 2 */
void free_state(game_state_t* state) {
  // TODO: Implement this function.
  if (state == NULL) {
    return;
  }

  if (!state->board) {
    for (unsigned int i = 0; i < state->y_size; i++) {
      free(state->board[i]); 
    }
    free(state->board);
  }

  if (!state->snakes) {
    free(state->snakes);
  }

  free(state);
}

/* Task 3 */
void print_board(game_state_t* state, FILE* fp) {
  // TODO: Implement this function.
  for (int row = 0; row < state->y_size; row++) {
    fprintf(fp, "%s\n", state->board[row]); 
  }
  return;
}

/* Saves the current state into filename (already implemented for you). */
void save_board(game_state_t* state, char* filename) {
  FILE* f = fopen(filename, "w");
  print_board(state, f);
  fclose(f);
}

/* Task 4.1 */
static bool is_tail(char c) {
  // TODO: Implement this function.
  if (c == 'w' || c == 'a' || c == 's' | c == 'd') {
    return true;
  }
  return false;
}

static bool is_snake(char c) {
  // TODO: Implement this function.
  if (is_tail(c) || c == '^' || c == '<' || c == 'v' || c == '>' || c == 'x') {
    return true;
  }
  return false;
}

static char body_to_tail(char c) {
  // TODO: Implement this function.
  switch (c)
  {
  case '^':
    return 'w'; 
  case '<':
    return 'a';
  case 'v':
    return 's';
  case '>':
    return 'd';
  default:
    return '?';
  }
}

static int incr_x(char c) {
  // TODO: Implement this function.
  if (c == '>' || c == 'd') return 1;
  else if (c == '<' || c == 'a') return -1;
  return 0;
}

static int incr_y(char c) {
  // TODO: Implement this function.
  if (c == 'v' || c == 's') return 1;
  else if (c == '^' || c == 'w') return -1;
  return 0;
}

/* Task 4.2 */
static char next_square(game_state_t* state, int snum) {
  // TODO: Implement this function.
  int x = state->snakes[snum].head_x;
  int y = state->snakes[snum].head_y;
  char cell = get_board_at(state, x, y);
  int add_num = (cell == 'v' || cell == '>' ? 1 : -1);
  if (cell == '^' || cell == 'v') return get_board_at(state, x, y + add_num);
  else if (cell == '<' || cell == '>') return get_board_at(state, x + add_num, y);
  return '?';
}

/* Task 4.3 */
static void update_head(game_state_t* state, int snum) {
  // TODO: Implement this function.
  int h_x = state->snakes[snum].head_x;
  int h_y = state->snakes[snum].head_y;
  char cell = get_board_at(state, h_x, h_y);
  int add_num = (cell == 'v' || cell == '>' ? 1 : -1);
  if (cell == '^' || cell == 'v') {
    state->snakes[snum].head_y += add_num;
    set_board_at(state, h_x, state->snakes[snum].head_y, cell);
  } else if (cell == '<' || cell == '>') {
    state->snakes[snum].head_x += add_num;
    set_board_at(state, state->snakes[snum].head_x, h_y, cell);
  }
  return;
}

/* Task 4.4 */
static void update_tail(game_state_t* state, int snum) {
  // TODO: Implement this function.
  int t_x = state->snakes[snum].tail_x;
  int t_y = state->snakes[snum].tail_y;
  char cell = get_board_at(state, t_x, t_y);
  int add_num = (cell == 's' || cell == 'd' ? 1 : -1);
  if (cell == 'w' || cell == 's') {
    set_board_at(state, t_x, t_y, ' ');
    state->snakes[snum].tail_y += add_num;
    char new_tail = body_to_tail(get_board_at(state, t_x, state->snakes[snum].tail_y));
    set_board_at(state, t_x, state->snakes[snum].tail_y, new_tail);
  } else if (cell == 'a' || cell == 'd') {
    set_board_at(state, t_x, t_y, ' ');
    state->snakes[snum].tail_x += add_num;
    char new_tail = body_to_tail(get_board_at(state, state->snakes[snum].tail_x, t_y));
    set_board_at(state, state->snakes[snum].tail_x, t_y, new_tail);
  }
  return;
}

/* Task 4.5 */
void update_state(game_state_t* state, int (*add_food)(game_state_t* state)) {
  // TODO: Implement this function.
  for (int i = 0; i < state->num_snakes; i++) {
    if (!state->snakes[i].live) continue;
    int h_x = state->snakes[i].head_x;
    int h_y = state->snakes[i].head_y;
    char next_char = next_square(state, i);
    if (is_snake(next_char) || next_char == '#') {
      set_board_at(state, h_x, h_y, 'x');
      state->snakes[i].live = false;
    } else if (next_char == '*'){
      update_head(state, i);
      add_food(state);
    } else {
      update_head(state, i);
      update_tail(state, i);
    }
  }
  return;
}

/* Task 5 */
game_state_t* load_board(char* filename) {
  // TODO: Implement this function.
  FILE* file = fopen(filename, "r");
  if (!file) {
      return NULL;
  }

  char* line = NULL;
  size_t linecap = 0;
  ssize_t linelen;

  char** lines = NULL;
  size_t line_count = 0;
  int x_size = 0;

  game_state_t* state = NULL;

  // Read all lines into the lines array
  while ((linelen = getline(&line, &linecap, file)) != -1) {
      // Remove newline character
      if (linelen > 0 && line[linelen - 1] == '\n') {
          line[linelen - 1] = '\0';
          linelen--;
      }

      // Duplicate the line to store in lines array
      char* line_copy = strdup(line);
      if (!line_copy) {
          goto cleanup;
      }

      // Expand the lines array
      char** new_lines = realloc(lines, (line_count + 1) * sizeof(char*));
      if (!new_lines) {
          free(line_copy);
          goto cleanup;
      }
      lines = new_lines;
      lines[line_count++] = line_copy;
  }

  // Check if any lines were read
  if (line_count == 0) {
      goto cleanup;
  }

  // Determine x_size from the first line
  x_size = strlen(lines[0]);

  // Allocate the game_state_t structure
  state = malloc(sizeof(game_state_t));
  if (!state) {
      goto cleanup;
  }

  // Allocate the board array
  state->board = malloc(line_count * sizeof(char*));
  if (!state->board) {
      free(state);
      state = NULL;
      goto cleanup;
  }

  // Transfer ownership of line strings to the board
  for (size_t i = 0; i < line_count; i++) {
      state->board[i] = lines[i];
  }

  // Set the size fields
  state->x_size = x_size;
  state->y_size = line_count;

  // Free the lines array (not the individual strings)
  free(lines);
  lines = NULL;

cleanup:
  // Cleanup temporary resources
  if (lines) {
      for (size_t i = 0; i < line_count; i++) {
          free(lines[i]);
      }
      free(lines);
  }
  free(line);
  fclose(file);

  return state;
}

/* Task 6.1 */
static void find_head(game_state_t* state, int snum) {
  // TODO: Implement this function.
  snake_t* snake = &state->snakes[snum];
  int x = snake->tail_x;
  int y = snake->tail_y;


  char current_char = state->board[y][x];
  // 方向向量：右、下、左、上
  int dx = 0, dy = 0;
  switch (current_char) {
    case 'd': dx = 1;  dy = 0; break;
    case 's': dx = 0; dy = 1; break;
    case 'a': dx = -1; dy = 0; break;
    case 'w': dx = 0; dy = -1; break;
  }
  x += dx;
  y += dy;
  current_char = state->board[y][x];

  int prev_x = x, prev_y = y;
  while (1) {
    if (x < 0 || x >= state->x_size || y < 0 || y >= state->y_size) {
      break;
    }

    current_char = state->board[y][x];
    switch (current_char) {
      case '>': dx = 1;  dy = 0; break;
      case 'v': dx = 0; dy = 1; break;
      case '<': dx = -1; dy = 0; break;
      case '^': dx = 0; dy = -1; break;
      default: // 非箭头符号，结束追踪
        snake->head_x = prev_x;
        snake->head_y = prev_y;
        return;
    }

    // 保存当前位置
    prev_x = x;
    prev_y = y;

    // 移动到下一个位置
    x += dx;
    y += dy;
  }

  // 越界后，设置头部为最后一个有效位置
  snake->head_x = prev_x;
  snake->head_y = prev_y;
}

/* Task 6.2 */
game_state_t* initialize_snakes(game_state_t* state) {
  // TODO: Implement this function.
  if (!state || !state->board) return NULL;
  state->num_snakes = 0;
  state->snakes = NULL; 

  for (int y = 0; y < state->y_size; y++) {
    for (int x = 0; x < state->x_size; x++) {
      if (is_tail(get_board_at(state, x, y))) {
          state->num_snakes++;
      }
    }
  }
 
  if (state->num_snakes > 0) {
    state->snakes = malloc(state->num_snakes * sizeof(snake_t));
    if (!state->snakes) {
      state->num_snakes = 0;
      return NULL;
    }
  }
  int snake_idx = 0;
  for (int y = 0; y < state->y_size; y++) {
    for (int x = 0; x < state->x_size; x++) {
      char c = get_board_at(state, x, y);
      if (is_tail(c)) {
          state->snakes[snake_idx].tail_x = x;
          state->snakes[snake_idx].tail_y = y;
          state->snakes[snake_idx].live = true;  
          find_head(state, snake_idx);         
          snake_idx++;
      }
    }
  }
  return state;
}
