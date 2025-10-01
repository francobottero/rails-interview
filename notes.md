# NOTES.txt

## Design Decisions

### Implement Synchronization Logic

- **Two-way Sync:** The synchronization mechanism supports two-way data flow:
  - New/updated TodoLists and TodoItems from the external API are created/updated locally.
  - Local changes (create, update, delete) are propagated to the external API.
- **Change Detection:** Each TodoList and TodoItem has a `synced_at` timestamp and a `deleted_at` field (soft delete). Changes are detected via updated timestamps and deletion markers.

  ```ruby
  # Example: Detecting unsynced changes
  unsynced_items = TodoItem.where('updated_at > synced_at OR synced_at IS NULL')
  ```

- **Conflict Resolution:** The latest change wins, determined by comparing `updated_at` timestamps. If both local and remote have changes, the newer one overwrites the older. If it was neccesary, we could also define a heirarchy here (local has greater importance than remote, or otherwise).

  ```ruby
  # Example: Conflict resolution
  if local.updated_at > remote.updated_at
    push_to_remote(local)
  else
    update_local(remote)
  end
  ```

- **Batching:** Where possible, changes are batched to minimize API calls. For example, where the handshake fails between local and remote API, or when the remote API is not possible to reach (due to failures or shutdown). We could keep a list of those todo list items that were not updated, and send them all together to reduce overhead and API calls.

  ```ruby
  # Example: Batch push
  ExternalApi.bulk_update(todo_items)
  ```

### Resilience and Reliability

- **Partial Failures:** If a sync operation fails for a specific item, it is logged and retried up to 3 times with exponential backoff.

  ```ruby
  # Example: Retry with exponential backoff
  3.times do |attempt|
    begin
      sync_item(item)
      break
    rescue => e
      sleep(2 ** attempt)
      log_error(e)
      # As mentioned above, we could add a "state" that controls whether it was synced | failed
    end
  end
  ```

- **Atomicity:** Sync operations are performed in transactions to avoid partial updates.

  ```ruby
  # Example: Transactional sync
  ActiveRecord::Base.transaction do
    update_local_items(remote_items)
    mark_synced
  end
  ```

### Optimize Performance

- **Minimize API Calls:** 
  - Only fetch items changed since the last sync (`updated_since` parameter).
  - Only push local changes that have not been synced.
  - Use bulk endpoints if available.

  ```ruby
  # Example: Fetch changed items from external API
  response = ExternalApi.get('/todo_items', params: { updated_since: last_synced_at })
  ```

- **Caching:** External API responses are cached during a sync session to avoid redundant fetches.

  ```ruby
  # Example: Simple in-memory cache
  @cache ||= {}
  @cache[key] ||= ExternalApi.get(key)
  ```

### Error Handling and Logging

- **Error Messages:** All API errors are logged with context (endpoint, payload, error code/message).

  ```ruby
  # Example: Logging errors
  logger.error("Sync failed: endpoint=#{endpoint}, error=#{error.message}")
  ```

- **Logging:** Detailed logs are written for each sync operation, including success/failure, retries, and data diffs.

  ```ruby
  # Example: Logging sync diffs
  logger.info("Sync diff: local=#{local_item.attributes}, remote=#{remote_item.attributes}")
  ```

### Notes

For starters, we could highten the accuracy of error handling and logging by adding an external application to our stack (such as DataDog) to keep track of syncs that failed, this way getting a larger sense of why or where.

For future improvements, I would add the opportunity of manual sync by the press of a button and the option to choose between local or remote state (given that those two have a conflict).

--> Finally, for Damian, the foreign_key essentially enforces referential integrity at a database level. I remember being so mad about this because I was in the right track. Now, after a lil bit of reading, I can tell you that having it on false makes it rely on application-level validations (validates :..., presence: true).
