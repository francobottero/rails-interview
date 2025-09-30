class CreateTodoItem < ActiveRecord::Migration[7.0]
  def change
    create_table :todo_items do |t|
      t.string :name, null: false
      t.boolean :checked
      t.references :todo_list, foreign_key: true

      t.timestamps
    end
  end
end
