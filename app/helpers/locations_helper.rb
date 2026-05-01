module LocationsHelper
  def self.country_list
    file = Rails.root.join("lib", "country_list.json")
    file_content = File.read(file)
    data = JSON.parse(file_content)

    data.map{|country| [country["name"], country["alpha-2"]]}
  end
end
