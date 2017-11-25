class CreateCourses < ActiveRecord::Migration[5.1]
  def change
    create_table :courses do |t|
      t.integer :crse_id
      t.string :subject
      t.integer :catalog_nbr
      t.string :title
      t.string :description
      t.integer :units_minimum
      t.integer :units_maximum
      t.string :session_begin_dt
      t.string :session_end_dt

      t.timestamps
    end
  end
end
