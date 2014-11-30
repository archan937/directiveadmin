module ActiveAdmin
  class Comment < ActiveRecord::Base

    def display_name
      body
    end

  end
end
