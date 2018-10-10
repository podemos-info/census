# frozen_string_literal: true

shared_examples_for "tracks the user visit" do
  it { expect { subject } .to change(Visit, :count).by(1) }
end

shared_examples_for "doesn't track the user visit" do
  it { expect { subject } .not_to change(Visit, :count) }
end
