# frozen_string_literal: true

module Locations
  # this class serves as an orchestration layer for creating a location and it's associated forecasts.
  class CreateWithForecastService < ApplicationService
    attr_accessor :location_params, :location, :forecast

    def initialize(location_params)
      @location_params = location_params
      @location = nil
      @forecast = nil
    end

    # the path here is
    # 1. create the location record (or find it if it already exists)
    # 2. try and fetch a forecast from the cache based on the postal code.
    # 3. geocode if we need to retrieve coordinates to pull the forecast.
    # 4. pull the forecast based on the coordinates we have.
    # 5. return the location and the forecast, regardless of whether we were able to pull it.
    def call
      create_location
      fetch_forecast_from_cache
      geocode_location if @forecast.blank? && @location.geocoding_required?
      create_forecast if @forecast.blank? && !@location.geocoding_required? # don't try to pull the forecast if we don't have the coordinates.

      [ @location, @forecast ]
    end

    private

    # this creates (or finds) the location record in the database based on the parameters we have.
    def create_location
      @location = Location.find_or_create_by(location_params)
    end

    # this call tries to pull a forecast from the cache based on the postal code.
    # if we find it, we generate a new one associated with the location we just created.
    # if we don't find it, we return without trying to create it.
    def fetch_forecast_from_cache
      return if @location.postal_code.blank?
      cached_forecast = Forecasts::FetchByZipService.new(@location.postal_code).call
      return if cached_forecast.blank?

      @forecast = cached_forecast.dup
      @forecast.location = @location
      @forecast.save!
    end

    def geocode_location
      service = Locations::GeocodingService.new(@location)
      service.call
      @location = service.location
    end

    def create_forecast
      @forecast = Forecasts::CreateService.new(@location).call
    end
  end
end
