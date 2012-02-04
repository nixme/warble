class Play < ActiveRecord::Base
  belongs_to :user
  belongs_to :song

  def increment_skips
    self.class.increment_counter(:skips, id)
  end
end