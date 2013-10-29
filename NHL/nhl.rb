#!/usr/bin/ruby

require "nokogiri"
require 'open-uri'

module NHL

	# Configuration items
	# ====================
	# The API key here stored in an environment variable.
	# Get your own API key here: http://www.sportsdatallc.com/
	apiKey    = ENV[ "sportsdata_api_key" ] || "your_API_key"

	# SportsData's trial accounts are limited to one query per second.
	# This throttle variable adorns a sleep operation between queries
	throttle  = 1

	# Standings
	# =========
	# URL structure: http://api.sportsdatallc.org/nhl-[access_level][version]/seasontd/[season]/[nhl_season]/standings.xml?api_key=[your_api_key]
	url = "http://api.sportsdatallc.org/nhl-t3/seasontd/2013/reg/standings.xml?api_key=#{apiKey}"

	xml = Nokogiri::XML( open( url ) )
	xml.remove_namespaces!
	puts "NHL Standings:"
	xml.xpath( "league/season/conference" ).each do | conf |
		puts conf[ "name" ]
		conf.xpath( "division" ).each do | div |
			puts div[ "name" ].upcase
			div.xpath( "team" ).each do | team |
				puts team[ "name" ].ljust(12) + " "+ team[ "games_played" ].rjust(2)+ " "+ team[ "wins" ].rjust(2)+ " "+ team[ "losses" ].rjust(2)+ " "+ team[ "overtime_losses" ].rjust(2)+ " "+ team[ "points" ].rjust(3)+" " + team[ "win_pct" ].ljust(5,"0").rjust(6)
			end
			puts
		end
	end

	# Playing nice with the SportsData service
	sleep throttle

	# Today's games
	# =============
	# URL structure: http://api.sportsdatallc.org/nhl-[access_level][version]/games/[year]/[month]/[day]/schedule.xml?api_key=[your_api_key]

	todayStr= Time.now.strftime( "%Y/%m/%d" )
	puts "Schedule for #{ todayStr }:"

	url = "http://api.sportsdatallc.org/nhl-t3/games/#{ todayStr }/schedule.xml?api_key=#{ apiKey }"
	xml = Nokogiri::XML( open( url ) )
	xml.remove_namespaces!

	xml.xpath( "//game" ).each do | game |
		visitor = game.xpath( "away" )[ 0 ].attr( 'alias' )
		home    = game.xpath( "home" )[ 0 ].attr( 'alias' )
		notice  = ( game.attr( "status" ) == "inprogress" ? " (on now) " : "" )
		puts "#{ visitor.ljust(3) } at #{ home.ljust(3) } #{ notice }"
	end
	puts
end
