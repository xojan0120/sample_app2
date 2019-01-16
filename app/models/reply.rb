class Reply < ApplicationRecord
  belongs_to :micropost

  validates :reply_to, presence: true
end
