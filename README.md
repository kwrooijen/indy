# Indent of Doom

Indent of doom is a minor mode for Emacs which lets you add custom indentation rules.

## Install

This package requires the Dash package
[Get it here](https://github.com/magnars/dash.el)
Once you have that you can continue installing Indent of Doom

```
git clone git@github.com:AtticHacker/indent-of-doom
```
Put this in your load path and require it
```
(require 'indent-of-doom)
```

## Usage

### DSL Functions

#### Targets
* prev `Previous line`
* current `Current line`
* next `Next line`

#### Target functions
* ends-on `Takes 1 or more strings. Returns true of the target line ends with one of the arguments`
* starts-with `Takes 1 or more strings. Returns true of the target line starts with one of the arguments`
* indent `Takes optionally 1 integer argument. Get the indent level of the target line in space + (argument * tab-width)`
* indent-char `Takes no arguments. Get the first character of the target line.`
* indent-char-is `Takes 1 or more strings. Compare the first character of the target line with the argument.`

### Using the DSL
Let's say as an example that we are writing a list in Elixir code:

```
my_list_variable = [
                    1,
                    2,
                    3,
                    4
                    5
                   ]
```

This is how Elixir mode would normally indent this list. However I don't find this practical.
Using indent-of-doom we can /monkey patch/ this.
Inside your emacs config file add this:
```
(setq my-doom '(
   (elixir-mode . (
       ((current 'starts-with "]") (prev 'indent -1))
       ((prev 'ends-on "[")        (prev 'indent 1))
       ((prev 'ends-on ",")        (prev 'indent))
   ))
))
```

- **line** 1
    - Set the my-doom variable
- **line** 2
    - Add rules for elixir-mode
- **line** 3
    - If the current line starts with the character "]" then
the current line should have the same indentation as the
previous line MINUS 1 tab-width.
- **line** 4
    - If the previous line ends with the character "[" then
the current line should have the same indentation as the
previous line PLUS 1 tab-width.
- **line** 5
    - If the previous line ends with the character "," then
the current line should have the same indentation as the
previous line.

Now if we enable indent-of-doom-mode inside our Elixir file it will now indent as follows:

```
my_list_variable = [
    1,
    2,
    3,
    4
    5
]
```

Another example:

```
anon_function_of_doom_and_destruction = fn(x) ->
                                            where_am_i?(x)
                                        end
```
Adding these rules:

```
(setq my-doom '(
   (elixir-mode . (
       ((and (current 'starts-with "end")(prev 'ends-on ") ->")) (prev 'indent))
       ((current 'starts-with "end") (prev 'indent -1))
       ((prev 'ends-on ") ->")       (prev 'indent 1))
       ((current 'starts-with "]")   (prev 'indent -1))
       ((prev 'ends-on "[")          (prev 'indent 1))
       ((prev 'ends-on ",")          (prev 'indent))
   ))
))
```

Resulting in:

```
anon_function_of_doom_and_destruction = fn(x) ->
  where_am_i?(x)
end
```

The first case however, is very common among many languages, not just Elixir. Let's make it work for all languages instead.

```
(setq my-doom '(
   (all . (
       ((current 'starts-with "]") (prev 'indent -1))
       ((prev 'ends-on "[")        (prev 'indent 1))
       ((prev 'ends-on ",")        (prev 'indent))
   ))
   (elixir-mode . (
       ((and (current 'starts-with "end")(prev 'ends-on ") ->")) (prev 'indent))
       ((current 'starts-with "end") (prev 'indent -1))
       ((prev 'ends-on ") ->")       (prev 'indent 1))
   ))
))
```
Now the fn rule is only applied to elixir mode, and the list rules are applied to all modes.

Some lists however are written with curly braces instead of square brackets, let's fix that.

```
(setq my-doom '(
   (all . (
       ((current 'starts-with "]" "}")  (prev 'indent -1))
       ((prev 'ends-on "[" "{")         (prev 'indent 1))
       ((prev 'ends-on ",")             (prev 'indent))
   ))
   (elixir-mode . (
       ((and (current 'starts-with "end") (prev 'ends-on ") ->")) (prev 'indent))
       ((current 'starts-with "end") (prev 'indent -1))
       ((prev 'ends-on ") ->")       (prev 'indent 1))
   ))
))
```
