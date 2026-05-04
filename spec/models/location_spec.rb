require "rails_helper"

RSpec.describe Location, type: :model do
  describe "the ggeocoding_required? method" do
    context "the latitude and longitude are not present" do
      let(:location) { create(:location) }

      it "should require geocoding" do
        expect(location.geocoding_required?).to be true
      end
    end

    context "the latitude and longitude are present" do
      let(:location) { create(:location, latitude: 37.7749, longitude: -122.4194) }

      it "should not require geocoding" do
        expect(location.geocoding_required?).to be false
      end
    end
  end
end