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
      geocode_location
      update_location_coordinates

      @location
    end

    private

    # this method makes the geocoding API call.
    def geocode_location
      @raw_response = HTTParty.get(lookup_url, headers:)
    end

    # here, we take the raw response from the geocoding API, parse it, and update the location with the lat/lng coordinates
    def update_location_coordinates
      @location.update(parse_geocoding_response(@raw_response))
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
      combined = [@location.address_one, @location.address_two].compact.join(" ")
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