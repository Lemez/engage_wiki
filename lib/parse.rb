def parse(url = nil)
  URI.parse(url)
rescue URI::InvalidURIError
  host = url.match(".+\:\/\/([^\/]+)")[1]
  uri = URI.parse(url.sub(host, 'dummy-host'))
  uri.instance_variable_set('@host', host)
  uri
end

def hopen(url)
  begin
    open(url)
  rescue URI::InvalidURIError
    host = url.match(".+\:\/\/([^\/]+)")[1]
    path = url.partition(host)[2] || "/"
    Net::HTTP.get host, path
  end
end