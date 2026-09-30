-module(termbox_examples).

-export([show_all/0]).

-spec show_all() -> ok.
show_all() ->
    show_background(),
    show_foreground(),
    show_styles().

-spec show_background() -> ok.
show_background() ->
    io:format("background:~n"),
    lists:foreach(
        fun (I) ->
            Style = termbox_style:background(I),
            Str = unicode:characters_to_binary(io_lib:format("color: ~2..0b", [I])),
            Out = termbox_style:render_to_string(Style, Str),
            io:format("  ~ts~n", [Out])
        end, lists:seq(0, 15)).

-spec show_foreground() -> ok.
show_foreground() ->
    io:format("foreground:~n"),
    lists:foreach(
        fun (I) ->
            Style = termbox_style:foreground(I),
            Str = unicode:characters_to_binary(io_lib:format("color: ~2..0b", [I])),
            Out = termbox_style:render_to_string(Style, Str),
            io:format("  ~ts~n", [Out])
        end, lists:seq(0, 15)).

-spec show_styles() -> ok.
show_styles() ->
    io:format("styles:~n"),
    lists:foreach(
        fun (Type) ->
            Style = apply(termbox_style, Type, []),
            Str = atom_to_binary(Type, utf8),
            Out = termbox_style:render_to_string(Style, Str),
            io:format("  ~ts~n", [Out])
        end, [bold, faint, italic, underline, blink, crossed_out]).

