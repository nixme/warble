class Identity < ActiveRecord::Base
  belongs_to :user

  def self.find_with_omniauth(auth)
    find_by_provider_and_uid auth['provider'].to_s, auth['uid'].to_s
  end
  def self.create_with_omniauth(auth)
    Identity.create(uid: auth['uid'].to_s, provider: auth['provider'].to_s)
  end
end
