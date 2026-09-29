%%--------------------------------------------------------------------
%% terminal style (ANSI / ANSI-256 / RGB)
%%
%% #{type := ansi | ansi256, styles := [Spec]}
%%--------------------------------------------------------------------

-module(termbox_style).

-export([new/0]).
-export([background/1, background/2]).
-export([foreground/1, foreground/2]).
-export([open_code/0, open_code/1]).
-export([reset_code/0]).
-export([render_to_string/1, render_to_string/2]).


-spec new() -> map().
new() ->
    #{type => ansi, styles => []}.


-spec background(term()) -> map().
background(Color) ->
    background(new(), Color).

-spec background(map(), term()) -> map().
background(#{styles := Styles} = Style, Color) ->
    Style#{styles := Styles ++ [{background, Color}]}.

-spec foreground(term()) -> map().
foreground(Color) ->
    foreground(new(), Color).

-spec foreground(map(), term()) -> map().
foreground(#{styles := Styles} = Style, Color) ->
    Style#{styles := Styles ++ [{foreground, Color}]}.


-spec reset_code() -> binary().
reset_code() ->
    <<(termbox_screen:escape_code())/binary, "0m">>.

-spec open_code() -> binary().
open_code() ->
    open_code(new()).

-spec open_code(map()) -> binary().
open_code(#{styles := []}) ->
    <<>>;
open_code(#{styles := Styles} = Style) ->
    Sorted = lists:sort(Styles),
    Codes  = [seq(S, Style) || S <- Sorted],
    Joined = iolist_to_binary(lists:join(";", [to_bin(C) || C <- Codes])),
    <<(termbox_screen:escape_code())/binary, Joined/binary, "m">>.

-spec render_to_string(binary()) -> binary().
render_to_string(Str) ->
    render_to_string(new(), Str).

-spec render_to_string(map(), binary()) -> binary().
render_to_string(#{styles := []}, Str) ->
    Str;
render_to_string(Style, Str) ->
    <<(open_code(Style))/binary, Str/binary, (reset_code())/binary>>.


%% -- Internal funs --

seq(reset, _)       -> <<"0">>;
seq(bold, _)        -> <<"1">>;
seq(faint, _)       -> <<"2">>;
seq(italic, _)      -> <<"3">>;
seq(underline, _)   -> <<"4">>;
seq(blink, _)       -> <<"5">>;
seq(inverse, _)     -> <<"7">>;
seq(crossed_out, _) -> <<"9">>;
seq({background, Color}, Style) -> color(Style, Color, background);
seq({foreground, Color}, Style) -> color(Style, Color, foreground).

%% ansi 0-15
color(#{type := ansi}, Color, Type) when is_integer(Color), Color < 16 ->
    Base = case Color < 8 of true -> 30; false -> 82 end,
    Base + Color + case Type of background -> 10; foreground -> 0 end.

to_bin(N) when is_integer(N) -> integer_to_binary(N);
to_bin(B) when is_binary(B) -> B.

