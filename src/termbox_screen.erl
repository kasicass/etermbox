-module(termbox_screen).

-export([escape_code/0]).

-spec escape_code() -> binary().
escape_code() ->
    <<"\e[">>.

