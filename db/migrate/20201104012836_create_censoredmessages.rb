class CreateCensoredmessages < ActiveRecord::Migration[5.2]
  def change
    create_table :censoredmessages do |t|
      t.references :user, foreign_key: true
      t.references :message, foreign_key: true
      t.text :body
      t.timestamps
    end
  end
end
