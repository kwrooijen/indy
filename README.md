## Indy

## What is this?
Indy is a library which allows you to adjust your major mode's
indentation rules. This library provides a small EDSL to customize your rules.

Why would you want this?

For example let's say you're working in a team and you have a certain indentation
standard to follow. There might be a chance that the Major mode's indentation
does not comply with these standards. In this case you'd have to adjust
your indentation manually whenever working on your team's project to
stay consistent. A good example is Erlang mode which is explained in the
usage section.

## Installation

This package can be installed through [melpa](http://melpa.milkbox.net/):

    M-x package-install transpose-mark

Then require the package to use indy-mode

    (require 'indy)

## Usage

### DSL Functions

#### Targets
* indy--prev    `Previous line`
* indy--current `Current line`
* indy--next    `Next line`

#### Target functions
* indy--ends-on `Takes 1 or more strings. Returns true if the target line ends with one of the arguments`
* indy--starts-with `Takes 1 or more strings. Returns true if the target line starts with one of the arguments`
* indy--contains `Takes 1 or more strings (regular expression). Returns true if the target line contains this regular expression.`
* indy--indent `Takes optionally 1 integer argument. Get the indent level if the target line in space + (argument * tab-width)`
* indy--indent-char `Takes no arguments. Get the first character of the target line.`

### Using the DSL
Let's say as an example that we are writing a list in Erlang code:

```
MyLongVariable = [
                  1,
                  2,
                  3,
                  4
                  5
                 ].
```

This is how Erlang mode would normally indent this list. However I don't find this practical.
Using indy we can /monkey patch/ this.
Inside your emacs config file add this:
```
(setq indy-rules '(
   (erlang-mode . (
       ((indy--current 'indy--starts-with "]") (indy--prev-tab -1))
       ((indy--prev    'indy--ends-on "[")     (indy--prev-tab 1))
       ((indy--prev    'indy--ends-on ",")     (indy--prev-tab))
   ))
))
```

- **line** 1
    - Set the indy--rules variable
- **line** 2
    - Add rules for erlang-mode
- **line** 3
    - If the current line starts with the character "]" then
the current line should have the same indentation as the
previous line __MINUS__ 1 tab-width.
- **line** 4
    - If the previous line ends with the character "[" then
the current line should have the same indentation as the
previous line __PLUS__ 1 tab-width.
- **line** 5
    - If the previous line ends with the character "," then
the current line should have the same indentation as the
previous line.

Now if we enable indy-mode inside our Erlang file it will now indent as follows:

```
MyLongVariable = [
    1,
    2,
    3,
    4
    5
].
```

Another example:

```
AnonFunctionOfDoomAndDestruction = fun(X) ->
                                           where_am_i
                                   end.
```
Adding these rules:

```
(setq indy-rules '(
    (erlang-mode . (
        ((and (indy--current 'indy--starts-with "end")
         (indy--prev 'indy--ends-on ") ->"))      (indy--prev-tab))
        ((indy--current 'indy--starts-with "end") (indy--prev-tab -1))
        ((indy--prev 'indy--ends-on ") ->")       (indy--prev-tab 1))
        ((indy--current 'indy--starts-with "]")   (indy--prev-tab -1))
        ((indy--prev 'indy--ends-on "[")          (indy--prev-tab 1))
        ((indy--prev 'indy--ends-on ",")          (indy--prev-tab))
   ))
))
```
Resulting in:

```
AnonFunctionOfDoomAndDestruction = fun(X) ->
    where_am_i
end.
```

The first case however, is very common among many languages, not just Erlang. Let's make it work for all languages instead.

```
(setq indy-rules '(
    (all . (
        ((indy--current 'indy--starts-with "]")   (indy--prev-tab -1))
        ((indy--prev 'indy--ends-on "[")          (indy--prev-tab 1))
        ((indy--prev 'indy--ends-on ",")          (indy--prev-tab))
   ))
   (erlang-mode . (
        ((and (indy--current 'indy--starts-with "end")
         (indy--prev 'indy--ends-on ") ->"))      (indy--prev-tab))
        ((indy--current 'indy--starts-with "end") (indy--prev-tab -1))
        ((indy--prev 'indy--ends-on ") ->")       (indy--prev-tab 1))
   ))
))
```
Now the fun rule is only applied to Erlang mode, and the list rules are applied to all modes.

Some lists however are written with curly braces instead of square brackets, let's fix that.

```
(setq indy-rules '(
    (all . (
        ((indy--current 'indy--starts-with "]" "}") (indy--prev-tab -1))
        ((indy--prev 'indy--ends-on "[" "[")        (indy--prev-tab 1))
        ((indy--prev 'indy--ends-on ",")            (indy--prev-tab))
   ))
   (erlang-mode . (
        ((and (indy--current 'indy--starts-with "end")
         (indy--prev 'indy--ends-on ") ->"))      (indy--prev-tab))
        ((indy--current 'indy--starts-with "end") (indy--prev-tab -1))
        ((indy--prev 'indy--ends-on ") ->")       (indy--prev-tab 1))
   ))
))
```
EDSL:
** Targets
* indy--prev
* indy--next
* indy--current

** Target addon
* indy--starts-with
* indy--ends-on
* indy--contains

** Indentors
* indy--next-tab
* indy--current-tab
* indy--prev-char
* indy--next-char
* indy--current-char
* indy--ends-on
