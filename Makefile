all:
	rm -rf  *~ */*~ src/*.beam test/*.beam erl_cra*;
	rm -rf  logs *.pod_dir rebar.lock;
	rm -rf config sd;
	rm -rf *@*;
	rm -rf deployments *_info_specs;
	rm -rf _build test_ebin ebin *_info_specs;
	mkdir ebin;		
	rebar3 compile;	
	cp _build/default/lib/*/ebin/* ebin;
	rm -rf _build test_ebin logs log;
	git add -f *;
	git commit -m $(m);
	git push;
	echo Ok there you go!
eunit:
	rm -rf  *~ */*~ src/*.beam test/*.beam test_ebin erl_cra*;
	rm -rf *@*;
	rm -rf _build logs log *.pod_dir;
	rm -rf deployments *_info_specs;
	rm -rf config sd;
	rm -rf rebar.lock;
	rm -rf ebin;
	mkdir  application_info_specs;
	cp ../../../specifications/application_info_specs/*.spec application_info_specs;
	mkdir  host_info_specs;
	cp ../../../specifications/host_info_specs/*.host host_info_specs;
	mkdir deployment_info_specs;
	cp ../../../specifications/deployment_info_specs/*.depl deployment_info_specs;
	mkdir deployments;
	cp ../../../specifications/deployments/*.depl_spec deployments;
	mkdir test_ebin;
	mkdir ebin;
	rebar3 compile;
	cp _build/default/lib/*/ebin/* ebin;
	git clone https://github.com/joq62/config.git;
	erlc -o test_ebin test/*.erl;
	erl -pa host_info_specs -pa */ebin -pa ebin -pa test_ebin -sname dbase_test -run basic_eunit $(s) -setcookie cookie_test
