-module(termbox_examples).

-export([hello/0]).

-spec hello() -> ok.
hello() ->
    S1 = termbox_style:background(5),
    S2 = termbox_style:foreground(S1, 3),
    Str = termbox_style:render_to_string(S2, <<"Hello etermbox!">>),
    io:format("~ts~n", [Str]).

