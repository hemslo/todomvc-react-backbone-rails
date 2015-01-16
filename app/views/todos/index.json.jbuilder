json.array!(@todos) do |todo|
  json.extract! todo, :id, :title, :completed, :created_at, :updated_at
end
