# frozen_string_literal: true

shared_examples_for "has comments enabled" do
  it "shows current comments" do
    subject
    expect(response.body).to match(/id\=\"active_admin_comments_for_[a-z_]+_\d+\"/)
  end

  it "allows to add a comment" do
    subject
    expect(response.body).to match(/id\=\"new_active_admin_comment\"/)
  end
end
