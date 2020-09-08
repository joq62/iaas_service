%%% -------------------------------------------------------------------
%%% @author  : Joq Erlang
%%% @doc: : 
%%%  
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(node_lib). 
 
-define(TIMEOUT,5000).

-export([read_conf_all/1,
	 check_status_all/1,
	 check_status/3,
	 start_node/2
	]).


%% ====================================================================
%% External functions
%% ====================================================================
start_node(HostId,ConfigDir)->
    {ConfigInfo,_Error}=node_lib:read_conf_all(ConfigDir),    
    Result = case conf_info(ConfigInfo,HostId,[]) of
		 []->
		     {error,eexists,HostId};
		 Config->
		     start_node(Config)
	     end,
    Result.
start_node(Config)->
    {ip_addr,Ip}=lists:keyfind(ip_addr,1,Config),
    {ssh_port,Port}=lists:keyfind(ssh_port,1,Config),
    {ssh_user,User}=lists:keyfind(ssh_user,1,Config),
    {ssh_passwd,PassWd}=lists:keyfind(ssh_passwd,1,Config),
    {vm_id,VmId}=lists:keyfind(vm_id,1,Config),
    {host,HostId}=lists:keyfind(host,1,Config),

    Vm=list_to_atom(VmId++"@"++HostId),
    Result = case net_adm:ping(Vm) of
		 pong->
		     {error,[already_started,HostId]};
		 pang ->
		 %    io:format("~p~n",[{?MODULE,?LINE,my_ssh:ssh_send(Ip,Port,User,PassWd,"rm -rf "++VmId++" erl_crasch.dump include ",5000)}]),
		 %    io:format("~p~n",[{?MODULE,?LINE,my_ssh:ssh_send(Ip,Port,User,PassWd,"mkdir "++VmId,5000)}]),
		  %   io:format("~p~n",[{?MODULE,?LINE,my_ssh:ssh_send(Ip,Port,User,PassWd,"erl -pa "++VmId++"/*"++"/ebin "++"-sname "++VmId++" -setcookie abc -detached ",5000)}]),
		     ok=my_ssh:ssh_send(Ip,Port,User,PassWd,"rm -rf "++VmId++" erl_crasch.dump include ",500),
		     ok=my_ssh:ssh_send(Ip,Port,User,PassWd,"mkdir "++VmId,500),
		     ok=my_ssh:ssh_send(Ip,Port,User,PassWd,"erl -pa "++VmId++"/*"++"/ebin "++"-sname "++VmId++" -setcookie abc -detached ",5000),
		     check_started(500,Vm,100,{error,[Vm]});
		 Err ->
		     {error,[Err,HostId]}
	     end,
    Result.

check_started(_N,_Vm,_Timer,ok)->
    ok;
check_started(0,_Vm,_Timer,Result)->
    Result;
check_started(N,Vm,Timer,_Result)->
    NewResult=case net_adm:ping(Vm) of
		  pong->
		      ok;
		  Err->
		      timer:sleep(Timer),
		      {error,[Err,Vm]}
	      end,
    check_started(N-1,Vm,Timer,NewResult).

%@doc, spec etc
%% --------------------------------------------------------------------
%% Function: 
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%
%% --------------------------------------------------------------------
check_status_all(ConfigDir)->
    {ConfigInfo,_Error}=node_lib:read_conf_all(ConfigDir),
    StatusAll=check_status_all(ConfigInfo,?TIMEOUT,[]),
    StatusAll.
 
check_status_all([],_,StatusAll)->
    StatusAll;
check_status_all([Config|T],TimeOut,Acc)->
    {host,HostId}=lists:keyfind(host,1,Config),
    Status=check_node(Config,TimeOut),
    check_status_all(T,TimeOut,[{HostId,Status}|Acc]).
	


check_status(HostId,ConfigDir,TimeOut)->
    {ConfigInfo,_Error}=node_lib:read_conf_all(ConfigDir),    
    Status = case conf_info(ConfigInfo,HostId,[]) of
		 []->
		     {error,eexists,HostId};
		 Config->
		     check_node(Config,TimeOut)
	     end,
    Status.

check_node(Info,TimeOut)->
    {ip_addr,Ip}=lists:keyfind(ip_addr,1,Info),
    {ssh_port,Port}=lists:keyfind(ssh_port,1,Info),
    {ssh_user,User}=lists:keyfind(ssh_user,1,Info),
    {ssh_passwd,PassWd}=lists:keyfind(ssh_passwd,1,Info),
    {vm_id,VmId}=lists:keyfind(vm_id,1,Info),
    {host,HostId}=lists:keyfind(host,1,Info),
    Status=case my_ssh:ssh_connect(Ip,Port,User,PassWd,TimeOut) of
	       {ok,ConRef,_ChanId}->
		   Vm=list_to_atom(VmId++"@"++HostId),
		   case rpc:call(Vm,vm_service,ping,[]) of
		       {pong,Vm,vm_service}->
			   my_ssh:close(ConRef),
			   {running,[]};
		       {badrpc,nodedown}->
			   my_ssh:close(ConRef),
			   {nodedown,[]};
		       {badrpc,{'EXIT',{undef,Err}}}->
			   my_ssh:close(ConRef),
			   {unknown,{'EXIT',{undef,Err}}};
		       Err ->
			   {unknown,Err}
		   end;
	       {error,ehostunreach} ->
		   {unknown,ehostunreach};
	       {error,econnrefused} ->
		   {unknown,econnrefused};
	       {error,Err}->
		   {unknown,Err};
	       Error ->
		   {unknown,Error}
	   end,
    Status.


conf_info([],_HostId,Config)->
    Config;

conf_info([Config|T],HostId,Acc)->
    case {host,HostId}==lists:keyfind(host,1,Config) of
	true->
	    NewAcc=Config,
	    NewT=[];
	false->
	    NewAcc=Acc,
	    NewT=T
    end,
    conf_info(NewT,HostId,NewAcc).
%@doc, spec etc
%% --------------------------------------------------------------------
%% Function: 
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%
%% --------------------------------------------------------------------

read_conf_all(Dir)->
    {ok,Files}=file:list_dir(Dir),
    FileNames=[filename:join(Dir,File)||File<-Files,
					".config"==filename:extension(File)],
    {ConfigList,ErrorList}=do_config_list(FileNames,[],[]),
    {ConfigList,ErrorList}.
					

do_config_list([],ConfigList,ErrorList)->
    {ConfigList,ErrorList};
do_config_list([FileName|T],Acc1,Acc2) ->
    {NewAcc1,NewAcc2}=case file:consult(FileName) of
			  {ok,Info}->
			   %   {[Info|Acc1],Acc2};
			      {lists:append(Info,Acc1),Acc2};
			  Err->
			      {Acc1,lists:append([FileName,Err],Acc2)}
		      end,
    do_config_list(T,NewAcc1,NewAcc2).
	    
%% --------------------------------------------------------------------
%% Function: 
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%
%% --------------------------------------------------------------------



%% --------------------------------------------------------------------
%% Function: 
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%
%% --------------------------------------------------------------------
