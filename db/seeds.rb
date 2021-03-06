# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'open-uri'
require 'pry'

BASE_URL = "http://api.seatgeek.com/2/events"
QUERY = "?geoip=true&per_page=100&range=25mi&page=1&taxonomies.name=concert"

hash = JSON.load(open(BASE_URL+QUERY))

def create_event(event_hash)
  Event.create(seat_geek_id: event_hash["id"], 
    listing_count: event_hash["stats"]["listing_count"], 
    average_price: event_hash["stats"]["average_price"], 
    lowest_price: event_hash["stats"]["lowest_price"], 
    highest_price: event_hash["stats"]["highest_price"], 
    title: event_hash["title"], 
    datetime_local: event_hash["datetime_local"])
end

def create_artist(artist_hash)
  Artist.create(event_count: artist_hash["stats"]["event_count"],
    name: artist_hash["name"],
    seat_geek_id: artist_hash["id"])
end

def create_venue(venue_hash)
  Venue.create(city: venue_hash["city"],
    name: venue_hash["name"],
    extended_address: venue_hash["extended_address"],
    display_location: venue_hash["display_location"],
    state: venue_hash["state"],
    postal_code: venue_hash["postal_code"],
    longitude: venue_hash["location"]["lon"],
    latitude: venue_hash["location"]["lat"],
    address: venue_hash["address"],
    seat_geek_id: venue_hash["id"])
end

def create_genre(name)
  Genre.create(name: name)
end


hash["events"].each do |event_hash|
  new_event = create_event(event_hash)
  new_venue = create_venue(event_hash["venue"]) 
  new_event.venue = new_venue
  new_venue.save
  new_event.save
  event_hash["performers"].each do |artist|
    new_artist = create_artist(artist)
    new_event.artists << new_artist
    # associate events and artists
    if artist["genres"]
      artist["genres"].each do |genre|
        new_artist.genres << create_genre(genre["name"])
        #associate genres and artists
      end
    end
  end
end


