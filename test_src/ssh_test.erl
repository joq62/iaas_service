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

-define(VM1,'node1@asus').
%% --------------------------------------------------------------------
-export([start/0]).

%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:emulate loader
%% Description: requires pod+container module
%% Returns: non
%% --------------------------------------------------------------------
start()->
    ?debugMsg("read_conf"),
    read_conf(),
    ?debugMsg("read2"),
    read2(),
    ?debugMsg("start ssh"),
    start_ssh(),
    ?debugMsg("ssh1"),
 %   ssh1(),

    ?debugMsg("status node"),
 %   node1(),
    ?debugMsg("load start"),
    load_start(),
  %  all(),
 %   error(),
 %   event(),    
    ok.



 
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
node1()->
    %% start node
     io:format("~p~n",[{?MODULE,?LINE,rpc:call('10250@sthlm_1',init,stop,[])}]),
    {ConfigInfo,_Error}=node_lib:read_conf_all("test_src/node_config"),    
    Info=conf_info(ConfigInfo,"sthlm_1",[]),
    {ip_addr,Ip}=lists:keyfind(ip_addr,1,Info),
    {ssh_port,Port}=lists:keyfind(ssh_port,1,Info),
    {ssh_user,User}=lists:keyfind(ssh_user,1,Info),
    {ssh_passwd,PassWd}=lists:keyfind(ssh_passwd,1,Info),
    
    io:format("~p~n",[{?MODULE,?LINE,my_ssh:ssh_send(Ip,Port,User,PassWd,"pwd ",10000)}]),

    io:format("~p~n",[{?MODULE,?LINE,my_ssh:ssh_send(Ip,Port,User,PassWd,"erl -sname 10250 -setcookie abc -detached ",5000)}]),
    timer:sleep(5000),
    ?assertMatch(pong,net_adm:ping('10250@sthlm_1')),
    %% Node started 
    ?assertMatch({unknown,_},node_lib:check_status("sthlm_1","test_src/node_config",10000)),    
    ?debugMsg("ok node_config"),
    ?assertMatch({unknown,ehostunreach},node_lib:check_status("sthlm_1","test_src/wrong_ip",10000)),    
    ?debugMsg("ok wrong_ip"),
    ?assertMatch({unknown,econnrefused},node_lib:check_status("sthlm_1","test_src/wrong_port",10000)),  
    ?debugMsg("ok wrong_port"),
    ?assertMatch({unknown,"Unable to connect using the available authentication methods"},node_lib:check_status("sthlm_1","test_src/wrong_user",10000)),  
    ?debugMsg("ok wrong_user"),    
    ?assertMatch({unknown,"Unable to connect using the available authentication methods"},node_lib:check_status("sthlm_1","test_src/wrong_passwd",10000)),    
    ?debugMsg("ok wrong_passwd"),
    %%
    {ok, ChannelPid, _Connection} = ssh_sftp:start_channel("192.168.0.100",60122, [{user,"pi"},{password,"festum01"}]),
    ssh_sftp:del_dir(ChannelPid,"glurk"),
    ?assertMatch(ok,ssh_sftp:make_dir(ChannelPid,"glurk")),
    ?assertMatch({ok,[".",".."]},ssh_sftp:list_dir(ChannelPid,"glurk")),
    ?assertMatch(ok,ssh_sftp:del_dir(ChannelPid,"glurk")),
    ?assertMatch({error,no_such_file},ssh_sftp:list_dir(ChannelPid,"glurk")),
    ?assertMatch(ok,ssh_sftp:stop_channel(ChannelPid)),
    rpc:call('10250@sthlm_1',init,stop,[]),
    ok.

load_start()->
    {ConfigInfo,_Error}=node_lib:read_conf_all("test_src/node_config"),    
    Info=conf_info(ConfigInfo,"sthlm_1",[]),
    {ip_addr,Ip}=lists:keyfind(ip_addr,1,Info),
    {ssh_port,Port}=lists:keyfind(ssh_port,1,Info),
    {ssh_user,User}=lists:keyfind(ssh_user,1,Info),
    {ssh_passwd,PassWd}=lists:keyfind(ssh_passwd,1,Info),
    {host,Host}=lists:keyfind(host,1,Info),
    {vm_id,VmId}=lists:keyfind(vm_id,1,Info),

    ServiceId="adder_service",
    Vm=list_to_atom(VmId++"@"++Host),
    rpc:call(Vm,init,stop,[]),

    %%% Assum computer is running
    {ok, ChannelPid, _Connection} = ssh_sftp:start_channel(Ip,Port, [{user,User},{password,PassWd}]),

%    io:format("~p~n",[{?MODULE,?LINE,ssh_sftp:del_dir(ChannelPid,VmId)}]),
 %   io:format("~p~n",[{?MODULE,?LINE,ssh_sftp:del_dir(ChannelPid,"erl_crasch.dump")}]),
    io:format("~p~n",[{?MODULE,?LINE,my_ssh:ssh_send(Ip,Port,User,PassWd,"rm -rf "++VmId++" erl_crasch.dump include "++ServiceId,5000)}]),
 %   timer:sleep(200),
    ?debugMsg("rm -rf "++VmId++" erl_crasch.dump"),
    
 %   ?assertMatch(ok,ssh_sftp:make_dir(ChannelPid,VmId)),
  %  ?assertMatch({ok,[".",".."]},ssh_sftp:list_dir(ChannelPid,VmId)),
    ?debugMsg("list_dir(ChannelPid,VmId"),
  %  
  %  timer:sleep(200),
    ?assertMatch(["/home/pi"],my_ssh:ssh_send(Ip,Port,User,PassWd,"pwd",5000)),


    io:format("~p~n",[{?MODULE,?LINE,my_ssh:ssh_send(Ip,Port,User,PassWd,"pwd ",5000)}]),
  % ?assertMatch(ok,my_ssh:close(ConRef)),
 %  io:format("~p~n",[{?MODULE,?LINE,my_ssh:ssh_send(Ip,Port,User,PassWd,"git clone https://joq62:20Qazxsw20@github.com/joq62/include.git "++VmId,10000)}]),
 
    io:format("~p~n",[{?MODULE,?LINE,my_ssh:ssh_send(Ip,Port,User,PassWd,"mkdir "++VmId,5000)}]),
    io:format("~p~n",[{?MODULE,?LINE,my_ssh:ssh_send(Ip,Port,User,PassWd,"mkdir "++VmId++"/"++ServiceId,5000)}]),


    io:format("~p~n",[{?MODULE,?LINE,my_ssh:ssh_send(Ip,Port,User,PassWd,"git clone https://joq62:20Qazxsw20@github.com/joq62/"++ServiceId++".git",5000)}]),
  %  timer:sleep(1000),
 %   io:format("~p~n",[{?MODULE,?LINE,my_ssh:ssh_send(Ip,Port,User,PassWd,"mv "++ServiceId++" "++" "++VmId++"/"++ServiceId,5000)}]),
    io:format("~p~n",[{?MODULE,?LINE,my_ssh:ssh_send(Ip,Port,User,PassWd,"cp -r "++ServiceId++"/*"++" "++VmId++"/"++ServiceId,5000)}]),
  %  timer:sleep(200),
    io:format("~p~n",[{?MODULE,?LINE,my_ssh:ssh_send(Ip,Port,User,PassWd,"rm -rf "++ServiceId,5000)}]),
   % timer:sleep(200),
    
    ?debugMsg("clone ServiceId"),

   io:format("~p~n",[{?MODULE,?LINE,my_ssh:ssh_send(Ip,Port,User,PassWd,"git clone https://joq62:20Qazxsw20@github.com/joq62/include.git",5000)}]),
 %   io:format("~p~n",[{?MODULE,?LINE,my_ssh:ssh_send(Ip,Port,User,PassWd,"git clone https://github.com/joq62/include.git",5000)}]),
  %  timer:sleep(1000),
    io:format("~p~n",[{?MODULE,?LINE,my_ssh:ssh_send(Ip,Port,User,PassWd,"mv include "++VmId,5000)}]),
  %  timer:sleep(200),
    ?debugMsg("clone include"),
  %  io:format("~p~n",[{?MODULE,?LINE,my_ssh:ssh_send(Ip,Port,User,PassWd,"ls "++VmId,10000)}]),
  %  ?debugMsg("ls "),
   % timer:sleep(200),
    io:format("~p~n",[{?MODULE,?LINE,my_ssh:ssh_send(Ip,Port,User,PassWd,"cp "++VmId++"/"++ServiceId++"/src/"++ServiceId++".app "++VmId++"/"++ServiceId++"/ebin",5000)}]),
  %  timer:sleep(200),
    io:format("~p~n",[{?MODULE,?LINE,my_ssh:ssh_send(Ip,Port,User,PassWd, "erlc -o "++VmId++"/"++ServiceId++"/ebin "++VmId++"/"++ServiceId++"/src/*.erl",5000)}]),
  %  timer:sleep(200),
%     io:format("~p~n",[{?MODULE,?LINE,my_ssh:ssh_send(Ip,Port,User,PassWd,"cd "++VmId,5000)}]),
%    io:format("~p~n",[{?MODULE,?LINE,my_ssh:ssh_send(Ip,Port,User,PassWd,"erl -pa */ebin "++"-sname "++VmId++" -setcookie abc -detached ",5000)}]),  
    io:format("~p~n",[{?MODULE,?LINE,my_ssh:ssh_send(Ip,Port,User,PassWd,"erl -pa "++VmId++"/"++ServiceId++"/ebin "++"-sname "++VmId++" -setcookie abc -detached ",5000)}]),
    timer:sleep(5000),
    ?assertMatch(pong,net_adm:ping(Vm)),
    ?assertMatch(ok,rpc:call(Vm,application,start,[list_to_atom(ServiceId)])),
    ?assertMatch(42,rpc:call(Vm,adder_service,add,[20,22])),
    ?assertMatch(ok,rpc:call(Vm,application,stop,[adder_service])),
 %   ?assertMatch(ok,ssh_sftp:stop_channel(ChannelPid)),  
    rpc:call(Vm,init,stop,[]),
    ok.
    


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------

start_ssh()->
       my_ssh:start().

ssh1()->
    {ConfigInfo,_Error}=node_lib:read_conf_all("test_src/node_config"),    
    Info=conf_info(ConfigInfo,"sthlm_1",[]),
    {ip_addr,Ip}=lists:keyfind(ip_addr,1,Info),
    ?assertMatch("192.168.0.110",Ip),
    {ssh_port,Port}=lists:keyfind(ssh_port,1,Info),
    ?assertMatch(60110,Port),
    {ssh_user,User}=lists:keyfind(ssh_user,1,Info),
    ?assertMatch("pi",User),
    {ssh_passwd,PassWd}=lists:keyfind(ssh_passwd,1,Info),
    ?assertMatch("festum01",PassWd),
    ?assertMatch(["/home/pi"],my_ssh:ssh_send(Ip,Port,User,PassWd,"pwd ",10000)),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
read_conf()->
    {ConfigInfo,Error}=node_lib:read_conf_all("test_src/node_config"),
 
    ?assertMatch([[{kind,node},{api_version,"1.0.0"},{ip_addr,"192.168.0.100"},{ssh_port,60122},
		   {ssh_user,"pi"},{ssh_passwd,"festum01"},{vm_id,"10250"},{host,"asus"},{capability,[]}],
		  [{kind,node},{api_version,"1.0.0"},{ip_addr,"192.168.0.110"},{ssh_port,60110},
		   {ssh_user,"pi"},{ssh_passwd,"festum01"},{vm_id,"10250"},{host,"sthlm_1"},{capability,[{tellsticvk,[]}]}]],ConfigInfo),
    
    ?assertMatch(["test_src/node_config/error.config",{error,{_,erl_parse,["syntax error before: ","'.'"]}}],Error),
    ok.
    
read2()->
    {ConfigInfo,_Error}=node_lib:read_conf_all("test_src/node_config"),
    H1=[lists:keyfind(host,1,L)||L<-ConfigInfo],
    Hosts=[HostId||{host,HostId}<-H1],
    ?assertMatch(["asus","sthlm_1"],Hosts),    

    % ssh_info
     ?assertMatch([],conf_info(ConfigInfo,"glurk",[])),
    ?assertMatch([{kind,node},{api_version,"1.0.0"},{ip_addr,"192.168.0.100"},{ssh_port,60122},
		   {ssh_user,"pi"},{ssh_passwd,"festum01"},{vm_id,"10250"},{host,"asus"},{capability,[]}],conf_info(ConfigInfo,"asus",[])),
    
    ok.


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



