class CreateStudentAssignmentEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :student_assignment_events do |t|
      t.belongs_to :event, foreign_key: true
      t.belongs_to :student_assignment, foreign_key: true

      t.timestamps
    end
  end
end
