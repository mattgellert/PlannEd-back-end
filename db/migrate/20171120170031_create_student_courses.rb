class CreateStudentCourses < ActiveRecord::Migration[5.1]
  def change
    create_table :student_courses do |t|
      t.belongs_to :course, foreign_key: true
      t.belongs_to :student, foreign_key: true
      t.boolean :completed, default: false
      t.string :section
      t.string :time_start
      t.string :time_end
      t.string :pattern
      t.string :facility_descr
      t.string :facility_descr_short
      t.string :color

      t.timestamps
    end
  end
end
