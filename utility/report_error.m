function report_error(message,type)

    if java.lang.System.getProperty( 'java.awt.headless' )
        fprintf(1,message)
    else
        errordlg(message,type)        
    end

end
