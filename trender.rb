require 'koala'   # facebook wrapper
require 'sinatra' # to push onto server for javascript access
require 'open-uri'
require 'json'
access_token = 'CAACEdEose0cBACj4DZCaeZAET1eNXyLCGLHqZCdlxlUA2YF2RjYrFUDepo2fNr0r8rip4OHGZABUjd9IoXZBrszRr6yhwvEH1RugZCkr23XnJK6jZBTUtlLwlNzQ6c0zG2YnLJujlVAAS9qZC9oJx7SGRcI4NcuKRhqZAQ34olUAUCk9prFliZAX2XDgkKASOPmvZCfeJZBqiD0nZCgZDZD'
get '/' do
# Retrieves and prints a space-delimited mapping of
# dates => counts of messages on a date
# between me/ and friend.
# dates are in the form yyyymmdd.

if ARGV.size != 1 then
  fail 'missing friend of interest'
end
friend    = ARGV[0]
graph     = Koala::Facebook::API.new(access_token)
user      = graph.get_object("me")
messages  = graph.get_connections(user["id"], "outbox", { :limit => 200})
json_msgs = JSON.parse(JSON.pretty_generate(messages))

# find friend among all friends you've messaged  
times = []
target = ""
json_msgs.each do |msg|
  # these brackets on brackets are walking down the info tree
  # (it's JSON, but same idea as XML)
  if msg["to"]["data"][1] and msg["to"]["data"][1]["name"].include? friend then
    target = msg["comments"] # Facebook only will have one message set
    break                    # per friend per output page
  end
end

# at this point, we never need to find friend again :D
# we just follow the next links to the next set of
# messages by friend.
pages_deep = 0 # for debug
msg_dates = [] 
msg_dates = Hash.new
while target and target["paging"] do
#  puts pages_deep.to_s + " pages deep" # debug
#  pages_deep = pages_deep.next         # debug
  entries = target["data"]
  entries.each do |entry|
    time = entry["created_time"] # get timestamp
    date_key = ""
    time.split("-").each { |item| date_key += item.split("T")[0] } # to form yyyymmdd
    unless msg_dates.has_key? date_key then msg_dates[date_key] = 0 end
    msg_dates[date_key] = msg_dates[date_key].next
  end
  next_link = target["paging"]["next"]
  target = JSON.load(open(next_link))
end
# not sure if the below prints sorted by date
msg_dates.each { |date, count| puts "#{date} #{count}" }
end
