ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: "Dashboard"

  content do
    # force load chartkick
    text_node javascript_include_tag("application")
  end

  content title: "Dashboard" do
    columns do
      # SUPER ADMIN DASHBOARD
      if current_admin_user.super_admin?
        column do
          panel "Global Stats" do
            div style: "display:grid;grid-template-columns:repeat(3,1fr);gap:15px;" do

              div style: card_style do
                h4 "Companies"
                h2 Company.count
              end

              div style: card_style do
                h4 "Admin Users"
                h2 AdminUser.count
              end

              div style: card_style do
                h4 "Users"
                h2 User.count
              end

              div style: card_style do
                h4 "Quotes"
                h2 Quote.count
              end

              div style: card_style do
                h4 "Line Item Dates"
                h2 LineItemDate.count
              end

              div style: card_style do
                h4 "Line Items"
                h2 LineItem.count
              end

            end
          end

          # Charts
          panel "Quotes Created Over Time" do
            line_chart Quote.group_by_day(:created_at).count
          end

          panel "Users Created Over Time" do
            line_chart User.group_by_day(:created_at).count
          end

          panel "Line Items Created Over Time" do
            line_chart LineItem.group_by_day(:created_at).count
          end
        end

      # COMPANY ADMIN DASHBOARD
      else
        column do
          company_id = current_admin_user.company_id

          panel "Company Stats" do
            div style: "display:grid;grid-template-columns:repeat(2,1fr);gap:15px;" do

              div style: card_style do
                h4 "Users"
                h2 User.where(company_id: company_id).count
              end

              div style: card_style do
                h4 "Quotes"
                h2 Quote.where(company_id: company_id).count
              end

              div style: card_style do
                h4 "Line Item Dates"
                h2 LineItemDate.joins(:quote)
                                .where(quotes: { company_id: company_id })
                                .count
              end

              div style: card_style do
                h4 "Line Items"
                h2 LineItem.joins(line_item_date: :quote)
                           .where(quotes: { company_id: company_id })
                           .count
              end

            end
          end

          # Charts (company scoped)
          panel "Quotes Over Time" do
            line_chart Quote.where(company_id: company_id)
                            .group_by_day(:created_at).count
          end

          panel "Users Over Time" do
            line_chart User.where(company_id: company_id)
                           .group_by_day(:created_at).count
          end

          panel "Line Items Over Time" do
            line_chart LineItem.joins(line_item_date: :quote)
                     .where(quotes: { company_id: company_id })
                     .group_by_day(:created_at)
                     .count
          end
        end
      end
    end
  end

  # Reusable card style
  controller do
    helper_method :card_style

    def card_style
      "padding:20px;background:#f9fafb;border-radius:10px;
       box-shadow:0 2px 5px rgba(0,0,0,0.05);text-align:center;"
    end
  end
end
