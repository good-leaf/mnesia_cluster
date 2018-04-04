# mnesia_cluster #

项目代码来源于https://github.com/erlio/mnesia_cluster.git

This project contains the Mnesia layer found in RabbitMQ, adapted to be used in an application agnostic way within other OTP Applications or Releases.

## Configuration ##

### table_definition_mod ###
Defines the MFA that returns your Mnesia Table Definitions. The Definitions must have the following format:
```
[
{my_table,
  [
    {record_name, my_table_item},
    {attributes, record_info(fields, my_table_item)},
    {disc_copies, [node()]},
    {match, #my_table_item{_='_'}}
  ]
},
{my_other_table,
  [...]
}
...
].
```
The match property specifies a MatchHead similar to the one used in ETS and Mnesia MatchSpecs which is used for DB consistency checks during node startup.

### app_process ###
Specifies a name of a Process that should run on every cluster node. Your app can specify callbacks that get the Nodename where this process starts, dies, or recovers. See the next section `cluster_monitor_callbacks`.

### cluster_monitor_callbacks ###
Specifies a list of modules that are called in case the Process specified in `app_process` dies and recovers. The modules have to implement and export the `on_node_up/1`, and `on_node_down/1` functions. The Nodename is the single argument provided to the callbacks.

### cluster_nodes ###
Enables the auto configuration of a cluster during node startup
```
{TryNodes, NodeType}
```
TryNodes defines the Nodes that are subsequently tried during clustering. As soon as a node is reachable this process stops. NodeType can either be `ram` or `disc`and specifies if this node connects as a mnesia ram or disc node.

### cluster_partition_handling ###
Specifies how the node should react in case of a cluster partition. Three options exist:
- `ignore`: is obvious, we don't care.
- `pause_minority`: if the node belongs to the minor partition it stops the `mnesia_cluster` and `mnesia` applications. Once the partition is resolved the applications are automatically restarted. 
- `autoheal`: an elected leader takes over control

### 注意 ###
- `pause_minority模式：` 集群数最少3台，节点存活比例>0.5集群可用。当=<0.5时，最后一个节点停止mnesia，每隔1秒检测集群其他节点恢复情况，直到节点存活比例>0.5启动mnesia。
- `集群节点全部停止：` 在mnesia目录下查看nodes_running_at_shutdown文件，确定最后一个停止的节点，touch force_load文件，强制启动。

### 存在问题 ###
- `节点状态文件写入异常：` could_not_write_file "..../mnesia/cluster_nodes.config"
- `数据表载入等待超时：` timeout_waiting_for_tables

## Copyright ##

Copyright (c) 2014 Erlio GmbH  All rights reserved. 

The initial Developer of the Original Code is GoPivotal, Inc.
