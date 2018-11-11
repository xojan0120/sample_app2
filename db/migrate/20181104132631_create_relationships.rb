class CreateRelationships < ActiveRecord::Migration[5.1]
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end

    # よく検索に使われる項目はインデックスを張ることで検索効率をよくする
    add_index :relationships, :follower_id
    add_index :relationships, :followed_id

    # add_indexの第二引数を配列にすると、複合インデックスが張れる
    add_index :relationships, [:follower_id, :followed_id], unique: true
  end
end
