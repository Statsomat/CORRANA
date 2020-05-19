options(shiny.sanitize.errors = TRUE)

library(shiny)

source("chooser.R")

# Define UI for application 
shinyUI(fluidPage(
  
  tags$head(
    tags$style(HTML("
                   .shiny-notification{

                    position: fixed;
                    top: 10px;
                    left: calc(50% - 400px);;
                    width: 800px;
                    /* Make sure it draws above all Bootstrap components */
                    z-index: 2000;
                    background-color: #2fa42d;
                
                   }
                
                    
                    "))
    ),

  
  #Disable download button until check positive
  singleton(tags$head(HTML(
    '
  <script type="text/javascript">
  
    
    $(document).ready(function() {
      $("#downloadReport").attr("disabled", "true").attr("onclick", "return false;");
      Shiny.addCustomMessageHandler("check_download", function(message) {
        $("#downloadReport").removeAttr("disabled").removeAttr("onclick").html("");
      });
    })
    
    
    $(document).ready(function() {
      Shiny.addCustomMessageHandler("check_utf8", function(message) {
        $("#downloadReport").attr("disabled", "true");
      });
    })
    
     $(document).ready(function() {
      Shiny.addCustomMessageHandler("check_csv", function(message) {
        $("#downloadReport").attr("disabled", "true");
      });
    })
    
     $(document).ready(function() {
      Shiny.addCustomMessageHandler("check_fread", function(message) {
        $("#downloadReport").attr("disabled", "true");
      });
    })
    
    
  </script>
  '
  ))),
  
  br(),
  
  tags$div(a(img(src='Logo.jpg', width=150), href="https://www.statsomat.com", target="_blank")),
  
  h1("Correlation and Association", 
     style = "font-family: 'Source Sans Pro';
     color: #fff; text-align: center;
     background-color: #396e9f;
     padding: 20px;
     margin-bottom: 0px;"),
  h2("Full Version", 
     style = "font-family: 'Source Sans Pro';
     color: #fff; text-align: center;
     background-color: #2fa42d;
     padding: 5px;
     margin-top: 0px;"),
  
  br(),
  
  
  fluidRow( 
              
      
      column(6, 
             
             wellPanel(style = "background: #fff;", includeHTML("www/Description.html")),  
             wellPanel(style = "background: #fff;", includeHTML("www/Instructions.html")) 
             
      ),
                 
      column(6,  
             
             
             wellPanel(style = "background: #adc7de;", 
                          
                          h3("Upload"),
                          
                          # File input
                          fileInput("file", "Choose CSV file",
                                    accept = c(
                                      "text/csv",
                                      "text/comma-separated-values",
                                      ".csv"), 
                                    buttonLabel = "Browse...",
                                    placeholder = "No file selected"),
                          
                          
                       # Input: Select encoding ----
                       radioButtons("fencoding", "Encoding",
                                    choices = c(Auto = "unknown", 
                                                "UTF-8" = "UTF-8"),
                                    selected = "unknown", inline=TRUE),
                       
                       
                       # Input: Select decimal ----
                       radioButtons("decimal", "Decimal",
                                    choices = c(Auto = "auto",
                                                Comma = ",",
                                                Dot = "."),
                                    selected = "auto", inline=TRUE),
                       
                       tags$b("By clicking the Browse button and uploading a file, you agree to the Statsomat",
                              style="color: #808080;"),
                       
                       tags$a(href="https://statsomat.com/terms", target="_blank", "Terms of Use.", style="
                              font-weight: bold;")
            ),
          
            
            wellPanel(style = "background: #adc7de;", 
                      
                      h3("Select Variables"),
                      
                      uiOutput("selection1")
                      
                      
            )
            
      
      )
                  
  )
  
  ,
  
  
  fluidRow( 
    
    
    column(12, align="center", 
           
           wellPanel(style = "background: #ff9900", 
                     h3("Download the Report"),
                     h5("Click the button to download:"),
                     downloadButton('downloadReport','', 
                                    style="
                                    height:145px;
                                    width:84px;
                                    padding-top: 3px;
                                    color:#ff9900; 
                                    background-color: #ff9900; 
                                    border-color: #ff9900;
                                    background-image: url('Button.gif');")
                       
                    
                     
                     )
           
                     
           )
    
      ),
  
  
#  fluidRow( 
    
    
  #  column(12, align="center", 
           
   #        wellPanel(style = "background: #ff9900;", includeHTML("www/Buy2.html")), 
           
 #   )
    
#  ),
  
  
  
  
  fluidRow( 
    
    column(6, 
           
           wellPanel(style = "background: #fff;", includeHTML("www/Secure.html")), 
           wellPanel(style = "background: #fff;", includeHTML("www/Other.html"))
           
    ),
    
    column(6, 
           
           wellPanel(style = "background: #fff;", includeHTML("www/Also.html")),
           wellPanel(style = "background: #fff;", includeHTML("www/OpenSource.html"))
    
    ),

    column(12, 
       
       wellPanel(style = "background: #fff;", includeHTML("www/Contact.html"))
       
),

),
  
 includeHTML("www/Footer.html"),
 
 hr()
 
))
