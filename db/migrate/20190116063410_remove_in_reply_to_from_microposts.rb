class RemoveInReplyToFromMicroposts < ActiveRecord::Migration[5.1]
  def change
    remove_column :microposts, :in_reply_to, :string
  end
end
