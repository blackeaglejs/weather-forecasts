json.extract! location, :id, :address_one, :address_two, :city, :province, :created_at, :updated_at
json.url location_url(location, format: :json)
