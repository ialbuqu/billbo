# encoding: UTF-8

get '/bill/new' do
  if session[:email].nil?
    redirect '/auth?url=/bill/new'
  end

  if Admin.where(email: session[:email]).any?
    erb :"/bills/new", locals: { errors: [] }
  else
    redirect '/', :error => i18n.not_an_admin_account
  end
end

post '/bill/create' do
  due_date = Date.parse(params[:due_date]) rescue nil
  bill = Bill.new(params.merge("due_date" => due_date))

  if bill.save
    redirect '/bill/new', :success => i18n.bill_creation_ok
  else
    erb :"/bills/new", locals: { errors: bill.errors.full_messages }
  end
end

get '/bill/upload-receipt/:bill_id' do
  @action = "/bill/upload-receipt/#{params[:bill_id]}"
  erb :"/bills/upload_receipt"
end

post '/bill/upload-receipt/:bill_id' do
  bill = Bill.find(params[:bill_id])
  receipt = bill.create_receipt(params)

  if bill.save
    send_email receipt, bill
    redirect '/', :success => i18n.upload_receipt_ok
  else
    redirect "/bill/upload-receipt/#{params[:bill_id]}", :error => i18n.upload_receipt_fail
  end
end

get '/bill/reserve/:bill_id' do
  @action = "/bill/reserve/#{params[:bill_id]}"
  erb :"bills/reserve"
end

post '/bill/reserve/:bill_id' do
  bill = Bill.find(params[:bill_id])
  bill.reservations.create(params)

  unless bill.reservations.last.errors.any?
    bill.status = :reserved
    bill.save
    redirect '/', :success => i18n.reserve_bill_ok
  else
    redirect "/bill/reserve/#{params[:bill_id]}", :error => i18n.reserve_bill_fail
  end
end

private

def send_email payment, bill
  Admin.all.each do |admin|
    Pony.mail :to => admin.email,
          :from => payment.contributor_email,
          :subject => i18n.upload_receipt_subject,
          :html_body => erb(:"/mails/payment_confirmation",
                            :locals => {:receipt => payment, :bill => bill },
                            :layout => false),
          :via => :smtp

  end
end
