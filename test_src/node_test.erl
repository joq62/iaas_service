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
    ?debugMsg("status all"),
    status_all(),
  %  all(),
 %   error(),
 %   event(),    
    ok.




%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
status_all()->
    io:format("~p~n",[{?MODULE,?LINE,rpc:call('10250@sthlm_1',init,stop,[])}]),
    timer:sleep(1000),
    ?assertMatch([{_,{nodedown,[]}},{_,{nodedown,[]}}],node_lib:check_status_all("test_src/node_config")),    
    ?assertMatch(ok,node_lib:start_node("vm_service","sthlm_1","test_src/node_config")),    
    
    ?assertMatch(pong,net_adm:ping('10250@sthlm_1')),
   
    ok.



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------

