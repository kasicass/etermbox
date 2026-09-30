%%--------------------------------------------------------------------
%% terminal style (ANSI / ANSI-256 / RGB)
%%--------------------------------------------------------------------

-module(termbox_style).

-export([new/0]).
-export([ansi/0, ansi/1]).
-export([ansi256/0, ansi256/1]).
-export([background/1, background/2]).
-export([foreground/1, foreground/2]).
-export([bold/0, bold/1]).
-export([faint/0, faint/1]).
-export([italic/0, italic/1]).
-export([underline/0, underline/1]).
-export([blink/0, blink/1]).
-export([inverse/0, inverse/1]).
-export([crossed_out/0, crossed_out/1]).
-export([open_code/0, open_code/1]).
-export([reset_code/0]).
-export([render_to_string/1, render_to_string/2]).


%% types

-type terminal_type() :: ansi | ansi256.

-type terminal_style() :: 
    bold
    | faint
    | italic
    | underline
    | blink
    | inverse
    | crossed_out
    | {foreground, integer()}
    | {background, integer()}.

-type terminal_palette() :: #{
    type := terminal_type(),
    styles := [terminal_style()]
}.

-spec new() -> terminal_palette().
new() ->
    #{type => ansi, styles => []}.


%% terminal type (color mode)

-spec ansi() -> terminal_palette().
ansi() ->
    ansi(new()).

-spec ansi(terminal_palette()) -> terminal_palette().
ansi(Palette) ->
    Palette#{type => ansi}.

-spec ansi256() -> terminal_palette().
ansi256() ->
    ansi256(new()).

-spec ansi256(terminal_palette()) -> terminal_palette().
ansi256(Palette) ->
    Palette#{type => ansi256}.


%% styles

-spec background(term()) -> terminal_palette().
background(Color) ->
    background(new(), Color).

-spec background(terminal_palette(), term()) -> terminal_palette().
background(#{styles := Styles} = Palette, Color) ->
    Palette#{styles := [{background, Color} | Styles]}.

-spec foreground(term()) -> terminal_palette().
foreground(Color) ->
    foreground(new(), Color).

-spec foreground(terminal_palette(), term()) -> terminal_palette().
foreground(#{styles := Styles} = Palette, Color) ->
    Palette#{styles := Styles ++ [{foreground, Color}]}.

-spec bold() -> terminal_palette().
bold() ->
    bold(new()).

-spec bold(terminal_palette()) -> terminal_palette().
bold(#{styles := Styles} = Palette) ->
    Palette#{styles := [bold | Styles]}.

-spec faint() -> terminal_palette().
faint() ->
    faint(new()).

-spec faint(terminal_palette()) -> terminal_palette().
faint(#{styles := Styles} = Palette) ->
    Palette#{styles := [faint | Styles]}.

-spec italic() -> terminal_palette().
italic() ->
    italic(new()).

-spec italic(terminal_palette()) -> terminal_palette().
italic(#{styles := Styles} = Palette) ->
    Palette#{styles := [italic | Styles]}.

-spec underline() -> terminal_palette().
underline() ->
    underline(new()).

-spec underline(terminal_palette()) -> terminal_palette().
underline(#{styles := Styles} = Palette) ->
    Palette#{styles := [underline | Styles]}.

-spec blink() -> terminal_palette().
blink() ->
    blink(new()).

-spec blink(terminal_palette()) -> terminal_palette().
blink(#{styles := Styles} = Palette) ->
    Palette#{styles := [blink | Styles]}.

-spec inverse() -> terminal_palette().
inverse() ->
    inverse(new()).

-spec inverse(terminal_palette()) -> terminal_palette().
inverse(#{styles := Styles} = Palette) ->
    Palette#{styles := [inverse | Styles]}.

-spec crossed_out() -> terminal_palette().
crossed_out() ->
    crossed_out(new()).

-spec crossed_out(terminal_palette()) -> terminal_palette().
crossed_out(#{styles := Styles} = Palette) ->
    Palette#{styles := [crossed_out | Styles]}.


%% rendering

-spec reset_code() -> binary().
reset_code() ->
    <<(termbox_screen:escape_code())/binary, "0m">>.

-spec open_code() -> binary().
open_code() ->
    open_code(new()).

-spec open_code(terminal_palette()) -> binary().
open_code(#{styles := []}) ->
    <<>>;
open_code(#{styles := Styles} = Palette) ->
    Sorted = lists:sort(Styles),
    Codes  = [seq(S, Palette) || S <- Sorted],
    Joined = iolist_to_binary(lists:join(";", [to_bin(C) || C <- Codes])),
    <<(termbox_screen:escape_code())/binary, Joined/binary, "m">>.

-spec render_to_string(binary()) -> binary().
render_to_string(Str) ->
    render_to_string(new(), Str).

-spec render_to_string(terminal_palette(), binary()) -> binary().
render_to_string(#{styles := []}, Str) ->
    Str;
render_to_string(Palette, Str) ->
    <<(open_code(Palette))/binary, Str/binary, (reset_code())/binary>>.


%% -- Internal funs --
-spec seq(term(), terminal_palette()) -> binary() | integer().
seq(reset, _)       -> <<"0">>;
seq(bold, _)        -> <<"1">>;
seq(faint, _)       -> <<"2">>;
seq(italic, _)      -> <<"3">>;
seq(underline, _)   -> <<"4">>;
seq(blink, _)       -> <<"5">>;
seq(inverse, _)     -> <<"7">>;
seq(crossed_out, _) -> <<"9">>;
seq({background, Color}, Palette) -> color(Palette, Color, background);
seq({foreground, Color}, Palette) -> color(Palette, Color, foreground).

%% ansi 0-15
-spec color(terminal_palette(), integer(), term()) -> integer().
color(#{type := ansi}, Color, Type) when is_integer(Color), Color < 16 ->
    Base = case Color < 8 of true -> 30; false -> 82 end,
    Base + Color + case Type of background -> 10; foreground -> 0 end.

-spec to_bin(integer() | binary()) -> binary().
to_bin(N) when is_integer(N) -> integer_to_binary(N);
to_bin(B) when is_binary(B) -> B.

