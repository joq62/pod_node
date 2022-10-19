%%%-------------------------------------------------------------------
%% @doc pod_node public API
%% @end
%%%-------------------------------------------------------------------

-module(pod_node_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    AllSpec=application:get_all_env(pod_node),
 %   io:format("AllSpec ~p~n",[{AllSpec,?MODULE,?LINE}]),
    {connect_nodes,ConnectNodes}=lists:keyfind(connect_nodes,1,AllSpec),
    {pod_dir,PodDir}=lists:keyfind(pod_dir,1,AllSpec),
 
    application:stop(common),
    application:stop(sd),
    ok=application:start(common),
    ok=application:start(sd),
    
    pod_node_sup:start_link([
			     ConnectNodes,
			     PodDir
			    ]).

stop(_State) ->
    ok.

%% internal functions
