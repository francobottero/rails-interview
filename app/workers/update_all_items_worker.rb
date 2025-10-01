class UpdateAllItemsWorker
  include Sidekiq::Worker
  include ActionView::RecordIdentifier

  def perform(todo_item_id)
    item = TodoItem.find(todo_item_id)
    todo_list = item.todo_list
    item.update!(checked: true)

    # This is where we would call the other api
    # We could use a gem like httpx to manage the call to the external API
    # For example:
    # HTTPX.plugin(:concurrent).with(timeout: { connect_timeout: 5, read_timeout: 5 }).build_request(
    #   :put,
    #   "https://api.example.com/todo_lists/{todo_list.id}/todo_items/{item.id}",
    #   body: { checked: true },
    #   headers: { "Content-Type" => "application/json" }
    # )

    sleep 2

    Turbo::StreamsChannel.broadcast_replace_to(
      todo_list,
      target: dom_id(item),
      partial: "todo_items/todo_item",
      locals: { todo_item: item }
    )
  end
end