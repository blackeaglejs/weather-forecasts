# frozen_string_literal: true

module Forecasts
  # This service attempts to lookup forecasts by the postal code in the cache. If we find it, we return it. Otherwise, we return nil.
  class FetchByZipService < ApplicationService
    attr_accessor :postal_code

    def initialize(postal_code)
      @postal_code = postal_code
    end

    def call
      forecast_id = Rails.cache.read(@postal_code)

      if forecast_id
        @forecast = Forecast.find(forecast_id)
        return @forecast
      end

      nil
    end
  end
end