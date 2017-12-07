class CreateEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :events do |t|
      t.string :title
      t.string :description, default: nil
      t.boolean :due_date, default: false
      t.boolean :assignment_to_do, default: false
      t.boolean :course_to_do, default: false
      t.boolean :completed, default: nil
      t.datetime :start_date
      t.datetime :end_date
      t.string :color
      t.integer :student_course_id, defalut: nil
      t.integer :student_assignment_id, default: nil

      t.timestamps
    end
  end
end
