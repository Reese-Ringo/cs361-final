#!/usr/bin/env ruby

class Track

  def initialize(segments, name=nil)
    @name = name
    segment_objects = []
    segments.each do |segment|
      segment_objects.append(segment)
    end
    # set segments to segment_objects
    @segments = segment_objects
  end

  def get_track_json()
    json = '{"type": "Feature", '
    if @name != nil
      json += '"properties": {"title": "' + @name + '"},'
    end
    json += '"geometry": {"type": "MultiLineString","coordinates": ['
    # Loop through all the segment objects
    @segments.each_with_index do |segment, index|
      if index > 0
        json += ","
      end
      json += '['
      # Loop through all the coordinates in the segment
      tsj = ''
      segment.coordinates.each do |c|
        if tsj != ''
          tsj += ','
        end
        # Add the coordinate
        tsj += '['
        tsj += "#{c.lon},#{c.lat}"
        if c.ele != nil
          tsj += ",#{c.ele}"
        end
        tsj += ']'
      end
      json += tsj
      json += ']'
    end
    json + ']}}'
  end

end

class TrackSegment

  attr_reader :coordinates

  def initialize(coordinates)
    @coordinates = coordinates
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

  def get_waypoint_json(indent=0)
    json = '{"type": "Feature",'
    # if name is not nil or type is not nil
    json += '"geometry": {"type": "Point","coordinates": '
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
      if type != nil  # if type is not nil
        if name != nil
          json += ','
        end
        json += '"icon": "' + @type + '"'  # type is the icon
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
    # Write stuff
    gjson = '{"type": "FeatureCollection","features": ['
    @features.each_with_index do |feature, index|
      if index != 0
        gjson +=","
      end

      if feature.class == Track
          gjson += feature.get_track_json
      elsif feature.class == Waypoint
          gjson += feature.get_waypoint_json
      end
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


