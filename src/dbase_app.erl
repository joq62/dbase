%%%-------------------------------------------------------------------
%% @doc dbase public API
%% @end
%%%-------------------------------------------------------------------

-module(dbase_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    dbase_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
