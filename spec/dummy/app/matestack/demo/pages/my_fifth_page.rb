class Demo::Pages::MyFifthPage < Matestack::Ui::Page

  def prepare
    @dummy_models = DummyModel.all
  end

  def response
    heading size: 2, text: "This is Page 5"

    heading size: 3, text: "Dummy Models"
    async id: 'dummy-model-list', rerender_on: "test_model_created" do
      ul do
        @dummy_models.each do |dummy_model|
          li do
            plain dummy_model.title
          end
        end
      end
    end
  end

end
