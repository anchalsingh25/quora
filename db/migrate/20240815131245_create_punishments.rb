class CreatePunishments < ActiveRecord::Migration[7.0]
  def change
    create_table :punishments do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :punishment_type
      t.datetime :restriction_time

      t.timestamps
    end
  end
end
