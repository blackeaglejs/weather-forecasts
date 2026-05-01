# frozen_string_literal: true

module Locations
  # this class connects to the OpenStreetMap Nominatim API to geocode a location's address into latitude and longitude coordinates.
  class GeocodingService < ApplicationService
    attr_reader :location

    # we initialize with a Location object, which will already have its fields populated from the controller save.
    def initialize(location)
      @location = location
    end

    # the call method is the public method for this interface - all the business logic is in private emthods. 
    def call
      # pull the coordinates either out of the database or from the geocoding API
      coordinates = find_coordinates_from_zip_code || geocode_location
      binding.irb
      update_location_coordinates(coordinates)

      @location
    end

    private

    # let's try and find the location's approximate coordinates out of the database.
    # the idea here is that zip codes are relatively small, so a weather forecast I'm not expecting huge 
    # variability in the lat/lng, and by extension of that, the weather forecast
    def find_coordinates_from_zip_code
      return nil if @location.postal_code.blank?

      existing_location = Location.where(postal_code: @location.postal_code).where.not(latitude: nil, longitude: nil).first
      return nil if existing_location.blank?

      {
        latitude: existing_location.latitude,
        longitude: existing_location.longitude
      }
    end

    # this method makes the geocoding API call.
    # it then parses the response and gets the coordinates
    def geocode_location
      @raw_response = HTTParty.get(lookup_url, headers:)

      parse_geocoding_response(@raw_response)
    end

    # here, we take the raw response from the geocoding API, parse it, and update the location with the lat/lng coordinates
    def update_location_coordinates(coordinates)
      @location.update(coordinates)
    end

    # the response from nominatim is an array of matches, but having specified a limit of 1, we'll either get an empty array or an array with one element 
    # we only care here about the lat/lng in the response - not any of the other parameters - for now, so we'll ignore the rest of the response. 
    def parse_geocoding_response(response)
      return {} if response.empty?

      {
        latitude: response.first["lat"],
        longitude: response.first["lon"]
      }
    end

    # nominatim requires headers to ensure that they're getting light request traffic. 
    # right now it's hardcoded to my email, but in a production app, we'd set this is as an environment variable.
    def headers
      {"User-Agent" => "weather-forecasts/1.0 (zoheb.nensey@gmail.com)", "Accept" => "application/json"}
    end

    # nominatim's search API takes query parameters - the pattern here is that we only include parameters that we have, and not anything else. 
    def lookup_url
      "https://nominatim.openstreetmap.org/search?#{[street, city, state, postal_code, country_code].reject(&:blank?).join("&")}&format=json&limit=1"
    end

    def street
      combined = [@location.address_one, @location.address_two].compact.join(" ").rstrip
      combined.present? ? "street=#{combined}" : ""
    end

    def city
      @location.city.present? ? "city=#{@location.city}" : ""
    end

    def state
      @location.province.present? ? "state=#{@location.province}" : ""
    end

    def postal_code
      @location.postal_code.present? ? "postalcode=#{@location.postal_code}" : ""
    end

    def country_code
      @location.country.present? ? "countrycodes=#{@location.country}" : ""
    end
  end
end