class FluxxGrantAddRequestGrantCycle < ActiveRecord::Migration
  def self.up
    change_table :requests do |t|
      t.integer :grant_cycle_id
    end
    group = MultiElementGroup.create :target_class_name => 'Request', :name => 'grant_cycle', :description => 'Grant Cycle'
    MultiElementValue.create :multi_element_group_id => group.id, :value => 'Grant Cycle'
  end

  def self.down
    change_table :requests do |t|
      t.integer :grant_cycle_id
    end
  end
end