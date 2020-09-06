%% This is the application resource file (.app file) for the 'base'
%% application.
{application, node_service,
[{description, "node_service" },
{vsn, "0.0.1" },
{modules, 
	  [node_service_app,node_service_sup,node_service,
		node]},
{registered,[node_service]},
{applications, [kernel,stdlib]},
{mod, {node_service_app,[]}},
{start_phases, []}
]}.
