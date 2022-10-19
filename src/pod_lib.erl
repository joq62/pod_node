%%% -------------------------------------------------------------------
%%% @author  : Joq Erlang
%%% @doc: : 
%%% Created :
%%% Node end point  
%%% Creates and deletes Pods
%%% 
%%% API-kube: Interface 
%%% Pod consits beams from all services, app and app and sup erl.
%%% The setup of envs is
%%% -------------------------------------------------------------------
-module(pod_lib).   

-export([
	 load_start/4,
	 stop_unload/2
	]).



%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
load_start(Service,GitPath,BaseDir,EnvArgs)->
    ServiceDir=filename:join(BaseDir,Service),
    Result=case git_clone_to_dir(GitPath,ServiceDir) of
	       {error,Reason}->
		   {error,Reason};
	       {ok,CloneResult}->
		   App=list_to_atom(Service),
		   ServiceDir=filename:join(BaseDir,Service),
		   Paths=[ServiceDir,filename:join(ServiceDir,"ebin")],
		   case load(App,Paths) of
		       {error,Reason}->
			   {error,[Reason,clone_result,CloneResult]};
		       ok->
			   application:set_env(EnvArgs),
			   case start(App) of
			       ok->
				   ok;
			       {error,Reason}->
				   {error,[Reason,clone_result,CloneResult]}
			   end
		   end
	   end,
    Result.
			   
			   

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
stop_unload(Service,BaseDir)->
    ServiceDir=filename:join(BaseDir,Service),
    App=list_to_atom(Service),
    application:unload(App), 
    os:cmd("rm -rf "++ServiceDir), 
    timer:sleep(1000),
    application:stop(App).
    
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------



%%%---------- Internal ----------
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
git_clone(GitPath,ServiceDir)->
    os:cmd("rm -rf "++ServiceDir),
    timer:sleep(1000),
    GitResult=os:cmd("git clone "++GitPath++" "++ServiceDir),
    timer:sleep(1000),
    Result=case filelib:is_dir(ServiceDir) of
	       false->
		   {error,[failed_to_clone,GitPath,GitResult]};
	       true->
		   ok
	   end,
    
    Result.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

git_clone_to_dir(GitPath,ServiceDir)->
    TempDirName=erlang:integer_to_list(os:system_time(microsecond),36)++".dir",
    TempDir=TempDirName,
	  %  io:format("TempDir ~p~n",[TempDir]),
    os:cmd("rm -rf "++ServiceDir),
    Result=case file:make_dir(ServiceDir) of
	        {error,Reason}->
		   {error,Reason};
	       ok->
		   case os:cmd("rm -rf "++TempDir) of
		       []->
			   case file:make_dir(TempDir) of
			       ok->
				   CloneResult=os:cmd("git clone "++GitPath++" "++TempDir),
				   case os:cmd("mv  "++TempDir++"/*"++" "++ServiceDir) of
				       []->
					   os:cmd("rm -r  "++TempDir),
					   {ok,CloneResult};
				       Reason->
					   {error,[Reason,clone_result,CloneResult,?MODULE,?LINE]}
				   end;
			       {error,Reason}->
				   {error,Reason}
			   end;
		       Reason->
			   {error,[Reason,?MODULE,?LINE]}
		   end
	   end,	       
    Result.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
load(App,Paths)->
    AddedPathsResult=[{Path,code:add_patha(Path)}||Path<-Paths,
						   true/=code:add_patha(Path)],
    Result=case AddedPathsResult of
	       []-> % ok
		   case application:load(App) of
		       {error, Reason}->
			   {error, [Reason,App]};
		       ok->
			   ok
		   end;
	       ErrorList->
		   {error,[ErrorList]}
	   end,
    Result.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
start(App)->
    application:start(App).


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
