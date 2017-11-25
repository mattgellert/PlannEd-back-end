class CreateAssignments < ActiveRecord::Migration[5.1]
  def change
    create_table :assignments do |t|
      t.belongs_to :course, foreign_key: true
      t.string :title
      t.text :description
      t.datetime :due_date
      t.boolean :completed, default: false #remove
      t.references :primary_assignment, index: true

      t.timestamps
    end
  end
end
