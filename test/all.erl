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
-module(all).   
 
-export([start/0]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

-define(Id_c1,"c1").

-define(SourceDir,"./test/specs").
-define(DestDir,".").
-define(SpecFiles,["spec.deployment","spec.cluster","spec.host","spec.application"]).
	 

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
-define(HostNames,["c100","c300","c200","c201"]).
-define(HostName,"c100").
-define(ClusterName,"test_cluster").
-define(DeplName,"any_not_same_hosts_not_same_pods").

-define(SourceDepFile,"./test/specs/spec.deployment").
-define(DepFile,"spec.deployment").
-define(SourceClusterFile,"./test/specs/spec.cluster").
-define(ClusterFile,"spec.cluster").
-define(SourceHostFile,"./test/specs/spec.host").
-define(HostFile,"spec.host").
-define(SourceApplicationFile,"./test/specs/spec.application").
-define(ApplicationFile,"spec.application").
-define(LogDir,"logs").

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------


start()->
   
    ok=setup(),

    ok=load_start(),
    ok=stop_unload(),

    io:format("Test OK !!! ~p~n",[?MODULE]),
    init:stop(),
    ok.

    
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
stop_unload()->
     io:format("Start ~p~n",[?FUNCTION_NAME]),

    Service1="test_add",
    Service2="test_sub",
    BaseDir="pod.dir",
    
    ok=pod_node:stop_unload(Service1,BaseDir),
    [{"test_sub",_}
    ]=lists:sort(pod_node:which_services()),
    
    ok=pod_node:stop_unload(Service2,BaseDir),
    []=lists:sort(pod_node:which_services()),
    
    
    
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),    
    ok.
    
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
load_start()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),
    
    Service1="test_add",
    GitPath1="https://github.com/joq62/test_add.git",
    Service2="test_sub",
    GitPath2="https://github.com/joq62/test_sub.git",
    BaseDir="pod.dir",
    EnvArgs=[],
    
    []=pod_node:which_services(),
    ok=pod_node:load_start(Service1,GitPath1,BaseDir,EnvArgs),
    42=test_add:add(20,22),
    ok=pod_node:load_start(Service2,GitPath2,BaseDir,EnvArgs),
    42=test_sub:sub(62,20),
    [
     {"test_add",_},
     {"test_sub",_}
    ]=lists:sort(pod_node:which_services()),
   
    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),    
    ok.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------

	 	 

setup()->
    io:format("Start ~p~n",[?FUNCTION_NAME]),

    file:delete(?ClusterFile),
    {ok,ClusterBin}=file:read_file(?SourceClusterFile),
    ok=file:write_file(?ClusterFile,ClusterBin),
    
    file:delete(?DepFile),
    {ok,DepBin}=file:read_file(?SourceDepFile),
    ok=file:write_file(?DepFile,DepBin),

    file:delete(?HostFile),
    {ok,HostBin}=file:read_file(?SourceHostFile),
    ok=file:write_file(?HostFile,HostBin),

    file:delete(?ApplicationFile),
    {ok,ApplBin}=file:read_file(?SourceApplicationFile),
    ok=file:write_file(?ApplicationFile,ApplBin),
 
    
    ConnectNodes=[node()],
    PodDir="pod.dir",
    os:cmd("rm -rf "++PodDir),
    timer:sleep(1000),
    ok=file:make_dir(PodDir),

    PodNodeEnv=[{pod_node,[{connect_nodes,ConnectNodes},
			   {pod_dir,PodDir}]}],
    
    
    ok=application:set_env(PodNodeEnv),
    ok=application:start(pod_node),
    pong=pod_node:ping(),

    io:format("Stop OK !!! ~p~n",[?FUNCTION_NAME]),

    ok.
