#!/usr/bin/env sh

rebar3 compile
erl -noshell -pa _build/default/lib/termbox/ebin -eval 'termbox_examples:show_all(), init:stop().'

