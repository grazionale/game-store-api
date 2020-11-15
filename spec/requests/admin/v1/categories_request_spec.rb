require 'rails_helper'

RSpec.describe 'Admin::V1::Categories', type: :request do
  let(:user) { create(:user) }

  context 'GET /categories' do
    let(:url) { '/admin/v1/categories' }
    # ! significa bang, Precisamos fazer isso porque o let opera com lazy loading, ou seja,
    # ele só carrega o conteúdo quando chamamos o método pela primeira vez. Precisamos utilizar
    # o let! para categories porque nós precisamos que ele seja executado antes de fazermos o
    # request, caso contrário não teremos dados retornados pelo endpoint.
    let!(:categories) { create_list(:category, 5) }

    it 'returns all Categories' do
      get url, headers: auth_header(user)
      expect(body_json['categories']).to contain_exactly(*categories.as_json(only: %i[id name]))
    end

    it 'returns success status' do
      get url, headers: auth_header(user)
      expect(response).to have_http_status(:ok)
    end
  end

  context 'POST /categories' do
    let(:url) { '/admin/v1/categories' }

    context 'with valid params' do
      # attribute_for do Factory Bot. Este método retorna um hash com os dados de uma
      # factory, que armazenamos numa chave category. Chamamos o to_json para que ele
      # transforme este hash em JSON de fato para enviarmos no request
      let(:category_params) { { category: attributes_for(:category) }.to_json }

      it 'adds a new Category' do
        expect do
          # Deste post, ele verifica que Category aumentou a quantidade em 1. Desse jeito
          # conseguimos verificar se ela foi realmente persistida no banco
          post url, headers: auth_header(user), params: category_params
        end.to change(Category, :count).by(1)
      end

      it 'returns last added Category' do
        post url, headers: auth_header(user), params: category_params
        expected_category = Category.last.as_json(only: %i[id name])
        expect(body_json['category']).to eq expected_category
      end

      it 'returns success status' do
        post url, headers: auth_header(user), params: category_params
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid params' do
      let(:category_invalid_params) do
        { category: attributes_for(:category, name: nil) }.to_json
      end

      it 'does not add a new Category' do
        # POST com estes parâmetros inválidos que estamos nos certificando que 
        # Category não possui nenhuma alteração na contagem.
        expect do
          post url, headers: auth_header(user), params: category_invalid_params
        end.to_not change(Category, :count)
      end

      # estamos verificando se a resposta possui a chave name dentro da estrutura de erro
      it 'returns error message' do
        post url, headers: auth_header(user), params: category_invalid_params
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it 'returns unprocessable_entity status' do
        post url, headers: auth_header(user), params: category_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end    
    end
  end

  context "PATCH /categories/:id" do
    let(:category) { create(:category) }
    let(:url) { "/admin/v1/categories/#{category.id}" }

    context "with valid params" do
      let(:new_name) { 'My new Category' }
      let(:category_params) { { category: { name: new_name } }.to_json }

      it 'updates Category' do
        patch url, headers: auth_header(user), params: category_params
        # reload com a category que criamos para que ela seja recarregada do banco e 
        # verificamos se o nome dela é igual ao novo nome que definimos nos parâmetros
        category.reload
        expect(category.name).to eq new_name
      end  

      it 'returns updated Category' do
        patch url, headers: auth_header(user), params: category_params
        category.reload
        expected_category = category.as_json(only: %i(id name))
        expect(body_json['category']).to eq expected_category
      end
      
      it 'returns success status' do
        patch url, headers: auth_header(user), params: category_params
        expect(response).to have_http_status(:ok)
      end      
    end
  
    context "with invalid params" do
      let(:category_invalid_params) do 
        { category: attributes_for(:category, name: nil) }.to_json
      end
  
      it 'does not update Category' do
        old_name = category.name
        patch url, headers: auth_header(user), params: category_invalid_params
        category.reload
        expect(category.name).to eq old_name
      end
      
      it 'returns error message' do
        patch url, headers: auth_header(user), params: category_invalid_params
        expect(body_json['errors']['fields']).to have_key('name')
      end
      
      it 'returns unprocessable_entity status' do
        patch url, headers: auth_header(user), params: category_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end      
    end  
  end
  
end
