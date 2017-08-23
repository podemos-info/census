class Rack::Attack
  ### Configure Cache ###

  # Static configuration
  client_servers_ips = Set.new Rails.application.secrets.client_servers_ips&.split(/[^\.\d]/)

  # If you don"t want to use Rails.cache (Rack::Attack"s default), then
  # configure it here.
  #
  # Note: The store is only used for throttling (not blacklisting and
  # whitelisting). It must implement .increment and .write like
  # ActiveSupport::Cache::Store

  # Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new 

  ### Throttle Spammy Clients ###

  # If any single client IP is making tons of requests, then they"re
  # probably malicious or a poorly-configured scraper. Either way, they
  # don"t deserve to hog all of the app server"s CPU. Cut them off!
  #
  # Note: If you"re serving assets through rack, those requests may be
  # counted by rack-attack and this throttle may be activated too
  # quickly. If so, enable the condition to exclude them from tracking.

  # Throttle all requests by IP (60rpm)
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip # unless req.path.start_with?("/assets")
  end

  # Block suspicious requests for '/etc/password' or wordpress specific paths.
  # After 3 blocked requests in 10 minutes, block all requests from that IP for 5 minutes.
  Rack::Attack.blocklist('fail2ban pentesters') do |req|
    # `filter` returns truthy value if request fails, or if it's from a previously banned IP
    # so the request is blocked
    Rack::Attack::Fail2Ban.filter("pentesters-#{req.ip}", :maxretry => 3, :findtime => 10.minutes, :bantime => 5.minutes) do
      # The count for the IP is incremented if the return value is truthy
      CGI.unescape(req.query_string) =~ %r{/etc/passwd} ||
      req.path.include?('/etc/passwd') ||
      req.path.include?('wp-admin') ||
      req.path.include?('wp-login')
    end
  end

  ### Prevent Brute-Force Login Attacks ###

  # The most common brute-force login attack is a brute-force password
  # attack where an attacker simply tries a large number of emails and
  # passwords to see if any credentials match.
  #
  # Another common method of attack is to use a swarm of computers with
  # different IPs to try brute-forcing a password for a specific account.

  # Throttle POST requests to /login by IP address
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"
  # throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
  #   if req.path == "/login" && req.post?
  #     req.ip
  #   end
  # end

  # Throttle POST requests to /login by email param
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/email:#{req.email}"
  #
  # Note: This creates a problem where a malicious user could intentionally
  # throttle logins for another user and force their login requests to be
  # denied, but that"s not very common and shouldn"t happen to you. (Knock
  # on wood!)
  # throttle("logins/email", limit: 5, period: 20.seconds) do |req|
  #   if req.path == "/login" && req.post?
  #     # return the email if present, nil otherwise
  #     req.params["email"].presence
  #   end
  # end

  ### Custom Throttle Response ###

  # By default, Rack::Attack returns an HTTP 429 for throttled responses,
  # which is just fine.
  #
  # If you want to return 503 so that the attacker might be fooled into
  # believing that they"ve successfully broken your app (or you just want to
  # customize the response), then uncomment these lines.
  # self.throttled_response = lambda do |env|
  #  [ 503,  # status
  #    {},   # headers
  #    [""]] # body
  # end

  # Always allow requests from localhost
  safelist("allow from localhost") do |req|
    # Requests are allowed if the return value is truthy
    "127.0.0.1" == req.ip || "::1" == req.ip
  end

  # Always allow requests from other servers
  safelist("allow from client servers") do |req|
    # Requests are allowed if the return value is truthy
    client_servers_ips.member? req.ip
  end

  # Block API requests
  Rack::Attack.blocklist("API requests") do |req|
    # Requests are blocked if the return value is truthy
    req.path.start_with?("/api/")
  end
end