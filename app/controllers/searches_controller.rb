class SearchesController < ApplicationController

  def show
    Tire.configure { logger STDERR } if Rails.env.development?

    if params[:query]
      @gems = Rubygem.tire.search "name:(*#{params[:query]}*) AND indexed:true",
                                  :page     => params[:page],
                                  :per_page => Rubygem.per_page,
                                  :load     => {:include => 'versions'}
      @exact_match = Rubygem.name_is(params[:query]).with_versions.first
    end
  end

end
