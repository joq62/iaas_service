%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(node_test).  
     
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
-include("log.hrl").
-include("node.hrl").
%% --------------------------------------------------------------------
-export([start/1]).

%% ====================================================================
%% External functions
%% ====================================================================

% Use cases

% Normal
% 1. check status per node
% 2. Per node that has started/re-started create and start vm '10250@host'
% 3. Start a specific node with vm_id=VmId on host=HostId
% 4. Request a worker node Start a worker node "30000" - "30030"
% 

%% --------------------------------------------------------------------
%% Function:emulate loader
%% Description: requires pod+container module
%% Returns: non
%% --------------------------------------------------------------------
start(N)->
    ?debugMsg("status all"),
    status_all(N),
  %  all(),
 %   error(),
 %   event(),    
    ok.




%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
status_all(0)->
    ok;
status_all(N)->
    ?debugMsg("status all"),
    io:format("~p~n",[{?MODULE,?LINE,N}]),
    io:format("~p~n",[{?MODULE,?LINE,rpc:call('10250@sthlm_1',init,stop,[])}]),
    io:format("~p~n",[{?MODULE,?LINE,rpc:call('10250@asus',init,stop,[])}]),
    timer:sleep(1000),
    ?assertMatch([{_,{nodedown,[]}},{_,{nodedown,[]}}],node_lib:check_status_all("test_src/node_config")),
    ?assertMatch(ok,node_lib:start_node("sthlm_1","test_src/node_config")),    

    ?assertMatch( {error,[already_started,"sthlm_1"]},node_lib:start_node("sthlm_1","test_src/node_config")),    
    
    ?assertMatch(pong,net_adm:ping('10250@sthlm_1')),
   
    status_all(N-1).



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------

