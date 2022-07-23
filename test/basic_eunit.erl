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
-module(basic_eunit).   
 
-export([start/0,
	 install/0,
	 restart/0]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
install()->
    ok=setup(),
    Nodes=test_nodes:get_nodes(),
    [N0,N1,N2]=test_nodes:get_nodes(),
    MnesiaDirs=[{N,atom_to_list(N)}||N<-Nodes],
    DbModuleList=[db_cluster],
    [ok,ok,ok]=[rpc:call(N,code,add_pathsa,[["ebin","test_ebin"]])||N<-Nodes],
    
    %%- SetUp Mnesia dirs
    [rpc:call(N,application,set_env,[[{mnesia,[{dir,MnesiaDir}]}]],1000)||{N,MnesiaDir}<-MnesiaDirs],

    % Install intitial node
    ok=rpc:call(N0,dbase_lib,dynamic_install_start,[N0]),

    % Add the rest
  %  rpc:call(N0,dbase_lib,dynamic_install,[[N1,N2],N0]),
    rpc:call(N0,dbase_lib,dynamic_install,[[N1],N0]),
    rpc:call(N1,dbase_lib,dynamic_install,[[N2],N1]),
 
 
    % Create table and first record
    ok=rpc:call(N0,db_cluster,create_table,[Nodes]),
    {atomic,ok}=rpc:call(N0,db_cluster,create,["cluster_1","cookie_1",["c100","c200"],[{created,date(),time()}]]),

%    timer:sleep(2000),
    %------------------
    io:format("N0 read_all ~p~n",[rpc:call(N0,db_cluster,read_all,[])]),
    io:format("N1  read_all ~p~n",[rpc:call(N1,db_cluster,read_all,[])]),
    io:format("N2  read_all ~p~n",[rpc:call(N2,db_cluster,read_all,[])]),
    
    
    
    %Check
    io:format("mnesia:system_info() ~p~n",[rpc:call(N0,mnesia,system_info,[])]),
    ok=kill_restart_node(N0,N1),
 %   timer:sleep(1000),
 %   init:stop().

    ok.

kill_restart_node(N0,N1)->
    X=rpc:call(N0,db_cluster,read_all,[]),
    X=rpc:call(N1,db_cluster,read_all,[]),

    rpc:call(N0,init,stop,[]),
    io:format("mnesia:system_info() ~p~n",[rpc:call(N1,mnesia,system_info,[])]),
    {aborted,{node_not_running,N0}}=rpc:call(N0,db_cluster,read_all,[]),
    rpc:call(N1,dbase_lib,dynamic_install,[[N0],N1]),
    X=rpc:call(N0,db_cluster,read_all,[]),
    io:format("mnesia:system_info() ~p~n",[rpc:call(N1,mnesia,system_info,[])]),
    ok.
    

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
restart()->
    application:set_env([{mnesia,[{dir,"mnesia_dir"}]}]),
    mnesia:stop(),
    mnesia:start(),
    mnesia:wait_for_tables([cluster], 5000),
    io:format("read_all 1 ~p~n",[db_cluster:read_all()]), 
%    db_cluster:create_table([node()]),
    db_cluster:create("cluster_1","cookie_1",["c100","c200"],[{created,date(),time()}]),
 %   mnesia:add_table_copy(schema,node(),disc_copies),
 %  {atomic,ok}=mnesia:add_table_copy(schema,node(),disc_copies),
    io:format("mnesia:system_info() ~p~n",[mnesia:system_info()]),
    io:format("read_all 2 ~p~n",[db_cluster:read_all()]), 
    timer:sleep(2000),
    init:stop().


start()->
    
   
    ok=start_node_etcd(),
    io:format("sd:all() ~p~n",[sd:all()]),

    ok=db_host_spec:init_table(),
   "192.168.1.202"=config:host_local_ip("c202"),
    io:format("db_host_spec:read_all() ~p~n",[db_host_spec:read_all()]),

    ok=db_application_spec:init_table(),
    "https://github.com/joq62/nodelog.git"=config:application_gitpath("nodelog.spec"),
    io:format("db_application_spec:read_all() ~p~n",[db_application_spec:read_all()]),

    ok=db_deployment_info:init_table(),
    "calculator"=config:deployment_name("calculator.depl"),
    io:format("db_deployment_info:read_all() ~p~n",[db_deployment_info:read_all()]),

    ok=db_deployments:init_table(),
    "cluster1_cookie"=config:deployment_spec_cookie("cluster1.depl_spec"),
    io:format("db_deployments:read_all() ~p~n",[db_deployments:read_all()]),


   % init:stop(),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
check_application_spec()->
  
    ok.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
check_host_spec()->
    HostName="c202",
    "192.168.1.202"=config:host_local_ip("c202"),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
init_host_spec()->
    ok=db_host_spec:create_table(),
    AllHostNames=config:host_all_hostnames(),
    init_host_spec(AllHostNames).
    
init_host_spec([])->
    ok;
init_host_spec([HostName|T])->
    {atomic,ok}=db_host_spec:create(HostName,
				    config:host_local_ip(HostName),
				    config:host_public_ip(HostName),
				    config:host_ssh_port(HostName),
				    config:host_uid(HostName),
				    config:host_passwd(HostName),
				    config:host_application_config(HostName)
				   ),
    
    init_host_spec(T).


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start_node_etcd()->
    ok=sd:appl_start([]),
    pong=sd:ping(),
    ok=config:appl_start([]),
    pong=config:ping(),
    ok=etcd:appl_start([]),
    pong=etcd:ping(), 
    ok=etcd:dynamic_db_init([]),
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
  %  ok=config:appl_start([]),
  %  pong=config:ping(),  
    % Simulate host
    ok=rpc:call(node(),test_nodes,start_nodes,[]).
%    [Vm1|_]=test_nodes:get_nodes(),

%    Ebin="ebin",
 %   true=rpc:call(Vm1,code,add_path,[Ebin],5000),
  
   
