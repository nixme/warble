class CreateJukeboxes < ActiveRecord::Migration
  def change
    create_table :jukeboxes do |t|
      t.string :name
      t.references :play, index: true
      t.integer :volume, default: 50, nullable: false

      t.timestamps
    end
  end
end
