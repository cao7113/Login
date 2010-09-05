class AddOtherFields < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :mail
      t.string :icon
      t.integer :state, :default=>100
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :mail, :icon, :state
    end
  end
end
