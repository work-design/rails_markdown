module Markdown
  module Model::Git::GithubGit

    def markdowns(result = {}, path = 'markdowns', client)
      r = client.contents working_directory, path: path

      if r.is_a?(Array)
        r.each do |entry|
          markdowns(result, entry[:path], client)
        end
      elsif r[:type] == 'file' && r[:name].end_with?('.md')
        detail = { model: posts.find(&->(i){ i.path == r[:path] }) || posts.build(path: r[:path]) }
        if r[:content]
          detail[:model].markdown = Base64.decode64(r[:content]).force_encoding('utf-8')
        end
        result.merge! r[:path] => detail
      elsif r[:type] == 'file' && r[:path].start_with?('assets/')
        detail = { model: assets.find(&->(i){ i.path == r[:path] }) || assets.build(path: r[:path]) }
        detail[:model].name = r[:name]
        blob = client.blob working_directory, r[:sha]
        detail[:model].file.attach(
          io: StringIO.new(Base64.decode64(blob[:content])),
          filename: r[:name]
        )
        result.merge! r[:path] => detail
      end

      result
    end

    def sync(github_user)
      client = github_user.client
      markdowns(client).map do |_, object|
        object[:model].save
      end
    end

    def sync_later(github_user)
      GithubGitJob.perform_later(self, github_user)
    end

  end
end
