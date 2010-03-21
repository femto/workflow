class CreateRefundRequests < ActiveRecord::Migration
  def self.up
    create_table :refund_requests do |t|
      t.integer :amount
      t.timestamps
    end
  end

  def self.down
    drop_table :refund_requests
  end
end
