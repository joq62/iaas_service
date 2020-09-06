all:
	rm -rf  logfiles *_service include *~ */*~ */*/*~;
	rm -rf *.beam src/*.beam test_src/*.beam erl_crash.dump */erl_crash.dump */*/erl_crash.dump;
	cp src/*.app ebin;
	erlc -I ../include -o ebin src/*.erl;
doc_gen:
	rm -rf  node_config logfiles doc/*;
	erlc ../doc_gen.erl;
	erl -s doc_gen start -sname doc

test:
	rm -rf  *_service include logfiles app_config node_config latest.log;
	rm -rf *.beam src/*.beam test_src/*.beam ebin/* test_ebin/* erl_crash.dump;
#	include
	git clone https://joq62:20Qazxsw20@github.com/joq62/include.git;
	cp src/*app ebin;
	erlc -I include -o ebin src/*.erl;
	erlc -I include -o test_ebin test_src/*.erl;
	erl -pa ebin -pa -pa test_ebin -s node_tests start -sname node_test -setcookie abc
