class SearchesController < ApplicationController

  # Indicate incorrect query to the user
  rescue_from Tire::Search::SearchRequestFailed do |error|
    flash.now[:failure] = "Sorry, your query is incorrect." if error.message =~ /SearchParseException/ && params[:query]
    render :show, :status => :internal_server_error
  end

  def show
    if params[:query].present?
      @gems = Rubygem.tire.search :page     => params[:page],
                                  :per_page => Rubygem.per_page,
                                  :load     => {:include => 'versions'} do |search|
        search.query do |q|
          q.boolean do |it|
            it.should { |q| q.text   'name', params[:query], :type => 'phrase_prefix', :operator => 'and', :boost => 100 }
            it.should { |q| q.string params[:query], :default_operator => 'and' }
          end
        end
        search.filter :term, :indexed => true
        search.sort   do
          by 'downloads', :desc
          by 'name.raw',  :asc
        end

        STDOUT.puts search.to_curl if Rails.env.development?
      end

      @exact_match = Rubygem.name_is(params[:query]).with_versions.first
    end
  end

end
