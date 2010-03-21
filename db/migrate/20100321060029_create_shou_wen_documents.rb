class CreateShouWenDocuments < ActiveRecord::Migration
  def self.up
    create_table :shou_wen_documents do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :shou_wen_documents
  end
end
