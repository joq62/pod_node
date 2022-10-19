%%%-------------------------------------------------------------------
%% @doc pod_node top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(pod_node_sup).

-behaviour(supervisor).

%-export([start_link/0]).
-export([start_link/1]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link(AllEnv) ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, AllEnv).

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init(AllEnv) ->
    SupFlags = #{strategy => one_for_all,
                 intensity => 0,
                 period => 1},
    ChildSpecs = [#{id=>pod_node,
		    start=>{pod_node,start,[AllEnv]}}],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions
