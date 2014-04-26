require 'koala'
require 'open-uri'
require 'json'
access_token = 'CAACEdEose0cBAIORN55K6PlprgK4NDsZAAS9s2I82zyVpMURlbVcFAnYulYgpZBSkubETk0NEC5Ir4xWt0EtXycbPqOUnrVZAxff88r57KfVh1iVUtSMhIZAqJ1rmUclZA37Qdr6ZC3rD9Y5iheZBizGGzuZATqn9rguDqTZBREy91YRJIL7iXtUfzdU2wsIOYoPoSO49KnurMwZDZD'

if ARGV.size != 1 then
  fail 'missing friend of interest'
end
friend = ARGV[0]
graph = Koala::Facebook::API.new(access_token)
user  = graph.get_object("me")
messages = graph.get_connections(user["id"], "outbox")
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
count = 0
msg_dates = []
while target and target["paging"] do
  entries = target["data"]
  entries.each do |entry|
    msg_dates.push entry["created_time"]
  end
  next_link = target["paging"]["next"]
  target = JSON.load(open(next_link))
  puts '--------------'
end
puts msg_dates

