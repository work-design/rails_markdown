module Markdown
  class PostsController < BaseController
    before_action :set_post, only: [:show]

    def index
      q_params = {}
      q_params.merge 'git.organ_id': current_organ.id if defined?(current_organ) && current_organ

      @posts = Post.published.default_where(q_params).page(params[:page])
    end

    def show
    end

    def ppt
      @post = Post.find params[:id]
    end

    def asset
      path = params[:path].match(/assets\/.+/).to_s
      file = "#{path}.#{params[:format]}"
      real_path = RailsMarkdown::Engine.root.join('posts', file)

      send_file real_path
    end

    private
    def set_post
      path = "#{params[:path]}.#{params[:format]}"

      @post = Post.find_by(path: path)
    end

  end
end
