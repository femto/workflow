!simple0 1.0
-RefundRequest
%1refund_request(normal_employee)
  - agree 2level1_manager_approval
%2level1_manager_approval(manager1)
  - agree 3level2_manager_approval
  - reject 1refund_request
%{amount>10000}3level2_manager_approval(manager2)