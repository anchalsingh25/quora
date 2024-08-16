class CreateReports < ActiveRecord::Migration[7.0]
  def change
    create_table :reports do |t|
      t.references :reportable, polymorphic: true, null: false
      t.references :reportee, null: false, foreign_key: { to_table: :users }
      t.references :reporter, null: false, foreign_key: { to_table: :users }
      t.integer :category
      t.text :reason
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
