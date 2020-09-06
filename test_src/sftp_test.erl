%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(sftp_test).  
     
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
    ssh1(),

    ?debugMsg("status node"),
    node1(),
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
    {ConfigInfo,Error}=node_lib:read_conf_all("test_src/node_config"),    
    Info=conf_info(ConfigInfo,"asus",[]),
    {ip_addr,Ip}=lists:keyfind(ip_addr,1,Info),
    {ssh_port,Port}=lists:keyfind(ssh_port,1,Info),
    {ssh_user,User}=lists:keyfind(ssh_user,1,Info),
    {ssh_passwd,PassWd}=lists:keyfind(ssh_passwd,1,Info),

    % Ok
    {ok,ConRef,ChanId}=my_ssh:ssh_connect(Ip,Port,User,PassWd),
    ?assertMatch(["/home/pi"],my_ssh:ssh_send(ConRef,ChanId,"pwd")), 
    ?assertMatch(ok,my_ssh:close(ConRef)),
   
     % Error 
    ?assertMatch({error,ehostunreach},my_ssh:ssh_connect("192.168.66.66",Port,User,PassWd)), 
    ?assertMatch({error,econnrefused},my_ssh:ssh_connect(Ip,1234,User,PassWd)),
    ?assertMatch({error,"Unable to connect using the available authentication methods"},my_ssh:ssh_connect(Ip,Port,"glurk",PassWd)),  
    ?assertMatch({error,"Unable to connect using the available authentication methods"},my_ssh:ssh_connect(Ip,Port,User,"glurk")),  
    
    % ok
    {ok,ConRef1,ChanId1}=my_ssh:ssh_connect(Ip,Port,User,PassWd),
    ?assertMatch(["/home/pi"],my_ssh:ssh_send(ConRef1,ChanId1,"pwd")),  
    ?assertMatch(ok,my_ssh:close(ConRef1)),

    ok.



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------

start_ssh()->
       my_ssh:start().

ssh1()->
    {ConfigInfo,Error}=node_lib:read_conf_all("test_src/node_config"),    
    Info=conf_info(ConfigInfo,"asus",[]),
    {ip_addr,Ip}=lists:keyfind(ip_addr,1,Info),
    ?assertMatch("192.168.0.100",Ip),
    {ssh_port,Port}=lists:keyfind(ssh_port,1,Info),
    ?assertMatch(60122,Port),
    {ssh_user,User}=lists:keyfind(ssh_user,1,Info),
    ?assertMatch("pi",User),
    {ssh_passwd,PassWd}=lists:keyfind(ssh_passwd,1,Info),
    ?assertMatch("festum01",PassWd),
    {ok,ConRef,ChanId}=my_ssh:ssh_connect(Ip,Port,User,PassWd),
    ?assertMatch(["/home/pi"],my_ssh:ssh_send(ConRef,ChanId,"pwd")),
    ?assertMatch(ok,my_ssh:close(ConRef)),
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
		   {ssh_user,"pi"},{ssh_passwd,"festum01"},{vm_id,"10250"},{host,"computer1"},{capability,[{tellsticvk,[]}]}]],ConfigInfo),
    
    ?assertMatch(["test_src/node_config/error.config",{error,{_,erl_parse,["syntax error before: ","'.'"]}}],Error),
    ok.
    
read2()->
    {ConfigInfo,Error}=node_lib:read_conf_all("test_src/node_config"),
    H1=[lists:keyfind(host,1,L)||L<-ConfigInfo],
    Hosts=[HostId||{host,HostId}<-H1],
    ?assertMatch(["asus","computer1"],Hosts),    

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



