%% The contents of this file are subject to the Mozilla Public License
%% Version 1.1 (the "License"); you may not use this file except in
%% compliance with the License. You may obtain a copy of the License
%% at http://www.mozilla.org/MPL/
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and
%% limitations under the License.
%%
%% Copyright (c) 2014 Erlio GmbH, Basel Switzerland. All rights reserved.
%%
-module(mnesia_cluster_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================
start(normal, []) ->
    error_logger:info_msg("prepare update mnesia status files....~n"),
    mnesia_cluster_monitor:prepare_cluster_status_files(),
    %%选取活着节点，获取otp版本、应用版本、以及远程节点，检查与本地节点的版本是否一直，本地节点是否在远程节点列表
    error_logger:info_msg("choose alive remote node, check otp,version,remote node list~n"),
    mnesia_cluster_utils:check_cluster_consistency(),

    {ok, Vsn} = application:get_key(mnesia_cluster, vsn),
    error_logger:info_msg("Starting MnesiaCluster ~s on Erlang ~s~n",
                          [Vsn, erlang:system_info(otp_release)]),
    {ok, SupPid} = mnesia_cluster_sup:start_link(),
    true = register(mnesia_cluster, self()),
    %% this blocks until wait for tables to be replicated

    error_logger:info_msg("local node init....~n"),
    mnesia_cluster_utils:init(),

    error_logger:info_msg("local node init finish....~n"),
    {ok, SupPid}.

stop(_State) ->
    ok = case mnesia_cluster_utils:is_clustered() of
             true  ->
                 % rabbit_amqqueue:on_node_down(node());
                 ok;
             false -> mnesia_cluster_table:clear_ram_only_tables()
         end,
    ok.
