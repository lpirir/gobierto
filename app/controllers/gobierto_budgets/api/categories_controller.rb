module GobiertoBudgets
  module Api
    class CategoriesController < ApplicationController
      caches_action :index

      def index
        kind      = params[:kind]
        area_name = params[:area]
        render_404 and return if area_name == 'functional' and kind == 'I'

        if kind.nil? && area_name.nil?
          categories = {}
          BudgetArea.all_areas.each do |area|
            area.available_kinds.each do |kind|
              categories[area.area_name] ||= {}
              categories[area.area_name][kind] = Hash[area.all_items[kind].sort_by{ |k,v| k.to_f }]
            end
          end

          current_site.custom_budget_lines_categories.each do |category|
            categories[CustomArea.area_name][category.kind].merge!({ category.code => category.name })
          end
        else
          area = BudgetArea.klass_for(area_name)
          categories = Hash[area.all_items[kind].sort_by{ |k,v| k.to_f }]
        end


        respond_to do |format|
          format.json do
            render json: categories.to_json
          end
        end
      end
    end
  end
end
