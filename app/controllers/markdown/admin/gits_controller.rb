module Markdown
  class Admin::GitsController < Panel::GitsController

    def index
      q_params = {}
      q_params.merge! default_params

      @gits = Git.default_where(q_params).page(params[:page])
    end

  end
end
