require 'koala'   # facebook wrapper
# require 'sinatra' # to push onto server for javascript access
require 'open-uri'
require 'json'
access_token = 'CAACEdEose0cBAFUNmWakLYLf5SfB0ZBBQuZCZAuCq3RocvuXSDyuz9xpCa1BKDDwcezycsAnZBMTjjQi7j425QFHpoW4seNopGoCiAo2hqYZCk61slxZBTl3LVS7fEvUWQmt0xGh4xKmZBvvkW1ZCKNRhqUMOjhfPT2Sn6MhDbRGkyamArrZB04bM2dtIY5prldIZD'
# get '/:friend' do
# Retrieves and prints a space-delimited mapping of
# dates => counts of messages on a date
# between me/ and friend.
# dates are in the form yyyymmdd.

if ARGV.size != 1 then
  fail 'missing friend of interest'
end
# friend  = params[:friend] # for using with AJAX
friend    = ARGV[0] # for running locally
graph     = Koala::Facebook::API.new(access_token)
user      = graph.get_object("me")
messages  = graph.get_connections(user["id"], "outbox", { :limit => 2000})

# find friend among all friends you've messaged  
times = []
target = nil
while not target do
  messages.each do |msg|
    # currently names are case-sensitive
    if msg["to"]["data"][0] and msg["to"]["data"][0]["name"].include? friend then
      target = msg["comments"] # Facebook only will have one message set
                               # per friend per output page
    end
  end
  messages = messages.next_page unless target
end

# at this point, we never need to find friend again :D
# we just follow the next links to the next set of
# messages by friend.
# pages_deep = 0 # for debug
msg_dates = [] 
msg_dates = Hash.new
while target and target["paging"] do
    puts pages_deep.to_s + " pages deep" # debug
    pages_deep = pages_deep.next         # debug
  entries = target["data"]
  entries.each do |entry|
    time = entry["created_time"] # get timestamp
    date_key = time.split("T")[0]
    p entry
    unless msg_dates.has_key? date_key then 
      msg_dates[date_key] = 0 
    end
    msg_dates[date_key] = msg_dates[date_key].succ
  end
  next_link = target["paging"]["next"]
  begin
    target = JSON.load(open(next_link)) # we may be able to do /much/ better
    # than this by a FQL query: SELECT id FROM object_url WHERE url = next_link
    # but we'd need a way to get a graph object from an id. I expect there
    # is a way.
  rescue
    retry 
  end
end

# pretty sure the below prints sorted by date
sorted_dates = msg_dates.keys.to_a.sort
sorted_dates.each do |date|
  puts date + ' ' + msg_dates[date].to_s
end
