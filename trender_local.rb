require 'koala'   # facebook wrapper
# require 'sinatra' # to push onto server for javascript access
require 'open-uri'
require 'json'
access_token = 'CAACEdEose0cBAIJN3aZB5AYR40JrltANQgW2QHHOEDIug5L4JNkKMHQyoc1snoljXtawaXfCldG2VRZAbj33EeRmGTJrc8Cz4nTI60TTOX5NIVZARfZAZAHTw4nDMqOf7WBr4uhzMyLoWJOphy9UUONvg09nGY6yDIL9l2JDI3pxarCrW6CrIAkvZCyjaRqDg1pt7S4gWpegZDZD'
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
messages  = graph.get_connections(user["id"], "outbox", { :limit => 200})
json_msgs = JSON.parse(JSON.pretty_generate(messages))

# find friend among all friends you've messaged  
times = []
target = nil
while not target do
  puts 1
  json_msgs.each do |msg|
    # these brackets on brackets are walking down the info tree
    # (it's JSON, but same idea as XML)
    if msg["to"]["data"][1] and msg["to"]["data"][1]["name"].include? friend then
      target = msg["comments"] # Facebook only will have one message set
      break                    # per friend per output page
    end
  end
  if not target then json_msgs = JSON.load(open(json_msgs[json_msgs.size-1]["comments"]["paging"]["next"])) end
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
sorted_dates = msg_dates.keys.to_a.sort
sorted_dates.each do |date|
  puts date + ' ' + msg_dates[date].to_s
end



#end