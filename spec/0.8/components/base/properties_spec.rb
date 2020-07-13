require_relative '../../../support/utils'
include Utils

describe 'Properties Mechanism', type: :feature, js: true do

  before :all do
    class PropertyComponent < Matestack::Ui::StaticComponent
      requires :title
      requires :foo
      optional :description, :bar
      optional :text

      def response
        paragraph text: title
        paragraph text: foo
        paragraph text: description
        paragraph text: bar
        paragraph text: text
      end

      register_self_as :property_component
    end
  end

  describe 'missing requires' do
    it 'should raise exception if required property is missing' do
      class ExamplePage < Matestack::Ui::Page
        def response
          property_component
        end
      end

      visit '/example'
      expect(page).to have_content(Matestack::Ui::Core::Properties::PropertyMissingException.to_s)
      expect(page).to have_content('Required property title is missing for PropertyComponent')
    end

    it 'should raise exception if other required property is missing' do
      class ExamplePage < Matestack::Ui::Page
        def response
          property_component title: 'Title'
        end
      end

      visit '/example'
      expect(page).to have_content(Matestack::Ui::Core::Properties::PropertyMissingException.to_s)
      expect(page).to have_content('Required property foo is missing for PropertyComponent')
    end
  end

  describe 'defining methods' do
    it 'should define instance methods for required properties' do
      class ExamplePage < Matestack::Ui::Page
        def response
          property_component title: 'Title', foo: 'Foo'
        end
      end
      visit '/example'
      expect(page).to have_content('Title')
      expect(page).to have_content('Foo')
      prop_component = PropertyComponent.new(title: 'Title', foo: 'Foo')
      expect(prop_component.respond_to?(:title)).to be(true)
      expect(prop_component.respond_to?(:foo)).to be(true)
    end

    it 'should define instance methods for optional properties' do
      class ExamplePage < Matestack::Ui::Page
        def response
          property_component title: 'Title', foo: 'Foo', description: 'Description', bar: 'Bar'
        end
      end
      visit '/example'
      expect(page).to have_content('Description')
      expect(page).to have_content('Bar')
      prop_component = PropertyComponent.new(title: 'Title', foo: 'Foo')
      expect(prop_component.respond_to?(:description)).to be(true)
      expect(prop_component.respond_to?(:bar)).to be(true)
    end
  end

  it 'should raise exception if required property overwrites existing method' do
    class TempPropertyComponent < Matestack::Ui::StaticComponent
      requires :response
      def response
      end
      register_self_as :temp_property_component
    end

    class ExamplePage < Matestack::Ui::Page
      def response
        temp_property_component response: 'Foobar'
      end
    end

    visit '/example'
    expect(page).to have_content(Matestack::Ui::Core::Properties::PropertyOverwritingExistingMethodException.to_s)
    expect(page).to have_content('Required property response would overwrite already defined instance method for TempPropertyComponent')
  end

  it 'should raise exception if optional property overwrites existing method' do
    class TempOptionalPropertyComponent < Matestack::Ui::StaticComponent
      optional :response
      def response
      end
      register_self_as :temp_optional_property_component
    end

    class ExamplePage < Matestack::Ui::Page
      def response
        temp_optional_property_component response: 'Foobar'
      end
    end

    visit '/example'
    expect(page).to have_content(Matestack::Ui::Core::Properties::PropertyOverwritingExistingMethodException.to_s)
    expect(page).to have_content('Optional property response would overwrite already defined instance method for TempOptionalPropertyComponent')
  end

end