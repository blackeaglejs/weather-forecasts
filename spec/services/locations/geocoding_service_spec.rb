require "rails_helper"

RSpec.describe Locations::GeocodingService, type: :service do
  context "when a location is created with a postal code that already exists in the database with lat/lng coordinates" do
    let!(:new_location) { build(:location) }
    let(:existing_location) { create(:location, postal_code: new_location.postal_code, latitude: 40.7128, longitude: -74.0060) }
      it "should assign the existing lat/lng coordinates to the new location" do
        new_location.postal_code = existing_location.postal_code
        service = Locations::GeocodingService.new(new_location)
        result = service.call

        expect(result.latitude).to eq(existing_location.latitude)
        expect(result.longitude).to eq(existing_location.longitude)
      end
    end
  end

  context "when a location does not exist in the database" do
    let!(:new_location) { create(:location) }
    context "when the first geocoding API call returns results" do
      it "should assign the resulting lat/lng coordinates to the location" do
        stub_request(:get, /nominatim.openstreetmap.org/).to_return(status: 200, body: [ { "lat": "40.7127281", "lon": "-74.0060152" } ].to_json)
        service = Locations::GeocodingService.new(new_location)
        service.call

        expect(new_location.latitude).to eq(40.7127281)
        expect(new_location.longitude).to eq(-74.0060152)
      end
    end

    context "when the geocoding API call does not return results" do
      context "when we have a postal code" do
        it "should retry the geocoding API call with just the postal code" do
          stub_request(:get, /nominatim.openstreetmap.org/)
            .to_return(
              { status: 200, body: [].to_json }, # this covers the first instance with the full address
              { status: 200, body: [ { "lat": "40.7127281", "lon": "-74.0060152" } ].to_json } # this handles the second round with just the zip code
            )
          service = Locations::GeocodingService.new(new_location)

          expect(service).to receive(:geocode_location_with_postal_code).and_call_original
          service.call
        end
      end

      context "when we don't have a postal code" do
        let!(:new_location) { create(:location, postal_code: nil) }
        it "should raise a standard error indicating that we were unable to geocode the location" do
          stub_request(:get, /nominatim.openstreetmap.org/).to_return(status: 200, body: [].to_json)
          service = Locations::GeocodingService.new(new_location)

          expect { service.call }.to raise_error(StandardError, "Unable to geocode location with the provided information")
        end
      end
    end
  end
