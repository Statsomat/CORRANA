fluidPage(
  
  disconnectMessage(
    text = "Error or your session timed out. ",
    refresh = "Reload now",
    background = "#ff9900",
    colour = "white",
    overlayColour = "grey",
    overlayOpacity = 0.3,
    refreshColour = "black"
  ),
  
  actionButton("reload", "Reload the app", onclick ="location.href='http://statsomat.shinyapps.io/correlations';", style="
                                    color: black; 
                                    background-color: #ff9900; 
                                    float: right"),
  
  tags$head(
    tags$style(HTML("
                   .shiny-notification{

                    position: fixed;
                    top: 10px;
                    left: calc(50% - 400px);;
                    width: 800px;
                    /* Make sure it draws above all Bootstrap components */
                    z-index: 2000;
                    background-color: #ff9900;
                
                   }
                
                    "))
    ),
  
  # Remove progress bar fileinput
  tags$style(".shiny-file-input-progress {display: none}"),
  
  
  # Disable download button until check positive
  singleton(tags$head(HTML(
    '
  <script type="text/javascript">
    
    
    $(document).ready(function() {
      $("#download").attr("disabled", "true").attr("onclick", "return false;");
      Shiny.addCustomMessageHandler("check_generation", function(message) {
        $("#download").removeAttr("disabled").removeAttr("onclick").html("");
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
             
             wellPanel(style = "background: #fff;", includeHTML("www/Instructions.html"))
             
      ),
                 
      column(6,  
             
             
             wellPanel(style = "background: #adc7de;", 
                          
                          h3("Upload"),
                          
                          # File input
                          fileInput("file", "Choose a CSV file",
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
      )),            
            
fluidRow(column(12, 
            
            wellPanel(style = "background: #ff9900", align="center", 
                      
                      h3("Generate the Report"),
                      
                      radioButtons('rcode', 'Include R Code', c('Yes','No'), inline = TRUE),
                      
                      h5("Click the button to generate the report"),
                      
                      actionButton("generate", "", style="
                                    height:145px;
                                    width:84px;
                                    padding-top: 3px;
                                    color:#ff9900; 
                                    background-color: #ff9900; 
                                    background-image: url('Button.gif');
                                    border: none;
                                    outline: none;
                                    box-shadow: none !important;")
                      
                      
            ))),

fluidRow(column(12, 
            
            wellPanel(style = "background: #ff9900", align="center", 
                      
                      h3("Download the Report"),
                      
                      h5("Click the button to download the report"),
                      
                      downloadButton("download", "", style="
                                    height:145px;
                                    width:84px;
                                    padding-top: 3px;
                                    color:#ff9900; 
                                    background-color: #ff9900; 
                                    border-color: #ff9900;
                                    background-image: url('Button.gif');") 
                      
                      
        ))), 

  fluidRow(
    
    column(6, 
           
           wellPanel(style = "background: #fff;", includeHTML("www/Secure.html")), 
           wellPanel(style = "background: #fff;", includeHTML("www/Other.html"))
           
    ),
    
    column(6, 
           
           wellPanel(style = "background: #fff;", includeHTML("www/Also.html")),
           wellPanel(style = "background: #fff;", includeHTML("www/OpenSource.html"))
           
    )
    
  ),
  
  fluidRow( 
    
    column(12, 
           
           wellPanel(style = "background: #fff;", includeHTML("www/Contact.html"))
           
    )),
  
 includeHTML("www/Footer.html"),
 
 hr()
 
)
