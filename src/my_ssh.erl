%% @author Paolo Oliveira <paolo@fisica.ufc.br>
%% @copyright 2015-2016 Paolo Oliveira (license MIT)
%% @version 1.0.0
%% @doc
%% A simple, pure erlang implementation of a module for <b>Raspberry Pi's General Purpose
%% Input/Output</b> (GPIO), using the standard Linux kernel interface for user-space, sysfs,
%% available at <b>/sys/class/gpio/</b>.
%% @end
 
-module(my_ssh).
-export([start/0,close/1,ssh_send/6,ssh_connect/5]).
-author('joq erlang').

-define(DELAY,2000).

start()->
    ssh:start().

close(ConRef)->
    ssh:close(ConRef).

ssh_send(Ip,Port,User,Password,Msg,TimeOut)->
    case ssh_connect(Ip,Port,User,Password,TimeOut) of
	{error,Err}->
	    Reply={error,Err};
	{ok,ConRef,ChanId}->
	    Reply=send(ConRef,ChanId,Msg,TimeOut),
	    ssh:close(ConRef)
    end,
    timer:sleep(?DELAY),
    Reply.

ssh_connect(Ip,Port,User,Password,TimeOut)->
    Result=case ssh:connect(Ip,Port,[{user,User},{password,Password}],TimeOut) of
	       {error,Err}->
		   {error,Err};
	       {ok,ConRef}->
		   case ssh_connection:session_channel(ConRef,TimeOut) of
		       {error,Err}->
			   {error,Err};
		       {ok,ChanId}->
			   {ok,ConRef,ChanId}
		   end
	   end,
    Result.


send(ConRef,ChanId,Msg,TimeOut)->
    ssh_connection:exec(ConRef,ChanId,Msg,TimeOut),
%    R=rec(<<"na">>),
 %   Reply=case rec(ConRef,ChanId,TimeOut,no_msg,false) of
    Reply=case rec(ConRef,ChanId,TimeOut) of
	      {closed,R}->
		  %io:format("~p~n",[{?MODULE,?LINE,closed,R}])
		  ok;
	      {eof,R}->
		%io:format("~p~n",[{?MODULE,?LINE,eof,R}]);
		  ok;
	      {exit,R}->
		 % io:format("~p~n",[{?MODULE,?LINE,exit,R}]);
		  ok;
	      {error,Err}->
		  %io:format("~p~n",[{?MODULE,?LINE,error,Err}]);
		  ok;
	      no_msg->
		 % io:format("~p~n",[{?MODULE,?LINE,no_msg}]);
		  ok;
	      {ok,Result}->
		  X1=binary_to_list(Result),
		  string:tokens(X1,"\n")
	  end,
    Reply.
    
rec(ConRef,ChanId,TimeOut)->
    Reply=receive
	      {ssh_cm, ConRef, {data, ChanId, Type, Result}} when Type == 0 ->
		  {ok,Result};
	      {ssh_cm, ConRef, {data, ChanId, Type, Result}} when Type == 1 ->
		  {error,Result}
	  after TimeOut->
		  {error,timeout}
	  end,
    Reply.

    

rec(ConRef,_ChanId,_TimeOut,Result,true)->
    Result;
rec(ConRef,ChanId,TimeOut,Result,false)->
    receive
	{ssh_cm, ConnectionRef, {data, ChannelId, Type, Result}} when Type == 0 ->
	    NewResult={ok,Result},
	    Quit=true;
	{ssh_cm, ConnectionRef, {data, ChannelId, Type, Result}} when Type == 1 ->
	    NewResult={error,Result},
	    Quit=true;
	{ssh_cm,_,{eof,0}}->
	    NewResult={eof,Result},
	    Quit=false; 
	{ssh_cm,_,{exit_status,0,0}}->
	    NewResult={exit,Result},
	    Quit=true;
	{ssh_cm,_,{closed,0}}->
	    NewResult={closed,Result},
	    Quit=true 
	%Err->
	  %  {ssh_cm, ConnectionRef, {data, ChannelId, Type, Result_1}}=Err,
	   % NewResult={ok,Result_1},
	 %   NewResult={error,Err,Result},
	  %  Quit=true
    after TimeOut->
	    NewResult= {error,timeout},
	    Quit=true
    end,
    rec(ConRef,ChanId,TimeOut,NewResult,Quit).



rec(Msg)->
    receive 
	{ssh_cm,_,{data,0,0,BinaryMsg}}->
	    io:format("ssh_cm,_,{data,0,0 ~p~n",[{?MODULE,?LINE}]),
	    rec(BinaryMsg);
        {ssh_cm,_,{eof,0}}->
	    io:format("ssh_cm,_,{eof,0} ~p~n",[{?MODULE,?LINE}]),
	    rec(Msg);
	{ssh_cm,_,{exit_status,0,0}}->
	    io:format("ssh_cm,_,{exit_status,0,0} ~p~n",[{?MODULE,?LINE}]),
	     rec(Msg);
	{ssh_cm,_,{closed,0}}->
	    io:format("ssh_cm,_,{closed,0} ~p~n",[{?MODULE,?LINE}]),
	    Msg;
	{ssh_cm,_,{data,_,_,X}}->
	    io:format("ssh_cm,_,{data,_,_,X} ~p~n",[{?MODULE,?LINE}]),
	    X;
	{ssh_cm,_,Term}->
	    io:format("ssh_cm,_,Term ~p~n",[{?MODULE,?LINE}]),
	    term_to_binary(Term);
	Err ->
	    io:format("ssh_cm,_,Err ~p~n",[{?MODULE,?LINE,Err}]),
	    Err
    end.
