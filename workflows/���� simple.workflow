!simple0 1.0
-RefundRequest
%1refund_request提出退款申请(normal_employee)
  - 申请 2一级主管审批
%2一级主管审批(manager1)
  - 同意 3二级主管审批
  - 拒绝 1提出退款申请
%{amount>10000}3二级主管审批(manager2)