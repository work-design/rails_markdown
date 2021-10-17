module Markdown
  module Model::Git::GithubGit

    def markdowns(result = {}, path = nil, client)
      r = client.contents working_directory, path: path

      if r.is_a?(Array)
        r.each do |entry|
          if entry[:name].end_with?('.md') || entry[:type] == 'dir'
            markdowns(result, entry[:path], client)
          end
        end
      elsif r.is_a?(Sawyer::Resource)
        detail = { model: posts.find(&->(i){ i.path == r[:path] }) || posts.build(path: r[:path]) }
        if r[:content]
          detail.merge! content: Base64.decode64(r[:content]).force_encoding('utf-8')
        end
        result.merge!(r[:path] => detail)
      end

      result
    end

    def sync(github_user)
      client = github_user.client
      markdowns(client).map do |_, object|
        object[:model].markdown = object[:content]
        object[:model].save
      end
    end

  end
end
