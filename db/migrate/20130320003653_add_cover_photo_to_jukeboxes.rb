class AddCoverPhotoToJukeboxes < ActiveRecord::Migration
  def change
    add_column :jukeboxes, :cover_photo_url, :string
  end
end
