class CreateNotifications < ActiveRecord::Migration[7.2]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.references :notified_by, null: false, foreign_key: { to_table: :users }
      t.string :notification_type
      t.boolean :read, default: false

      t.timestamps
    end
  end
end
