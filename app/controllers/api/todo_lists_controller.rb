module Api
  class TodoListsController < ApiController
    # GET /api/todolists
    def index
      @todo_lists = TodoList.all

      respond_to :json
    end
  end
end
