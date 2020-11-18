require 'rails_helper'

RSpec.describe "Admin V1 Categories without authentication", type: :request do
  context "GET /categories" do
    let(:url) { "/admin/v1/categories" }
    let!(:categories) { create_list(:category, 5) }

    before(:each) { get url } # paramos de passar o usuário autenticado
    include_examples "unauthenticated access"
  end

  context "POST /categories" do
    let(:url) { "/admin/v1/categories" }

    before(:each) { get url }
    include_examples "unauthenticated access"
  end

  context "PATCH /categories/:id" do
    let(:category) { create(:category) }
    let(:url) { "/admin/v1/categories/#{category.id}" }

    before(:each) { get url }
    include_examples "unauthenticated access"
  end

  context "DELETE /categories/:id" do
    let!(:category) { create(:category) }
    let(:url) { "/admin/v1/categories/#{category.id}" } 

    before(:each) { get url }
    include_examples "unauthenticated access"
  end

end