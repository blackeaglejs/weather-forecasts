class AddUnitsToForecasts < ActiveRecord::Migration[8.1]
  def change
    add_column :forecasts, :units, :string
  end
end
