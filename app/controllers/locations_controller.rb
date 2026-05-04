class LocationsController < ApplicationController
  before_action :set_location, only: %i[ show edit update destroy ]

  # GET /locations or /locations.json
  def index
    @locations = Location.all
  end

  # GET /locations/1 or /locations/1.json
  def show
  end

  # GET /locations/new
  def new
    @location = Location.new
    @countries = LocationsHelper.country_list
  end

  # GET /locations/1/edit
  def edit
  end

  # POST /locations or /locations.json
  def create
    # the business logic for this controller call sits in a service object. 
    # we can initialize the service object and let it handle the orchestration.
    @location, @forecast = Locations::CreateWithForecastService.new(location_params).call

    respond_to do |format|
      # happy path
      if @location.present? && @forecast.present?
        format.html { redirect_to @location, notice: "Location was successfully created." }
        format.json { render :show, status: :created, location: @location }
      # the location didn't get created or has errors.
      elsif @location.blank? || @location.errors.any?
        @countries = LocationsHelper.country_list
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      elsif @location.present? && @forecast.blank?
        format.html { redirect_to @location, notice: "Location was created, but we were unable to retrieve the forecast." }
        format.json { render json: @forecast.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /locations/1 or /locations/1.json
  def update
    respond_to do |format|
      if @location.update(location_params)
        format.html { redirect_to @location, notice: "Location was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @location }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1 or /locations/1.json
  def destroy
    @location.destroy!

    respond_to do |format|
      format.html { redirect_to locations_path, notice: "Location was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location
      @location = Location.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def location_params
      puts "================================= Raw params: ================================="
      puts params[:location]
      puts "================================================================================"
      params.expect(location: [ :address_one, :address_two, :city, :province, :postal_code, :country ])
    end
end
