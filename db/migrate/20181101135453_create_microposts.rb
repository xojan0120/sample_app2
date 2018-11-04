class CreateMicroposts < ActiveRecord::Migration[5.1]
  def change
    create_table :microposts do |t|
      t.text :content
      t.references :user, foreign_key: true

      t.timestamps
    end

    # ユーザIDと作成時刻に複合インデックスを張る
    # インデックス,複合インデックスについては https://qiita.com/towtow/items/4089dad004b7c25985e3
    add_index :microposts, [:user_id, :created_at]
  end
end
