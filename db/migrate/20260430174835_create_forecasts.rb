class CreateForecasts < ActiveRecord::Migration[8.1]
  def change
    create_table :forecasts do |t|
      t.decimal :current_temperature
      t.decimal :high
      t.decimal :low
      t.datetime :time
      t.references :location, null: false, foreign_key: true

      t.timestamps
    end
  end
end
