require 'test_helper'

class SearchesControllerTest < ActionController::TestCase
  def setup
    super
    Rubygem.tire.index.delete
    Rubygem.tire.create_elasticsearch_index
  end

  context 'on GET to show with no search parameters' do
    setup { get :show }

    should respond_with :success
    should render_template :show
    should "see no results" do
      assert ! page.has_content?("Results")
    end
  end

  context 'on GET to show with search parameters for a rubygem without versions' do
    setup do
      @sinatra = create(:rubygem, :name => "sinatra")
      assert_nil @sinatra.versions.most_recent
      assert @sinatra.reload.versions.count.zero?
      get :show, :query => "sinatra"
    end

    should respond_with :success
    should render_template :show
  end

  context 'on GET to show with search parameters' do
    setup do
      @sinatra = create(:rubygem, :name => "sinatra")
      @sinatra_redux = create(:rubygem, :name => "sinatra-redux")
      @brando  = create(:rubygem, :name => "brando")
      create(:version, :rubygem => @sinatra)
      create(:version, :rubygem => @sinatra_redux)
      create(:version, :rubygem => @brando)
      get :show, :query => "sinatra"
    end

    should respond_with :success
    should render_template :show
    should assign_to(:gems) { [@sinatra, @sinatra_redux] }
    should assign_to(:exact_match) { @sinatra }
    should "see sinatra on the page in the results" do
      assert page.has_content?(@sinatra.name)
      assert page.has_selector?("a[href='#{rubygem_path(@sinatra)}']")
    end
    should "not see brando on the page in the results" do
      assert ! page.has_content?(@brando.name)
      assert ! page.has_selector?("a[href='#{rubygem_path(@brando)}']")
    end
  end

  context 'on GET to show with bad search query' do
    setup { get :show, :query => 'bang!' }

    should respond_with :internal_server_error
    should render_template :show
    should set_the_flash.now[:failure].to /query is incorrect/
    should "see no results" do
      assert ! page.has_content?("Results")
    end
  end
end
