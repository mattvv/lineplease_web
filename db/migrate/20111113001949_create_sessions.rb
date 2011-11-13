class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.string :session_id
      t.string :user_id
      t.string :username

      t.timestamps
    end
  end
end
