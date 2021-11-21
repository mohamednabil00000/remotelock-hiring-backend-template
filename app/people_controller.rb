class PeopleController
  require 'date'

  def initialize(params)
    @params = params
    @final_hash = Hash.new
  end

  def normalize
    dollar_hash = parse_format_file(params[:dollar_format])
    percent_hash = parse_format_file(params[:percent_format], ' % ')
    final_map = dollar_hash.merge!(percent_hash)
    final_arr = []
    final_map.sort.map do |key,value|
      value.each { |v| final_arr << v }
    end
    final_arr
  end

  private

  attr_reader :params, :final_hash

  def parse_format_file(file, splitter = ' $ ')
    dollar_format_lines = file.split("\n")
    first_line = dollar_format_lines[0].split(splitter)
    first_name_idx = first_line.find_index('first_name')
    city_idx = first_line.find_index('city')
    birthday_idx = first_line.find_index('birthdate')

    for i in 1..dollar_format_lines.size - 1 do
      line = dollar_format_lines[i].split(splitter)
      parsed_date = Date.parse(line[birthday_idx]).strftime("%-m/%-d/%-Y")
      parsed_city = get_city(line[city_idx])
      str = line[first_name_idx] + ', ' + parsed_city + 
        ', ' + parsed_date

      if params[:order].to_s == 'first_name'
        if final_hash[line[first_name_idx]].nil?
          final_hash[line[first_name_idx]] = []
        end
        final_hash[line[first_name_idx]] << str
      elsif params[:order].to_s == 'city'
        if final_hash[parsed_city].nil?
          final_hash[parsed_city] = []
        end
        final_hash[parsed_city] << str
      else
        date = Date.strptime(parsed_date, "%m/%d/%Y")
        if final_hash[date].nil?
          final_hash[date] = []
        end
        final_hash[date] << str
      end
    end

    return final_hash
  end

  def get_city(city)
    allowed_cities = {
      "LA" => "Los Angeles",
      "NYC" => "New York City"
    }

    return allowed_cities[city] ? allowed_cities[city] : city
  end
end
