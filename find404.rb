require 'uri'
require 'net/http'
require 'csv'
require 'parallel'

rows = CSV.read('urls.csv', :headers => true)
output = CSV.open('urls_output.csv', 'wb')
output << ['url', 'code']

urls = []
rows.each do |r|
 urls << {'url' => r['url']}
end

processed = 0
total_duration = 0
Parallel.each(urls, :in_threads => 16) do |u|
#rows.each do |u|
  start = Time.now
  url = u['url']

  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Head.new(uri.request_uri)
  response = http.request(request)

  output << [url, response.code]
  processed += 1
  duration = (Time.now - start)
  total_duration += duration
  avg = total_duration/processed
  ettf = ((rows.count - processed) * avg) / 60
  puts "#{url}, #{response.code}, ETTF: #{ettf} min"
  output.flush
end

