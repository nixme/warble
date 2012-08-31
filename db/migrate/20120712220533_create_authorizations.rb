class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.string :provider
      t.string :uid
      t.references :user

      t.timestamps
    end
    add_index :authorizations, :user_id

    User.all.find_each do |user|
      if user.facebook_id
        user.authorizations.create({provider: 'facebook', uid: user.facebook_id})
      end
    end

    remove_column :users, :facebook_id

  end
end
