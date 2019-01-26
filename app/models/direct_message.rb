class DirectMessage < ApplicationRecord
  validates :sender_id,        presence: true
  validates :receiver_id,      presence: true
  validates :sender_display,   inclusion: { in: [true, false] }
  validates :receiver_display, inclusion: { in: [true, false] }
end
