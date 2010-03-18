!!! 收文 1.0
%收文 start
  -办公室主任会签  fork1
%张三审批(actor-id=zs)  任务节点？ 类似于~assignment 即~tasktype这种
  -张三审批结束 join1
%钱五审批（actor-id=qw)
  -钱五审批结束 join1
%fork1 fork
  -张三审批 张三审批
  -钱五审批 钱五审批
%join1 join
  -会签完成 收文结束
%收文结束 end