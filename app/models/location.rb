class Location < ApplicationRecord
  has_many :forecasts, dependent: :destroy

  def latest_forecast
    forecasts.order(time: :desc).first
  end

  def geocoding_required?
    latitude.blank? || longitude.blank?
  end

  def formatted_location
    [ address_one, address_two, city, province, postal_code, country ].map { |part| part.presence }.compact.join(", ")
  end
end
