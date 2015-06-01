require_relative '../db/setup'
require_relative '../lib/user'
# Remember to put the requires here for all the classes you write and want to use

def parse_params(uri_fragments, query_param_string)
  params = {}
  params[:resource]  = uri_fragments[3]
  params[:id]        = uri_fragments[4]
  params[:action]    = uri_fragments[5]
  if query_param_string
    param_pairs = query_param_string.split('&')
    param_k_v   = param_pairs.map { |param_pair| param_pair.split('=') }
    param_k_v.each do |k, v|
      params.store(k.to_sym, v)
    end
  end
  params
end

def parse(raw_request)
  pieces = raw_request.split(' ')
  method = pieces[0]
  uri    = pieces[1]
  http_v = pieces[2]
  route, query_param_string = uri.split('?')
  uri_fragments = route.split('/')
  protocol = uri_fragments[0][0..-2]
  full_url = uri_fragments[2]
  subdomain, domain_name, tld = full_url.split('.')
  params = parse_params(uri_fragments, query_param_string)
  return {
    method: method,
    uri: uri,
    http_version: http_v,
    protocol: protocol,
    subdomain: subdomain,
    domain_name: domain_name,
    tld: tld,
    full_url: full_url,
    params: params
  }
end

system('clear')
loop do
  print "Supply a valid HTTP Request URL (h for help, q to quit) > "
  raw_request = gets.chomp

  case raw_request
  when 'q' then puts "Goodbye!"; exit
  when 'h'
    puts "A valid HTTP Request looks like:"
    puts "\t'GET http://localhost:3000/students HTTP/1.1'"
    puts "Read more at : http://www.w3.org/Protocols/rfc2616/rfc2616-sec5.html"
  else
    REQUEST = parse(raw_request)
    PARAMS  = REQUEST[:params]
    # Use the REQUEST and PARAMS constants to fill the request and
    # return an appropriate reponse
    # YOUR CODE GOES BELOW HERE
    @users = User.all
    puts REQUEST
    if User.exists?(PARAMS[:id])
      puts "200 OK"
      user = @users.find(PARAMS[:id])
      puts "#{user.first_name} #{user.last_name} | #{user.age}"
    elsif PARAMS[:first_name]
      starts_with = User.where("first_name LIKE ?", "#{PARAMS[:first_name]}%")
      starts_with.each do |user|
        puts "#{user.first_name} #{user.last_name} | #{user.age}"
      end
    elsif PARAMS[:resource] == "users" && PARAMS[:id] == nil
      puts "200 OK"
      @users.each do |user|
        puts "#{user.first_name} #{user.last_name} | #{user.age}"
      end
    else
      puts "404 Not Found"
    end
    # YOUR CODE GOES ABOVE HERE  ^
  end
end
