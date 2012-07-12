class RemoveFacebookId < ActiveRecord::Migration
  def up
    remove_column :users, :facebook_id
  end
end
