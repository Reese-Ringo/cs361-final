#!/usr/bin/env ruby

class Track

  def initialize(segments, name=nil)
    @name = name
    segment_objects = []
    segments.each do |segment|
      segment_objects.append(segment)
    end

    @segments = segment_objects
  end

  def get_json()
    json = '{"type": "Feature", '

    if @name != nil
      json += '"properties": {"title": "' + @name + '"},'
    end

    json += '"geometry": {"type": "MultiLineString","coordinates": ['

    @segments.each_with_index do |segment, index|

      if index > 0
        json += ","
      end

      json += '[' + segment.get_json + ']'
    end
    json + ']}}'
  end

end

class TrackSegment

  attr_reader :coordinates

  def initialize(coordinates)
    @coordinates = coordinates
  end

  def get_json()
    json = ''
    coordinates.each do |coordinate|

      if json != ''
        json += ','
      end

      json += '['
      json += "#{coordinate.lon},#{coordinate.lat}"

      if coordinate.ele != nil
        json += ",#{coordinate.ele}"
      end

      json += ']'
    end

    return json

  end

end

class Point

  attr_reader :lat, :lon, :ele

  def initialize(lon, lat, ele=nil)
    @lon = lon
    @lat = lat
    @ele = ele
  end

end

class Waypoint

  attr_reader :lat, :lon, :ele, :name, :type

  def initialize(lon, lat, ele=nil, name=nil, type=nil)
    @lat = lat
    @lon = lon
    @ele = ele
    @name = name
    @type = type
  end

  def get_json(indent=0)
    json = '{"type": "Feature","geometry": {"type": "Point","coordinates": '
    json += "[#{@lon},#{@lat}"

    if ele != nil
      json += ",#{@ele}"
    end

    json += ']},'

    if name != nil or type != nil
      json += '"properties": {'

      if name != nil
        json += '"title": "' + @name + '"'
      end

      if type != nil 

        if name != nil
          json += ','
        end

        json += '"icon": "' + @type + '"' 
      end
      json += '}'
    end
    json += "}"
  end

end

class World

  def initialize(name, things)
    @name = name
    @features = things
  end

  def add_feature(feature)
    @features.append(feature)
  end

  def to_geojson(indent=0)
    gjson = '{"type": "FeatureCollection","features": ['
    @features.each_with_index do |feature, index|

      if index != 0
        gjson +=","
      end

      gjson += feature.get_json

    end
    gjson + "]}"
  end

end

def main()
  waypoint1 = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
  waypoint2 = Waypoint.new(-121.5, 45.6, nil, "store", "dot")

  track_segment1 = TrackSegment.new([
    Point.new(-122, 45),
    Point.new(-122, 46),
    Point.new(-121, 46),
  ])

  track_segment2 = TrackSegment.new([ 
    Point.new(-121, 45), 
    Point.new(-121, 46), 
  ])

  track_segment3 = TrackSegment.new([
    Point.new(-121, 45.5),
    Point.new(-122, 45.5),
  ])

  track1 = Track.new([track_segment1, track_segment2], "track 1")
  track2 = Track.new([track_segment3], "track 2")

  world = World.new("My Data", [waypoint1, waypoint2, track1, track2])

  puts world.to_geojson()
end

if File.identical?(__FILE__, $0)
  main()
end


