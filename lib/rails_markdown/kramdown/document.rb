require 'kramdown'
require 'kramdown-parser-gfm'

module Kramdown
  class Element

    def links(result = [])
      if type == :a
        result << self
      elsif children.present?
        children.each do |ele|
          ele.links(result)
        end
        result
      end
      result
    end

  end
end
