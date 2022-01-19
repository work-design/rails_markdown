require 'httpx'
module Markdown
  module Marp
    BASE_URL = 'http://localhost:4000'
    extend self

    def parse(markdown)
      r = HTTPX.post(
        BASE_URL + '/marp',
        body: markdown
      )

      if r.status == 200
        JSON.parse(r.to_s)
      else
        { response: r.body.to_s }
      end
    end

  end
end
