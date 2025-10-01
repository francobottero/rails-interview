require 'rails_helper'

describe Api::TodoItemsController do
  render_views

  let!(:todo_list) { TodoList.create(name: "Play hockey on ice") }
  let!(:todo_item) { todo_list.todo_items.create(name: "Dont forget the ice hockey stick", checked: false) }

  describe 'GET index' do
    it 'returns all todo items in JSON' do
      get :index, params: { todo_list_id: todo_list.id }, format: :json

      expect(response.status).to eq(200)

      items = JSON.parse(response.body)
      expect(items.count).to eq(1)
      expect(items[0].keys).to match_array(['id', 'name', 'checked', 'todo_list_id'])
    end

    it 'raises error when not using json' do
      expect {
        get :index, params: { todo_list_id: todo_list.id }
      }.to raise_error(ActionController::RoutingError, 'Not supported format')
    end
  end

  describe 'GET show' do
    it 'returns a specific todo item in JSON' do
      get :show, params: { todo_list_id: todo_list.id, id: todo_item.id }, format: :json

      expect(response.status).to eq(200)

      item = JSON.parse(response.body)
      aggregate_failures do
        expect(item['id']).to eq(todo_item.id)
        expect(item['name']).to eq(todo_item.name)
        expect(item['checked']).to eq(todo_item.checked)
      end
    end
  end

  describe 'POST create' do
    it 'creates a new todo item' do
      expect {
        post :create, params: { todo_list_id: todo_list.id, todo_item: { name: "Dont forget roller skates", checked: false } }, format: :json
      }.to change { todo_list.todo_items.count }.by(1)

      expect(response.status).to eq(200)
      item = JSON.parse(response.body)
      expect(item['name']).to eq("Dont forget roller skates")
      expect(item['checked']).to eq(false)
    end
  end

  describe 'PATCH update' do
    it 'updates the todo item' do
      patch :update, params: { todo_list_id: todo_list.id, id: todo_item.id, todo_item: { checked: true } }, format: :json

      expect(response.status).to eq(200)
      expect(todo_item.reload.checked).to eq(true)
    end
  end

  describe 'DELETE destroy' do
    it 'deletes the todo item' do
      expect {
        delete :destroy, params: { todo_list_id: todo_list.id, id: todo_item.id }, format: :json
      }.to change { todo_list.todo_items.count }.by(-1)

      expect(response.status).to eq(204)
      expect(TodoItem.count).to eq(0)
    end
  end
end