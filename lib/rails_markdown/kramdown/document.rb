require 'kramdown'
require 'kramdown-parser-gfm'

module Kramdown
  class Element

    # 注意，这里 a, img 的 children 是忽略了的
    def group_elements(result = {})
      if result.key?(type)
        result[type] << self
      elsif children.present?
        children.each do |ele|
          ele.group_elements(result)
        end
        result
      else
        result
      end
    end

  end
end
