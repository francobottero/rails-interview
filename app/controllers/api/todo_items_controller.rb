module Api
  class TodoItemsController < ApiController
    # GET /api/todolists/{todo_list_id}/todoitems
    before_action :set_todo_list
    before_action :set_todo_item, except: [:index, :create]

    def index
      @todo_items = @todo_list.todo_items

      respond_to :json
    end

    def update    
      @todo_item.update(todo_item_params)

      respond_to :json
    end

    def create
      @new_todo_item = @todo_list.todo_items.create(todo_item_params)

      respond_to :json
    end

    def destroy
      @todo_item.destroy

      head :no_content
    end

    def show
      respond_to :json
    end

    private

    def set_todo_list
      @todo_list = TodoList.find_by(id: params[:todo_list_id])
    end

    def set_todo_item
      @todo_item = TodoItem.find_by(id: params[:id])
    end

    def todo_item_params
      params.require(:todo_item).permit(:name, :checked).compact_blank
    end
  end
end
