%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(ssh_test).  
     
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
-include("log.hrl").

%% --------------------------------------------------------------------
-export([start/0]).
-define(Mnesia,'mnesia@asus').
%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:emulate loader
%% Description: requires pod+container module
%% Returns: non
%% --------------------------------------------------------------------
start()->
    ?debugMsg("init"),
    ok=init(),
    ?debugMsg("start_node"),
    io:format("~p~n",[{?MODULE,?LINE,time()}]),
    ok=start_node("sthlm_1","glurk"),
    ?debugMsg("start_service"),
    io:format("~p~n",[{?MODULE,?LINE,time()}]),
    ok=start_service("sthlm_1","glurk","adder_service"),
    42=rpc:call('glurk@sthlm_1',adder_service,add,[20,22]),
    
    ?debugMsg("stop_node"),
    io:format("~p~n",[{?MODULE,?LINE,time()}]),
    ok=stop_node("sthlm_1","glurk"),
    pang=net_adm:ping('glurk@sthlm_1'),
    io:format("~p~n",[{?MODULE,?LINE,time()}]),
  %  ?debugMsg("start ssh"),
  %  start_ssh(),
  %  ?debugMsg("ssh1"),
  %  ssh1(),

  %  ?debugMsg("status node"),
  %  node1(),
  %  ?debugMsg("load start"),
   % load_start(),
 
    ok.



 
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
init()->
    %% start node
    [{_HostId,User,PassWd,Ip,Port}]=rpc:call(?Mnesia,db_computer,read,["sthlm_1"]),
    ?assertEqual(60110,Port),
    ?assertEqual(["/home/pi"],my_ssh:ssh_send(Ip,Port,User,PassWd,"pwd ",10000)),
    ok.
   


start_node(ComputerId,VmId)->
   % net_adm:ping(Vm)
    rpc:call(list_to_atom(VmId++"@"++ComputerId),init,stop,[]),
    timer:sleep(1000),
        
    Result = case rpc:call(?Mnesia,db_computer,read,[ComputerId]) of
		 []->
		     {error,[eexist,ComputerId]};
		 [{ComputerId,User,PassWd,Ip,Port}]->
		     Vm=list_to_atom(VmId++"@"++ComputerId),
		     case net_adm:ping(Vm) of
			 pong->
			     {error,[already_started,ComputerId]};
			 pang ->
			     ok=my_ssh:ssh_send(Ip,Port,User,PassWd,"rm -rf "++VmId++" erl_crasch.dump include ",3000),
			     ok=my_ssh:ssh_send(Ip,Port,User,PassWd,"mkdir "++VmId,3000),
			     ok=my_ssh:ssh_send(Ip,Port,User,PassWd,"erl -pa "++VmId++"/*"++"/ebin "++"-sname "++VmId++" -setcookie abc -detached ",5000),
			     node_lib:check_started(500,Vm,100,{error,[Vm]});
			 Err ->
			     {error,[Err,ComputerId]}
		     end
	     end,
    ?assertEqual(ok,Result),
    
    ok.
		
	   
stop_node(ComputerId,VmId)->
    Result = case rpc:call(?Mnesia,db_computer,read,[ComputerId]) of
		 []->
		     {error,[eexist,ComputerId]};
		 [{ComputerId,User,PassWd,Ip,Port}]->
		     Vm=list_to_atom(VmId++"@"++ComputerId),
		     rpc:call(Vm,init,stop,[]),
		     ok=my_ssh:ssh_send(Ip,Port,User,PassWd,"rm -rf "++VmId++" erl_crasch.dump include ",3000),
		     node_lib:check_stopped(500,Vm,100,{error,[Vm]});
		 Err ->
		     {error,[Err,ComputerId]}
	     end,
	?assertEqual(ok,Result),
    ok.

start_service(ComputerId,VmId,ServiceId)->
    Result = case rpc:call(?Mnesia,db_computer,read,[ComputerId]) of
		 []->
		     {error,[eexist,ComputerId]};
		 [{ComputerId,User,PassWd,Ip,Port}]->
		     Vm=list_to_atom(VmId++"@"++ComputerId),
		     case rpc:call(?Mnesia,db_service_def,read,[ServiceId]) of
			 []->
			     {error,[eexists,ServiceId]};
			 [{ServiceId,_Vsn,Source}]->
			     case net_adm:ping(Vm) of
				 pang->
				     {error,[no_contact,Vm]};
				 pong ->
				     case rpc:call(Vm,filelib,is_dir,[VmId]) of
					 false->
					     {error,['eexist dir ',VmId]};
					 {badrpc,Err} ->
					     {badrpc,Err};
					 true ->
					     my_ssh:ssh_send(Ip,Port,User,PassWd,"mkdir "++VmId++"/"++ServiceId,5000),
					     my_ssh:ssh_send(Ip,Port,User,PassWd,"git clone "++ Source++" "++ServiceId++".git",5000),
					     my_ssh:ssh_send(Ip,Port,User,PassWd,"git clone  https://joq62:20Qazxsw20@github.com/joq62/"++ServiceId++".git",5000),
									     
					     my_ssh:ssh_send(Ip,Port,User,PassWd,"cp -r "++ServiceId++"/*"++" "++VmId++"/"++ServiceId,5000),
					 %    my_ssh:ssh_send(Ip,Port,User,PassWd,"rm -rf "++ServiceId,5000),

					     my_ssh:ssh_send(Ip,Port,User,PassWd,"git clone https://joq62:20Qazxsw20@github.com/joq62/include.git",5000),
					     my_ssh:ssh_send(Ip,Port,User,PassWd,"mv include "++VmId,5000),
					     
					     my_ssh:ssh_send(Ip,Port,User,PassWd,"cp "++VmId++"/"++ServiceId++"/src/"++ServiceId++".app "++VmId++"/"++ServiceId++"/ebin",5000),
					     my_ssh:ssh_send(Ip,Port,User,PassWd, "erlc -o "++VmId++"/"++ServiceId++"/ebin "++VmId++"/"++ServiceId++"/src/*.erl",5000),
					     
					     true=rpc:call(Vm,code,add_path,["./"++VmId++"/"++ServiceId++"/ebin"]),
					     
					   %  my_ssh:ssh_send(Ip,Port,User,PassWd,"erl -pa "++VmId++"/"++ServiceId++"/ebin "++"-sname "++VmId++" -setcookie abc -detached ",5000),
					     
					     timer:sleep(1000),
					     rpc:call(Vm,application,start,[list_to_atom(ServiceId)])
				     end
			     end
		     end
	     end,
    Result.
					     
					     
				     
