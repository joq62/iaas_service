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
    R=rec(<<"na">>),
    X1=binary_to_list(R),
    Reply=string:tokens(X1,"\n"),
    Reply.

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
