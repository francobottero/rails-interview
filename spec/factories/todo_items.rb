FactoryBot.define do
  factory :todo_item do
    name { "Sample Task" }
    checked { false }
    association :todo_list
  end
end