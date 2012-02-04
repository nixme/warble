class DropPlaysUniqueIndex < ActiveRecord::Migration
  def up
    remove_index :plays, [:song_id, :user_id]
  end

  def down
    add_index :plays, [:song_id, :user_id], unique: true
  end
end
