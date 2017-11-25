class CreateStudentCourseInstructors < ActiveRecord::Migration[5.1]
  def change
    create_table :student_course_instructors do |t|
      t.belongs_to :student_course, foreign_key: true
      t.belongs_to :instructor, foreign_key: true

      t.timestamps
    end
  end
end
