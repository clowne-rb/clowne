describe Clowne do
  it 'has a version number' do
    # Sequel::Topic.association_reflections
    user = Sequel::User.create
    post = Sequel::Post.create
    user.add_post(post)

    user.posts_dataset.alpha_first.to_a # Get association with named scope
    scope = Proc.new { |params| where(title: params[:title]) } # scope as Proc
    user.posts_dataset.instance_exec({title: "dog"}, &scope) # call it

    Sequel::User.instance_variable_get("@create_timestamp_field")
    Sequel::User.instance_variable_get("@update_timestamp_field")

    expect(Clowne::VERSION).not_to be nil
  end
end
