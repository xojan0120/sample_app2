class DirectMessage < ApplicationRecord

  belongs_to :sender, class_name: 'User', foreign_key: :sender_id
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id

  validates :sender_id,        presence: true
  validates :receiver_id,      presence: true
  validates :sender_display,   inclusion: { in: [true, false] }
  validates :receiver_display, inclusion: { in: [true, false] }

  default_scope -> { order(created_at: :asc) }

  # pair_user_id e.g. [1 , 2]
  def self.get_dm(pair_user_id)
    ransack(sender_id_or_receiver_id: [pair_user_id]).result
  end

  def hide(target)
    # DMの送信者(Userオブジェクト)のIDと、DMの送信者IDが同じだったら
    #   自分が送信したメッセージであるので、送信者の表示をfalse
    # DMの送信者(Userオブジェクト)のIDと、DMの受信者IDが同じだったら
    #   自分が受信したメッセージであるので、受信者の表示をfalse
    case target
    when :sender
      update_attribute(:sender_display,   false)
    when :receiver
      update_attribute(:receiver_display,   false)
    end
  end
end
