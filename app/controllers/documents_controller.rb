class DocumentsController < ApplicationController

def new
    @document = Document.new
end

def create
    @document = Document.new(params[:document])
    # TODO: additional verification of correct user?
    return if redirected_because(params[:document].nil? || params[:document][:user_id].nil? || params[:document][:user_id].to_i != current_user.id,
        "Error: Couldn't associate document with your user. Please re-upload.",
        "/dashboard")
     
    @document.user = current_user
    # Process document type
    @document.document_type = params[:document][:document_type]
    
    if @document.save
        flash[:notice] = "Thanks for the upload! It should now show up in your profile. paramsdoctype=#{params[:document][:document_type]}, doctype=#{@document.document_type}"
    else
        flash[:notice] = "Oops! Something went wrong with your upload. No changes were made."
    end

    redirect_back_or_default "/dashboard"
end

def destroy
    @document = Document.find(params[:id])
    if @document.user == current_user
        if @document.destroy
            flash[:notice] = "Removed the requested document."
        else
            flash[:notice] = "The requested document escaped our virtual shredder. Please try again, or contact support."
        end
    else
        flash[:notice] = "Access violation."
    end
    redirect_back_or_default "/dashboard"
end

end