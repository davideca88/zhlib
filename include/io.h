#ifndef IO_H
#define IO_H

/**
 * exit - Exits the process
 *
 * @exit_code: exit code
 */
void __exit(int exit_code);

/**
 * string_length - Returns the length of a null terminated string
 *
 * @str: string buffer
 *
 * Return: length of @str
 */
int string_length(char *str);

/**
 * print_string - Prints a string to stdout
 *
 * @str: string to be printed
 */
void print_string(char *str);

/**
 * print_char - Prints a char (u8) to stdout
 *
 * @ch: char to be printed
 */
void print_char(char ch);

/**
 * print_newline - Prints a '\n'
 */
void print_newline(void);

/**
 * print_uint - Prints an u64 to stdout
 *
 * @no: u64 to be printed
 */
void print_uint(unsigned long n);

/**
 * print_int - Prints a i64 to stdout
 *
 * @no: i64 to be printed
 */
void print_int(long n);

/**
 * read_char - Reads a char (u8) from stdin
 *
 * Return: char read
 */
char read_char(void);

/**
 * read_word - Reads a word (u8[]) from stdin to buf. Skips white spaces
 *
 * @buf: buffer to store the read word
 * @buf_size: size of the buffer
 *
 * Return: @buf address if the word fits on @buf, 0 otherwise
 */
char *read_word(char *buf, unsigned long buf_size);

/**
 * parse_uint - Parses an u64 from a string and returns the string char count
 *              and the u64 on %rdx:%rax
 *
 * @str: input number string
 *
 * Return: input string char count on upper 64 bits
 *         and integer parsed on lower 64 bits
 */
__int128 parse_uint(char *str);

/**
 * parse_int - Parses an i64 from a string and returns the string char count
 *              and the i64 on %rdx:%rax
 *
 * @str: input number string
 *
 * Return: input string char count on upper 64 bits
 *         and integer parsed on lower 64 bits
 */
__int128 parse_int(char *str);

/**
 * string_equals - Returns 1 if strings are equals, returns 0 otherwise
 *
 * @str0: input string 0
 * @str1: input string 1
 * 
 * Return: 1 if string are equals, 0 otherwise
 */
unsigned long string_equals(char *str0, char* str1);

/**
 * string_copy - Copies @str to @buf
 *
 * @str: input string
 * @buf: buffer
 * @buf_size: buffer size
 *
 * Return: @buf address if @str fits on @buf, 0 otherwise
 */
char *string_copy(char* str, char* buf, unsigned long buf_size);

#endif // IO_H
