%%% -------------------------------------------------------------------
%%% @author  : Joq Erlang
%%% @doc: : 
%%%  
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(node). 


-export([ping/0,start_node/3,stop_node/1,
	 active/0,passive/0,all/0,
	 log/0
	]).


%% ====================================================================
%% External functions
%% ====================================================================

%@doc, spec etc

ping()-> 
    rpc:call(node(),node_service,ping,[]).


start_node(IpAddr,Port,VmId)->
    rpc:call(node(),node_service,start_node,[IpAddr,Port,VmId]).
    

stop_node(Vm)->
    rpc:call(node(),node_service,stop_node,[Vm]).

active()->
    rpc:call(node(),node_service,active,[]).
passive()->
    rpc:call(node(),node_service,passive,[]).
all()->
    rpc:call(node(),node_service,all,[]).
log()->
    rpc:call(node(),node_service,log,[]).
 
