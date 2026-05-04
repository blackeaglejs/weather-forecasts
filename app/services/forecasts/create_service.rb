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
      raise StandardError, "Location is missing coordinates" if @location.latitude.blank? || @location.longitude.blank?

      fetch_forecast_data
      raise StandardError, "External forecast retrieval failed with #{@raw_response.code}" unless @raw_response.success?

      parsed = parse_forecast_response
      raise StandardError, "External forecast retrieval did not retrieve temperature" if parsed[:current_temperature].nil? && parsed[:high].nil? && parsed[:low].nil?

      create_forecast(parsed)
      raise StandardError, "Failed to save forecast: #{@forecast.errors.full_messages.join(", ")}" if @forecast.errors.any?

      write_to_cache

      @forecast
    end

    private

    # we pull the data from here
    def fetch_forecast_data
      @raw_response = HTTParty.get(forecast_api_url, headers: { "Accept" => "application/json" })
    rescue SocketError, Net::OpenTimeout, Net::ReadTimeout => e
      raise StandardError, "Forecast API request failed: #{e.message}"
    end

    # we generate a parsed response with the relevant attributes for our forecast model
    def parse_forecast_response
      parsed_response = JSON.parse(@raw_response.body)
      {
       current_temperature: parsed_response.dig("current_weather", "temperature"),
       high: parsed_response.dig("daily", "temperature_2m_max", 0),
       low: parsed_response.dig("daily", "temperature_2m_min", 0),
       units: temperature_units
      }
    end

    def temperature_units
      parsed_response = JSON.parse(@raw_response.body)
      response_unit = parsed_response.dig("current_weather", "temperature_unit")

      if response_unit == "F"
        "fahrenheit"
      elsif response_unit == "C"
        "celsius"
      else
        nil
      end
    end

    def create_forecast(attributes)
      @forecast = @location.forecasts.create(attributes)
    end

    def write_to_cache
        Rails.cache.write("#{@location.postal_code}", @forecast.id, expires_in: 30.minutes)
    end

    # this API url uses the lat/lng to get current temperature, daily high, and daily low for this location.
    def forecast_api_url
      "#{BASE_URL}?latitude=#{@location.latitude}&longitude=#{@location.longitude}&daily=temperature_2m_max,temperature_2m_min&current=temperature_2m&wind_speed_unit=mph&temperature_unit=fahrenheit"
    end
  end
end
