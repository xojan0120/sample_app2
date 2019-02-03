class DirectMessageStat < ApplicationRecord
  belongs_to :direct_message
  belongs_to :user

  def visible
    update_attribute(:display, true)
  end

  def invisible
    update_attribute(:display, false)
  end

end
