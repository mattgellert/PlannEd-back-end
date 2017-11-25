class CreateStudentAssignments < ActiveRecord::Migration[5.1]
  def change
    create_table :student_assignments do |t|
      t.belongs_to :assignment, foreign_key: true
      t.belongs_to :student_course, foreign_key: true
      t.boolean :completed, default: false

      t.timestamps
    end
  end
end
