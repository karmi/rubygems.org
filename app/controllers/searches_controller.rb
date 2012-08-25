class SearchesController < ApplicationController

  def show
    if params[:query]
      @gems = Rubygem.tire.search :page     => params[:page],
                                  :per_page => Rubygem.per_page,
                                  :load     => {:include => 'versions'} do |search|
        search.query  { |q| q.text 'name', params[:query], :type => 'phrase_prefix', :operator => 'and' }
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
