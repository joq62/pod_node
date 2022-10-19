%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : resource discovery accroding to OPT in Action 
%%% This service discovery is adapted to 
%%% Type = application 
%%% Instance ={ip_addr,{IP_addr,Port}}|{erlang_node,{ErlNode}}
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(pod_node).
 
-behaviour(gen_server).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------

%% External exports

%% start_ops_node
%% stop_ops_node 

%% Usecases
% mkdir
% rmdir
% cp_file
% rm_file


% Update config file on one host
% Update config file on all hosts

% delete config file on node 
% 
% start new cluster 
% delete cluster 

% load_start appl on cluster node
% stop_unload appl on cluster node

% read nodelog on node

-export([
	 load_start/4,
	 stop_unload/2,
	 which_services/0
	]).

-export([
	

	]).

-export([
	 start/1,
	 stop/0,
	 appl_start/1,
	 ping/0
	]).


%% gen_server callbacks



-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%%-------------------------------------------------------------------
-record(state,{
	       connect_nodes,
	       pod_dir,
	       services
	       }).


%% ====================================================================
%% External functions
%% ====================================================================

appl_start([])->
    application:start(?MODULE).
%% --------------------------------------------------------------------
  
%% --------------------------------------------------------------------
load_start(Service,GitPath,BaseDir,EnvArgs)->
    gen_server:call(?MODULE,{load_start,Service,GitPath,BaseDir,EnvArgs},infinity).

stop_unload(Service,BaseDir)->
    gen_server:call(?MODULE,{stop_unload,Service,BaseDir},infinity).

which_services()->
    gen_server:call(?MODULE,{which_services},infinity).

%% --------------------------------------------------------------------

start(AllEnv)->
    gen_server:start_link({local, ?MODULE}, ?MODULE,AllEnv , []).
stop()-> gen_server:call(?MODULE, {stop},infinity).

ping()->
    gen_server:call(?MODULE,{ping},infinity).

%% cast

%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([ConnectNodes,PodDir]) ->
    
    
    {ok, #state{
	    connect_nodes=ConnectNodes,
	    pod_dir=PodDir,
	    services=[]
	   }}.   
 

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
handle_call({load_start,Service,GitPath,BaseDir,EnvArgs},_From, State) ->
    Reply=case lists:keymember(Service,1,State#state.services) of
	      true->
		  NewState=State,
		  {error,[already_started,Service]};
	      false->
		  case pod_lib:load_start(Service,GitPath,BaseDir,EnvArgs) of
		      {error,Reason}->
			  NewState=State,
			  {error,Reason};
		      ok->
			  NewServices=[{Service,{date(),time()}}|State#state.services],
			  NewState=State#state{services=NewServices},
			  ok
		  end
	  end,
    {reply, Reply, NewState};

handle_call({stop_unload,Service,BaseDir},_From, State) ->
    Reply=case lists:keymember(Service,1,State#state.services) of
	      false->
		  NewState=State,
		  {error,[eexists,Service]};
	      true->
		  case pod_lib:stop_unload(Service,BaseDir) of
		      {error,Reason}->
			  NewState=State,
			  {error,Reason};
		      ok->
			  NewServices=lists:keydelete(Service,1,State#state.services),
			  NewState=State#state{services=NewServices},
			  ok
		  end
	  end,
    {reply, Reply, NewState};

handle_call({which_services},_From, State) ->
    Reply=State#state.services,
    {reply, Reply, State};

%% --------------------------------------------------------------------

handle_call({ping},_From, State) ->
    Reply=pong,
    {reply, Reply, State};

handle_call(Request, From, State) ->
    Reply = {unmatched_signal,?MODULE,Request,From},
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(Msg, State) ->
    io:format("unmatched match cast ~p~n",[{Msg,?MODULE,?LINE}]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_info({ssh_cm,_,_}, State) ->
   
    {noreply, State};

handle_info(Info, State) ->
    io:format("unmatched match~p~n",[{Info,?MODULE,?LINE}]), 
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
