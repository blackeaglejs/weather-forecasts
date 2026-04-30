json.extract! forecast, :id, :current_temperature, :high, :low, :time, :location_id, :created_at, :updated_at
json.url forecast_url(forecast, format: :json)
