class CreateStudCourseCompEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :stud_course_comp_events do |t|
      t.belongs_to :event, foreign_key: true
      t.belongs_to :student_course_component, foreign_key: true

      t.timestamps
    end
  end
end
