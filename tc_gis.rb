require_relative 'gis.rb'
require 'json'
require 'test/unit'

class TestGis < Test::Unit::TestCase

  def test_waypoint_all_parameters
    waypoint = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
    expected = JSON.parse('{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}}')
    result = JSON.parse(waypoint.get_json)
    assert_equal(result, expected)
  end
    
  def test_waypoint_no_elevation_type
    waypoint = Waypoint.new(-121.5, 45.5, nil, "store", nil)
    expected = JSON.parse('{"type": "Feature","properties": {"title": "store"},"geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    result = JSON.parse(waypoint.get_json)
    assert_equal(result, expected)
  end

  def test_waypoint_no_elevation_name
    waypoint = Waypoint.new(-121.5, 45.5, nil, nil, "flag")
    expected = JSON.parse('{"type": "Feature","properties": {"icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    result = JSON.parse(waypoint.get_json)
    assert_equal(result, expected)
  end

  def test_multi_tracks
    track_segment1 = TrackSegment.new([
      Point.new(-122, 45),
      Point.new(-122, 46),
      Point.new(-121, 46),
    ])

    track_segment2 = TrackSegment.new([ 
      Point.new(-121, 45), 
      Point.new(-121, 46), 
    ])

    track = Track.new([track_segment1, track_segment2], "track 1")
    expected = JSON.parse('{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}}')
    result = JSON.parse(track.get_json)
    assert_equal(expected, result)
  end

  def test_single_track
    track_segment3 = TrackSegment.new([
      Point.new(-121, 45.5),
      Point.new(-122, 45.5),
    ])

    track = Track.new([track_segment3], "track 2")
    expected = JSON.parse('{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}')
    result = JSON.parse(track.get_json)
    assert_equal(expected, result)
  end

  def test_world
    waypoint = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
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

    world = World.new("My Data", [waypoint, waypoint2, track1, track2])

    expected = JSON.parse('{"type": "FeatureCollection","features": [{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}},{"type": "Feature","properties": {"title": "store","icon": "dot"},"geometry": {"type": "Point","coordinates": [-121.5,45.6]}},{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}},{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}]}')
    result = JSON.parse(world.to_geojson)
    assert_equal(expected, result)
  end

end
