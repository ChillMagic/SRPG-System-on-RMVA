#=================================================
# SRPG::MatchMap
#-------------------------------------------------
# Update : 11/02/2015
#=================================================

module SRPG::MatchMap
  # Match Map Data
  def self.matchMap(string, count_p = 1)
    # Basic String
    str = string[/\((.*)\)/m,1]
    return putError('Could not Match Map.') if (str.nil?)
    str = str.strip.delete(" ").delete("\r").squeeze("\n")
    # Set Record Data
    line = 1
    count = 0
    record = 0
    data = Array.new
    # Match
    str.each_char do |c|
      case c
      when "\n"
        line += 1
        next
      when "P"
        data.push(count_p)
        record = count
      else
        data.push(c.to_i)
      end
      count += 1
    end
    # Check
    putError("Error in Match of Map.") if (count % line != 0)
    # Set Map
    map = SRPG::Map.new(count/line,line,data)
    px, py = map.point(record)
    return [map, px, py]
  end
end
