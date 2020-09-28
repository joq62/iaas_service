%% This is the application resource file (.app file) for the 'base'
%% application.
{application, dbase_service,
[{description, "dbase_service" },
{vsn, "0.0.1" },
{modules, [dbase_service_app,dbase_service_sup,
	   dbase_service]},
{registered,[dbase_service]},
{applications, [kernel,stdlib]},
{mod, {dbase_service_app,[]}},
{start_phases, []}
]}.
