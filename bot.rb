#!/usr/bin/env ruby

require 'slack-ruby-bot'
require 'pry'

class PongBot < SlackRubyBot::Bot
  
  # for public channel messages
  scan(/!msg <#(\S*)\|.*> (.*)/) do |client, data, matches|
    channel_id = matches.flatten.first
    message = matches.flatten.last

    target_channel = client.web_client.channels_info(channel: channel_id).channel

    client.say(text: message, channel: target_channel.id)
    client.say(text: 'message sent', channel: data.channel)
  end

  # for user messages
  scan(/!msg <@(\S*)> (.*)/) do |client, data, matches|
    user_id = matches.flatten.first
    message = matches.flatten.last

    target_user = client.web_client.users_info(user: user_id).user

    client.web_client.chat_postMessage(channel: target_user.id, text: message, as_user: true)
    client.say(text: 'message sent', channel: data.channel)
  end

  # for dumping all the other messages to Witt's sockpuppet
  match(/.*/) do |client, data, match|
    channel = client.web_client.channels_info(channel: data.channel) rescue nil
    unless channel
      sender = client.web_client.users_info(user: data.user).user.name
      received_message = match.to_s.partition(" ").last

      crafted_message = "Got message from #{sender}: #{received_message}"

      # Witt's user id is U6Y31HS3U
      # Austin's user id is U6YV7NDC6
      client.web_client.chat_postMessage(channel: ENV['FORWARD_USER_TOKEN'], text: crafted_message, as_user: true)
    end
  end
end

PongBot.run
