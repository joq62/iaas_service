%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(node_tests).  
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
%% --------------------------------------------------------------------

%% External exports
-export([start/0]).



%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
start()->
    ?debugMsg("Test system setup"),
    ?assertEqual(ok,setup()),

    %% Start application tests

 %   ?debugMsg("monitor test "),
 %   ?assertEqual(ok,monitor_test:start()),    
    
    ?debugMsg("ssh test "),
    ?assertEqual(ok,ssh_test:start()),
    
 %   ?debugMsg("node test "),
 %   ?assertEqual(ok,node_test:start(2)),


%    ?debugMsg("Start stop_test_system:start"),
    %% End application tests
    cleanup(),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
setup()->
   ssh:start(),
   % rpc:call('node1@asus',application,stop,[sd_service]),
   io:format("~p~n",[{?MODULE,?LINE,rpc:call('mnesia@asus',mnesia,start,[])}]),
    %timer:sleep(200),	
    
  % ?assertEqual({pong,node1@asus,sd_service},rpc:call('node1@asus',sd_service,ping,[])),
  %  ?assertEqual(ok,application:start(sd_service)),

    ok.

cleanup()->
    ssh:stop(),
   % application:stop(sd_service),
    rpc:call('mnesia@asus',init,stop,[]),
    init:stop().




