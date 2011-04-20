class FluxxGrantMigrateClientStoresToProgramHierarchy < ActiveRecord::Migration
  def self.up
    ClientStore.all.each do |client_store|
      if client_store.data
        funj = client_store.data.de_json
        cards detail url
          funj['cards'].each do |card|
          end
        end
        client_store.data = funj.to_json
        client_store.save
      end
    end
  end

  def self.down
  end
end
