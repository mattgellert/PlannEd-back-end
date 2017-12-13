class CreateStudentCourseComponents < ActiveRecord::Migration[5.1]
  def change
    create_table :student_course_components do |t|
      t.belongs_to :student_course, foreign_key: true
      t.string :title
      t.string :component
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
