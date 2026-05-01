# frozen_string_literal: true

module Forecasts
  class CreateService < ApplicationService
    BASE_URL = "https://api.open-meteo.com/v1/forecast".freeze

    attr_accessor :location

    def initialize(location)
      @location = location
    end

    # this call fetches the forecast data
    # then we parse the response to extract the relevant forecast attributes
    # then we create a new forecast record associated with the location
    # we finish by writing to the cache with the postal code as the key and the database ID as the value
    def call
      fetch_forecast_data
      parse_forecast_response
      create_forecast
      write_to_cache

      @forecast
    end

    private

    # we pull the data from here
    def fetch_forecast_data
      @raw_response = HTTParty.get(forecast_api_url, headers: {"Accept" => "application/json"})
    end

    # we generate a parsed response with the relevant attributes for our forecast model
    def parse_forecast_response
      {
       current_temperature: @raw_response.dig("current_weather", "temperature"),
       high: @raw_response.dig("daily", "temperature_2m_max", 0),
       low: @raw_response.dig("daily", "temperature_2m_min", 0),
       units: temperature_units
      }
    end

    def temperature_units
      response_unit = @raw_response.dig("current_weather", "temperature_unit")

      if response_unit == "F"
        "fahrenheit"
      elsif response_unit == "C"
        "celsius"
      else
        nil
      end
    end

    def create_forecast
      @forecast = @location.forecasts.create(parse_forecast_response)
    end

    def write_to_cache
        Rails.cache.write("#{@location.postal_code}", @forecast.id, expires_in: 30.minutes)
    end

    # this API url uses the lat/lng to get current temperature, daily high, and daily low for this location.
    def forecast_api_url
      "#{BASE_URL}?latitude=#{@location.latitude.to_s}&longitude=#{@location.longitude.to_s}&daily=temperature_2m_max,temperature_2m_min&current=temperature_2m&wind_speed_unit=mph&temperature_unit=fahrenheit"
    end
  end
end