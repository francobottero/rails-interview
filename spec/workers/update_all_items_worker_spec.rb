require 'rails_helper'

RSpec.describe UpdateAllItemsWorker, type: :worker do
  let!(:todo_list) { TodoList.create(name: "Go to play some football") }
  let!(:todo_item) { todo_list.todo_items.create(name: "Dont forget the Nacional jersey", checked: false) }

  before do
    allow(UpdateAllItemsWorker).to receive(:sleep)
  end

  it "marks the item as completed" do
    described_class.new.perform(todo_item.id)
    expect(todo_item.reload.checked).to eq(true)
  end

  it "broadcasts to the Todo List Turbo stream" do
    expect(Turbo::StreamsChannel).to receive(:broadcast_replace_to).with(
      todo_list,
      target: "todo_item_#{todo_item.id}",
      partial: "todo_items/todo_item",
      locals: { todo_item: instance_of(TodoItem) }
    )

    described_class.new.perform(todo_item.id)
  end
end
