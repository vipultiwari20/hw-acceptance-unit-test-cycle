require 'rails_helper'
describe MoviesController do
  before(:each) do
    @movie1 = FactoryBot.create(:movie, id: 1, title: "Shawshank Redemption", rating: "UG", description: "", release_date: "1996", director: "Unkown")
    @movie2 = FactoryBot.create(:movie, id: 2, title: "The Green Mile", rating: "PG", description: "", release_date: "1993", director: "Unkown")
    @movie3 = FactoryBot.create(:movie, id: 3, title: "no director", rating: "R", description: "test", release_date: "test")
  end

  describe 'preexisting method test in before(:each)' do
    it 'should call find model method' do
      Movie.should_receive(:find).with('1')
      get :show, :id => '1'
    end

    it 'should render page correctoy' do
      get :index
      response.should render_template :index
    end

    it 'should redirect to appropriate url' do
      get :index, 
          {},    
          {ratings: {G: 'G', PG: 'PG'}}
      response.should redirect_to :ratings => {G: 'G', PG: 'PG'}
    end

    it 'should create movie and redirect' do
      post :create,
           {:movie => { :title => "Golmaal", :description => "A comedy movie", :director => "Rohit Shetty", :rating => "R", :release_date =>"02/08/2006"}}
      response.should redirect_to movies_path
      expect(flash[:notice]).to be_present

    end
    it 'should render two movies' do
      get :index
      response.should render_template :index
    end

    it 'should update render edit view' do
      Movie.should_receive(:find).with('1')
      get :edit,
          {id: '1'}

    end

    it 'should update data correctly' do
      Movie.stub(:find).and_return(@movie1)
      put :update,
          :id => @movie1[:id],
          :movie => {title: "Another Movie", rating: "UG", description: "Horror movie", release_date: "25/11/2066", director: "Rohit Shetty"}
      expect(flash[:notice]).to be_present
    end
  end

  describe 'director methods test in before(:each)' do
    it 'should call appropriate model method' do
      Movie.should_receive(:similar_movies).with(@movie2[:id], {'director' => @movie2[:director]})
      get :similar, :id => @movie2[:id], :based_on => 'director'
    end

    it 'should redirect to homepage on invalid no director request' do
      Movie.should_receive(:similar_movies).with(@movie3[:id], {'director' => @movie3[:director]})
      Movie.stub(:similar_movies).with(@movie3[:id], {'director' => @movie3[:director]}).and_return(nil)
      get :similar, :id => @movie3[:id], :based_on => 'director'
      expect(flash[:notice]).to be_present
      response.should redirect_to movies_path
    end
  end
end