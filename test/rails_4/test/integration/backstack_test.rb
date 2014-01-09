require 'test_helper'

class BackstackTest < ActionDispatch::IntegrationTest

  # My hackpologies, this is just dizzying.  Hard to see patterns to
  # spot errors.
  def test_backstack_meandering

    # DRYer lambdas
    aback = lambda {|x| ['a#back[href=?]', x.to_s] } # testing backstack_link
    nolink = lambda {|x| ['#no_link_trail', x.to_s] } # testing backstack_trail

    get '/'
    assert_select 'a#back', :count => 0 # means no back link
    assert_select *nolink['Alpha']

    get '/c2/c'
    assert_select *aback['/']
    assert_select *nolink['Alpha / Charlie']

    # testing clicky trail
    assert_select '#link_trail' do
      assert_select "a[href='/']", 'Alpha'
    end

    get '/c2/b'
    assert_select *aback['/']
    assert_select *nolink['Alpha / Bravo']

    get '/'
    assert_select 'a#back', :count => 0
    assert_select *nolink['Alpha']

    get '/c2/c'
    assert_select *aback['/']
    assert_select *nolink['Alpha / Charlie']

    get '/c3/f'
    assert_select *aback['/c2/c']
    assert_select *nolink['Alpha / Charlie / Foxtrot']

    # # testing backstack_ignore - shouldnt change above
    # backstack_ignore('ic1#ignore1') is set in application_controller.rb
    get '/ic1/ignore1'
    # assert_select *aback['/c2/c'] # back link disappears, is that ok?
    assert_select *nolink['Alpha / Charlie / Foxtrot']
 
    # # testing backstack_ignore - *should* change above
    # backstack_ignore('ic2#ignore2') is not set in application_controller.rb
    get '/ic2/ignore2'
    # assert_select *aback['/c2/c'] # back link disappears, is that ok?
    assert_select *nolink['Alpha / Charlie / Ignore2']

    # fix mess we made above 
    get '/c3/f'
    assert_select *aback['/c2/c']
    assert_select *nolink['Alpha / Charlie / Foxtrot']
    
    
    # testing clicky trail
    assert_select '#link_trail' do
      assert_select "a[href='/']", 'Alpha'
      assert_select "a[href='/c2/c']", 'Charlie'
    end

    get '/c4/j'
    assert_select *aback['/c3/f']
    assert_select *nolink['Alpha / Charlie / Foxtrot / Juliet']
    get '/c4/i'
    assert_select *aback['/c3/f']
    assert_select *nolink['Alpha / Charlie / Foxtrot / India']
    get '/c4/h'
    assert_select *aback['/c3/f']
    assert_select *nolink['Alpha / Charlie / Foxtrot / Hotel']
    get '/c4/g'
    assert_select *aback['/c3/f']
    assert_select *nolink['Alpha / Charlie / Foxtrot / Golf']

    # testing clicky trail
    assert_select '#link_trail' do
      assert_select "a[href='/']", 'Alpha'
      assert_select "a[href='/c2/c']", 'Charlie'
      assert_select "a[href='/c3/f']", 'Foxtrot'
    end

    get '/c3/f'
    assert_select *aback['/c2/c']
    assert_select *nolink['Alpha / Charlie / Foxtrot']
    get '/c3/d'
    assert_select *aback['/c2/c']
    assert_select *nolink['Alpha / Charlie / Delta']
    get '/c3/e'
    assert_select *aback['/c2/c']
    assert_select *nolink['Alpha / Charlie / Echo']

    # testing clicky trail
    assert_select '#link_trail' do
      assert_select "a[href='/']", 'Alpha'
      assert_select "a[href='/c2/c']", 'Charlie'
    end

    get '/c2/c'
    assert_select *aback['/']

    get '/'
    assert_select 'a#back', :count => 0 # means no back link
    assert_select *nolink['Alpha']

  end




end
