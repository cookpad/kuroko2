json.token @response.next_forward_token
json.events do
  json.array! @response.events do |event|
    json.timestamp l(Time.at(event.timestamp/1000), format: :short)
    begin
      log = JSON.parse(event.message)
      json.message rinku_auto_link(html_escape(log['message']), :urls)
      json.pid log['pid']
      json.uuid log['uuid']
    rescue JSON::ParserError
      json.message rinku_auto_link(html_escape(event.message), :urls)
    end
  end
end

# vim: set ft=ruby:
