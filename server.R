options(shiny.maxRequestSize = 32*1024^2)
options(shiny.sanitize.errors = TRUE)

library(shiny)
library(rmarkdown)
library(data.table)
library(readr)

source("Functions.R")

# Define server logic 
shinyServer(function(input, output, session) {
  
  
  # Upload data
  datainput <- reactive({ 
    
    ###############
    # Validations
    ###############
    
    validate(need(input$file$datapath != "", "Please upload a CSV file."))
    
    validate(need(tools::file_ext(input$file$datapath) == "csv", "Error. Not a CSV file. Please upload a CSV file."))
    
    
    if (input$fencoding == "unknown"){
      
      validate(need(try(datainput1 <- fread(input$file$datapath, header = "auto", sep="auto", dec=".", encoding = "unknown", 
                                            data.table = FALSE, na.strings = "")),
                    "Error. File cannot be read. Please check that the file is not empty, fully whitespace, or skip has been set after the last non-whitespace."))
      
      validate(need(tryCatch(datainput1 <- fread(input$file$datapath, header = "auto", sep="auto", dec=".", encoding = "unknown", 
                                           data.table = FALSE, na.strings = ""), warning=function(w) {}),
                    "Error. The file cannot be read unambigously. Check the characters for the field separator (semicolon should work in most cases), quote or decimal."
                    ))

      validate(need(try(iconv(colnames(datainput1), guess_encoding(input$file$datapath)[[1]][1], "UTF-8")),
                        "Error. Encoding cannot be converted. Please try other upload options."))
      
               
      validate(need(try(sapply(datainput1[, sapply(datainput1, is.character)], function(col) iconv(col, guess_encoding(input$file$datapath)[[1]][1], "UTF-8"))),
                        "Error. Encoding cannot be converted. Please try other upload options."))
      
    }
    
   if (input$fencoding == "UTF-8"){
      
      validate(
       need(guess_encoding(input$file$datapath)[[1]][1] %in% c("UTF-8","ASCII") & 
               guess_encoding(input$file$datapath)[[2]][1] > 0.9,
             "Error. The file is probably not UTF-8 encoded. Please convert to UTF-8 or try the automatic encoding option.")
      )
     
      validate(need(try(datainput1 <- fread(input$file$datapath, header = "auto", sep="auto", dec=".", encoding = "UTF-8", 
                                  data.table = FALSE, na.strings = "")), "Error. File cannot be read. Please check that the file is not empty, fully whitespace, or skip has been set after the last non-whitespace."))
      
      
      validate(need(tryCatch(datainput1 <- fread(input$file$datapath, header = "auto", sep="auto", dec=".", encoding = "unknown", 
                                                 data.table = FALSE, na.strings = ""), warning=function(w) {}),
                    "Error. The file cannot be read unambigously. Check the characters for the field separator (semicolon should work in most cases), quote or decimal."
      ))

   }
    
   

   if (is.null(input$file))
      return(NULL)
    
    
    ###############
    # Datainput code
    ################
    
    return(tryCatch(
      
      
      if (input$fencoding == "UTF-8" & input$decimal == "auto"){ 
        
        datainput1 <- fread(input$file$datapath, header = "auto", sep="auto", dec=".", encoding = "UTF-8", data.table = FALSE, na.strings = "")
        
        # Probably comma as decimal
        colnames <- sapply(datainput1, function(col) is.numeric(col) & Negate(is.integer)(col))
        if (sum(colnames) == 0L){
          
          datainput1 <- fread(input$file$datapath, header = "auto", sep="auto", dec=",", encoding = "UTF-8", data.table = FALSE, na.strings = "")
          size <- min(dim(datainput1)[1],15)
          datainput1 <- datainput1[1:size,,drop=FALSE]
          datainput1
          
        } else {
          size <- min(dim(datainput1)[1],15)
          datainput1 <- datainput1[1:size,,drop=FALSE]
          datainput1
          }
        
      } else if (input$fencoding == "UTF-8" & input$decimal != "auto") {
        
        datainput1 <- fread(input$file$datapath, header = "auto", sep="auto", dec=input$decimal, encoding = "UTF-8", data.table = FALSE, na.strings = "")
        size <- min(dim(datainput1)[1],15)
        datainput1 <- datainput1[1:size,,drop=FALSE]
        datainput1
        
        
      } else if (input$fencoding == "unknown" &  input$decimal == "auto"){
        
        enc_guessed <- guess_encoding(input$file$datapath)
        enc_guessed_first <- enc_guessed[[1]][1]
        datainput1 <- fread(input$file$datapath, header = "auto", sep="auto", dec=".", encoding = "unknown", data.table = FALSE, na.strings = "")
        
        # Probably comma as decimal
        colnames <- sapply(datainput1, function(col) is.numeric(col) & Negate(is.integer)(col))
        if (sum(colnames) == 0L){
          
          datainput1 <- fread(input$file$datapath, header = "auto", sep="auto", dec=",", encoding = "unknown", data.table = FALSE, na.strings = "")
          colnames(datainput1) <- iconv(colnames(datainput1), enc_guessed_first, "UTF-8")
          col_names <- sapply(datainput1, is.character)
          datainput1[ ,col_names] <- sapply(datainput1[, col_names], function(col) iconv(col, enc_guessed_first, "UTF-8"))
          size <- min(dim(datainput1)[1],15)
       #   datainput1 <- datainput1[1:size,,drop=FALSE]
          datainput1
          
        } else {
          
          colnames(datainput1) <- iconv(colnames(datainput1), enc_guessed_first, "UTF-8")
          col_names <- sapply(datainput1 , is.character)
          datainput1[ ,col_names] <- sapply(datainput1[, col_names], function(col) iconv(col, enc_guessed_first, "UTF-8"))
          size <- min(dim(datainput1)[1],15)
    #      datainput1 <- datainput1[1:size,,drop=FALSE]
          datainput1}
        
      } else {
        
        enc_guessed <- guess_encoding(input$file$datapath)
        enc_guessed_first <- enc_guessed[[1]][1]
        datainput1 <- fread(input$file$datapath, header = "auto", sep="auto", dec = input$decimal, encoding = "unknown", data.table = FALSE, na.strings = "")
        colnames(datainput1) <- iconv(colnames(datainput1), enc_guessed_first, "UTF-8")
        col_names <- sapply(datainput1, is.character)
        datainput1[ ,col_names] <- sapply(datainput1[, col_names], function(col) iconv(col, enc_guessed_first, "UTF-8"))
        size <- min(dim(datainput1)[1],15)
   #     datainput1 <- datainput1[1:size,,drop=FALSE]
        datainput1
        
      }
      
      ,error=function(e) stop(safeError(e))
      
    ))
    
    
  })
  
  
  # Check upload
  
  output$uploadtext <- renderText({
    
    req(datainput())
    
    paste("Upload completed without errors. You can continue with the download.")
    
  })
  
  
  # Ui Output for R code option
  output$ui <- renderUI({
    
    if (is.null(input$format))
      return()
    
    switch(input$format, "PDF"= radioButtons('rcode', 'Include R Code', c('No','Yes'), inline = TRUE))
           
  })
  
  
  # Disable downloadbutton if false utf8
  observe({
    
    req(input$file)
    
    if (tools::file_ext(input$file$datapath) == "csv" & input$fencoding == "UTF-8"){
      
      if (guess_encoding(input$file$datapath)[[1]][1] != "UTF-8" & 
          guess_encoding(input$file$datapath)[[1]][1] != "ASCII"){session$sendCustomMessage("check_utf8", list(check_utf8 = 1))}
      
      if (guess_encoding(input$file$datapath)[[1]][1] == "UTF-8" & 
          guess_encoding(input$file$datapath)[[2]][1] <= 0.9){session$sendCustomMessage("check_utf8", list(check_utf8 = 1))}
      
      if (guess_encoding(input$file$datapath)[[1]][1] == "ASCII" & 
          guess_encoding(input$file$datapath)[[2]][1] <= 0.9){session$sendCustomMessage("check_utf8", list(check_utf8 = 1))}
    
    }
  })
  
  # Disable downloadbutton if no csv
  observe({
    
    req(input$file)
    
    if (tools::file_ext(input$file$datapath) != "csv"){
      
      session$sendCustomMessage("check_csv", list(check_csv = 1))
      
    }
    
  })
  
  
  # Disable downloadbutton at fread error 
  observe({
    
    req(input$file)
    
    if (tools::file_ext(input$file$datapath) == "csv" & input$fencoding == "unknown"){
      
      
    tryCatch({fread(input$file$datapath, header = "auto", sep="auto", dec=".", encoding = "unknown", 
                      data.table = FALSE, na.strings = "")}, 
             
              error=function(e) {
               
               session$sendCustomMessage("check_fread", list(check_fread = 1))
               
              },
             
               warning = function(w) {
                 
                 session$sendCustomMessage("check_fread", list(check_fread = 1))
                 
               }
             )  
      
    }
    
    
    
    if (tools::file_ext(input$file$datapath) == "csv" & input$fencoding == "UTF-8"){
      
      tryCatch({fread(input$file$datapath, header = "auto", sep="auto", dec=".", encoding = "UTF-8", 
                      data.table = FALSE, na.strings = "")}, 
               
               error=function(e) {
                 session$sendCustomMessage("check_fread", list(check_fread = 1))
                 
               },
      
              warning = function(w) {
                session$sendCustomMessage("check_fread", list(check_fread = 1))
                }
              )  
    }
    
  })  
  
  
  # Select Variables
  output$selection1 <- renderUI({
    
    req(datainput())
    
    chooserInput("selection1", "Available", "Selected",
                 colnames(datainput()), c(), size = 15, multiple = TRUE)
    
  })
  

  # Enable downloadbutton if file, datainput() and at least selection1 ready
  observe({
    
    req(input$file, datainput(), input$selection1$right)
    session$sendCustomMessage("check_download", list(check_download = 1))
    
  })
  
  # Download report
  output$downloadReport <- downloadHandler(
    
    
    filename = function() {
      paste('MyReport', sep = '.','pdf')
    },
    
    content = function(file) {
      
      src0 <- normalizePath('report_kernel.Rmd') 
      src1 <- normalizePath('report.Rmd')
      src2 <- normalizePath('Logo.jpg')
      src3 <- normalizePath('logo.Rmd')
      src4 <- normalizePath('references.bib')
      src5 <- normalizePath('report_code_unknown.Rmd') 
      src6 <- normalizePath('report_code_common.Rmd') 
      
      # Temporarily switch to the temp dir
      owd <- setwd(tempdir())
      on.exit(setwd(owd))
      file.copy(src0, 'report_kernel.Rmd', overwrite = TRUE)
      file.copy(src1, 'report.Rmd', overwrite = TRUE)
      file.copy(src2, 'Logo.jpg', overwrite = TRUE)
      file.copy(src3, 'logo.Rmd', overwrite = TRUE)
      file.copy(src4, 'references.bib', overwrite = TRUE)
      file.copy(src5, 'report_code_unknown.Rmd', overwrite = TRUE)
      file.copy(src6, 'report_code_common.Rmd', overwrite = TRUE)
      
      # Set up parameters to pass to Rmd document
      enc_guessed <- guess_encoding(input$file$datapath)
      enc_guessed_first <- enc_guessed[[1]][1]
      
      params <- list(data = datainput(), filename=input$file, decimal=input$decimal, enc_guessed = enc_guessed_first, 
                     vars1 = input$selection1$right)
      
      # Knit the document
      
      withProgress(message = 'Please wait, Statsomat is computing...', value=0, {
        
        for (i in 1:15) {
          incProgress(1/15)
          Sys.sleep(0.25)
          
        }
        
     
          out <- render('report_code_unknown.Rmd', pdf_document(latex_engine = "xelatex"),
                                params = params,
                                envir = new.env(parent = globalenv())
                            )

          file.rename(out, file)
        
      })
      
    })
  
})