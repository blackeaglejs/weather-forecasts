require "rails_helper"

RSpec.describe Forecast, type: :model do
  describe "it should belong to a location" do
    context "when a forecast is created with a location" do
      let(:forecast) { create(:forecast) }

      it "should be valid" do
        expect(forecast).to be_valid
      end
    end

    context "when a forecast is created without a location" do
      let(:forecast) { build(:forecast, location: nil) }

      it "should not be valid" do
        expect(forecast).not_to be_valid
      end
    end
  end
end
