class Location < ApplicationRecord
  has_many :forecasts, dependent: :destroy

  def latest_forecast
    forecasts.order(time: :desc).first
  end

  def geocoding_required?
    latitude.blank? || longitude.blank?
  end
end
