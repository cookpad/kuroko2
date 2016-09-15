require 'rails_rinku'

module Kuroko2
  module ApplicationHelper
    include RailsRinku
    alias_method :auto_link, :rinku_auto_link
  end
end
