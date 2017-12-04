class CreateEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :events do |t|
      t.string :title
      t.boolean :due_date, default: false
      t.boolean :assignment_to_do, default: false
      t.datetime :start_date
      t.datetime :end_date
      t.string :color

      t.timestamps
    end
  end
end
