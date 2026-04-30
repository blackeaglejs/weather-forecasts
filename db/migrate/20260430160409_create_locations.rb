class CreateLocations < ActiveRecord::Migration[8.1]
  def change
    create_table :locations do |t|
      t.string :address_one
      t.string :address_two
      t.string :city
      t.string :province
      t.string :postal_code
      t.string :country

      t.timestamps
    end
  end
end
