require 'koala'
require 'open-uri'
require 'json'
access_token = 'CAACEdEose0cBAJZCylvBU9cKQnWdZAcPHkvqnZB4z3SxU4OhTnbF8NX4clwIhyOZCadyjN5AfeHqUTiIdP240vMCZBvKmAtJievBXY6MDcu8CK3b7fZBoKvkIZAsroVlfjfk5xYWSmfcJzax2xyfQbr0qfIoROfNX3oppyHodbHGeVbZAAZCZBGy4KuDNHhNw0lZBxM5DgfLMySPAZDZD'

if ARGV.size != 1 then
  fail 'missing friend of interest'
end
friend = ARGV[0]
graph = Koala::Facebook::API.new(access_token)
user  = graph.get_object("me")
messages = graph.get_connections(user["id"], "outbox", { :limit => 2000})
json_msgs = JSON.parse(JSON.pretty_generate(messages))
#puts JSON.pretty_generate(messages)
#exit # this is enough to print out queryable json

# find friend among all friends you've messaged  
times = []
target = ""
json_msgs.each do |msg|
  if msg["to"]["data"][1] and msg["to"]["data"][1]["name"].include? friend then
    target = msg["comments"]
    break
  end
end
# at this point, we never need to find friend again :D
pages_deep = 0
msg_dates = []
msg_dates = Hash.new
while target and target["paging"] do
  #puts pages_deep.to_s + " pages deep"
  #pages_deep = pages_deep.next
  entries = target["data"]
  entries.each do |entry|
    time = entry["created_time"]
    date_key = ""
    time.split("-").each { |item| date_key += item.split("T")[0] }
    unless msg_dates.has_key? date_key then msg_dates[date_key] = 0 end
    msg_dates[date_key] = msg_dates[date_key].next
  end
  next_link = target["paging"]["next"]
  target = JSON.load(open(next_link))
end
data = []
msg_dates.each { |date, count| puts "#{date} #{count}" }
#puts msg_dates #Hash[msg_dates.to_a().reverse()]
