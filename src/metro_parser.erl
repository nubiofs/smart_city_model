-module(metro_parser).
-include_lib("xmerl/include/xmerl.hrl").

% usage:
%
% l(osm_parser).
% osm_parser:show("map.osm").

-export([
         show/2
        ]).

% Init the XML processing
show(Infilename , Print) ->
    {Doc, _Misc} = xmerl_scan:file(Infilename),
    Graph = digraph:new(),
    init( Doc , Graph ),
    case Print of 
		true -> print_graph( Graph );
		_ -> ok
    end,
    Graph.

% read the OSM tag and extract all children
init( Node, Graph ) ->
    case Node of
        #xmlElement{name=Name, content=Content} ->
            
	    case Name of
		
		metro -> 

			nodes_links(Content , Graph);
			
		_ -> ok

	    end;
            _ -> ok
    end.

nodes_links([] , _Graph) ->
    ok;

nodes_links([Node | MoreNodes], Graph) ->
    extract_nodes( Node , Graph ),
    nodes_links(MoreNodes , Graph).

%
% Show a node/element and then the children of that node.
extract_nodes(Node , Graph ) ->

    case Node of
        #xmlElement{name=Name, content=Content} ->
            
	    case Name of
		
		stations -> 
			
			get_nodes(Content , Graph );

		links ->

			get_links(Content , Graph );		

		_ ->
			ok
	    end;

            _ -> ok
    end.

get_nodes([] , _Graph ) ->
    ok;

get_nodes([Node | MoreNodes] , Graph ) ->
    extract_node(Node , Graph ),
    get_nodes( MoreNodes , Graph ).


get_links([] , _Graph ) ->
    ok;

get_links([ Link | MoreLinks ] , Graph ) ->
    extract_link(Link , Graph ),
    get_links( MoreLinks , Graph ).

% Show a node/element and then the children of that node.
extract_node(Node , Graph ) ->

    case Node of
        #xmlElement{name=Name, attributes=Attributes} ->
            
	    case Name of
		
		station -> 
			
			Id = children( Attributes , idNode ),	
			digraph:add_vertex(Graph, list_to_atom(Id));	

		_ ->
			ok
	    end;

            _ -> ok
    end.

extract_link(Link , Graph ) ->

    case Link of
        #xmlElement{name=Name, attributes=Attributes} ->
            
	    case Name of
		
		link -> 
			
			%Id = children( Attributes , idLink ),	
			From = children( Attributes , idOrigin ),
			To = children( Attributes , idDestination ),
			digraph:add_edge(Graph, list_to_atom(From), list_to_atom(To)),
			digraph:add_edge(Graph, list_to_atom(To), list_to_atom(From));

		_ ->
			ok
	    end;

            _ -> ok
    end.


children( [] , _Type ) ->
    ok;

children( [Node | MoreNodes] , Type ) ->
    Element = extract_children( Node , Type ),
    case Element of

	ok ->
    		
		children( MoreNodes , Type );

	_ ->
		Element

    end.


extract_children( Node , Type ) ->

    case Node of
        #xmlAttribute{name=Name, value=Value} ->
            
	    case Name of
		
		Type -> 

			Value;

		_ -> ok

	    end;
            _ -> ok
    end.

print_graph( Graph ) ->
	
	Vertices = digraph:vertices( Graph ),
	Edges = digraph:edges( Graph ),
	print_vertices( Vertices  ),
	print_edges( Graph , Edges ).



print_vertices([]) ->
	ok;

print_vertices([Element | MoreElements]) ->
	io:format("vertice: ~s~n", [ Element ]),
	print_vertices(MoreElements).



print_edges(_Graph , []) ->
	ok;

print_edges(Graph, [Element | MoreElements]) ->
	Edge = digraph:edge(Graph, Element),
	io:format("vInicio: ~s~n", [ element( 2 , Edge ) ]),
	io:format("vFim: ~s~n", [ element( 3 , Edge) ]),
	io:format("id: ~s~n", [ element( 4 , Edge) ]),
	print_edges( Graph , MoreElements ).
