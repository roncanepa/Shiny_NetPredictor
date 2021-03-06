# Copyright (C) 2016 Abhik Seal <abhik1368@gmail.com>
# This program CC BY-NC-SA 3.0 license.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#################################################################################
## Load the libraries
library(shinyBS)
library(shinythemes) 
library(shiny)
library(shinysky)
library(shinyjs)
library(rCharts)
source("help.R")
library(visNetwork)
#library(shinyGridster)
#################################################################################

inputTextarea <- function(inputId, value="", nrows, ncols) {
    tagList(
        singleton(tags$head(tags$script(src = "textarea.js"))),
        tags$textarea(id = inputId,
                      class = "inputtextarea",
                      rows = nrows,
                      cols = ncols,
                      as.character(value))
    )
}

shinyUI(navbarPage(theme =shinytheme("spacelab"),img(src = "netpredicter.png", height = 32, width = 35) ,id ="bar",
                   tabPanel(icon("home",lib = "glyphicon"),
                            
                            div(style = " text-align: center;font-family: 'times'",
                                h2(" NetPredictor brings to you the power of finding missing links in Chem-Biological network .."),
                                br(),
                                br(),
                                img(src = "netpredicter.png", height = 150, width = 150,align = "success")
    
                                ),                   
                            br(),
                            br(),
                            br(),
                            div(style = "text-align: center;",                             
                                bsButton("gofind", label = "Start Prediction",  style = "default",
                                         size = "large", disabled = FALSE
                                )),
                            br(),br(),br(),br(),br(),br(),
                            div(style= "text-align: center;",                  
                                fluidRow(
                                    column(4,
                                           img(src = "upload.png", height = 90, width = 100,align = "center"),
                                           h3("1. Load your data into NetPredicter ")),
                                    column(4,
                                           img(src = "network.png", height = 90, width = 85,align = "center"),
                                           h3("2. Predict for missing links in a Network")),
                                    
                                    column(4,
                                           img(src = "discover.png", height = 90, width = 100,align = "center"),
                                           
                                           h3("3. Discover new relations in a network")
                                    )),
                                br(),
                                br()
                            )
                   ),
                   tabPanel("Start Prediction",icon=icon("dot-circle-o"),
                               
                            tags$head(
                                 tags$style(HTML("
                                  h1 {
                                    font-family: 'Verdana', cursive;
                                    line-height: 1.1;
                                    font-size : 20px;
                                    color: #4863A0
                                  }"))),
                            
                            headerPanel("Apply NetPredictor to your Data"),
                            
                            br(),br(),
#                             fluidRow(      
#                                 
#                                 column(4,wellPanel(
                            sidebarPanel(width=3,
                                # From http://stackoverflow.com/questions/19777515/r-shiny-mainpanel-display-style-and-font
                                HTML('<style type="text/css">
                                        .well { background-color: #ffffff; }
                                 </style>'),
                                       h4(icon("upload",lib = "glyphicon"),"load your data (or select Example)"),
                                       radioButtons(inputId="data_input_type", 
                                                    label="",
                                                    choices=c("Custom Data"="custom", "Example Data"="example"),
                                                    selected="", inline=FALSE),
                                       
                                      bsTooltip("data_input_type", "Choose Either example sets or input custom sets of data",
                                          "right", options = list(container = "body")),
                                
                                       ## Example data
                                       conditionalPanel(condition = "input.data_input_type == 'example'",
                                                    
                                                            selectInput("datasets", "Example datasets", choices = c("Enzyme","GPCR","Ion Channel","Nuclear Receptor"),selected = "",multiple = FALSE),
                                                        h4(icon("magic",lib = "font-awesome"),"Select Network Alogirthms"),
                                                        radioButtons(inputId="algorithm_typeI", 
                                                                     label="",
                                                                     choices=c("HeatS"="heat","Network Based Inference"="nbi","Random Walk with Restart"="rwr","NetCombo"="netcombo"),
                                                                     selected="", inline=FALSE),
                                                        conditionalPanel(condition = "input.algorithm_typeI=='heat'",
                                                                         sliderInput("heatAlpha", "Alpha", value=0.5, min=0, max=1,width ='200px'),
                                                                         sliderInput("heatLambda", "Lambda", value=0.5, min=0, max=1,width = '200px')),
                                                        conditionalPanel(condition = "input.algorithm_typeI=='nbi'",
                                                                         sliderInput("nbiAlpha", "Alpha", value=0.5, min=0, max=1,width ='200px'),
                                                                         sliderInput("nbiLambda", "Lambda", value=0.5, min=0, max=1,width = '200px')),
                                                        conditionalPanel(condition = "input.algorithm_typeI=='rwr'",
                                                                         sliderInput("rwr_restart", "Restart", value=0.8, min=0, max=1,width ='200px')),
                                                        conditionalPanel(condition = "input.algorithm_typeI=='netcombo'",
                                                                         sliderInput("nc_restart", "Restart", value=0.8, min=0, max=1,width ='200px'),
                                                                         sliderInput("ncAlpha", "Alpha", value=0.5, min=0, max=1,width ='200px'),
                                                                         sliderInput("ncLambda", "Lambda", value=0.5, min=0, max=1,width ='200px'))),
                                       # Local files
                                       conditionalPanel(condition = "input.data_input_type == 'custom'",
                                                                
                                                        fileInput('dt_file', label="Drug-Target Biparite Network", 
                                                                  multiple=FALSE,
                                                                  accept=c('text/csv',
                                                                           'text/comma-separated-values',
                                                                           'text/tab-separated-values',
                                                                           '.csv',
                                                                           'text/plain',
                                                                           '.tsv')),
                                                        bsTooltip("dt_file", "Input CSV file with Binary Drug Target Interactions Matrix",
                                                                  "right", options = list(container = "body")),
                                                        fileInput('drug_file', label="Drug Similarity Matrix", 
                                                                  multiple=FALSE,
                                                                  accept=c('text/csv',
                                                                           'text/comma-separated-values',
                                                                           'text/tab-separated-values',
                                                                           '.csv',
                                                                           'text/plain',
                                                                           '.tsv')),
                                                        bsTooltip("drug_file", "Input CSV file with Drug-Drug similarity Matrix",
                                                                  "right", options = list(container = "body")),
                                                        fileInput('target_file', label="Target Similarity Matrix", 
                                                                  multiple=FALSE,
                                                                  accept=c('text/csv',
                                                                           'text/comma-separated-values',
                                                                           'text/tab-separated-values',
                                                                           '.csv',
                                                                           'text/plain',
                                                                           '.tsv')),
                                                        bsTooltip("target_file", "Input CSV file with Target-Target similarityMatrix",
                                                                  "right", options = list(container = "body")),
                                                        h4("Select Network Alogirthms"),
                                                        radioButtons(inputId="algorithm_typeII", 
                                                                     label="",
                                                                     choices=c("HeatS"="heat","Network Based Inference"="nbi","Random Walk with Restart"="rwr","NetCombo"="netcombo"),
                                                                     selected="nbi", inline=FALSE),
                                                        conditionalPanel(condition = "input.algorithm_typeII=='heat'",
                                                                         sliderInput("cheatAlpha", "Alpha", value=0.5, min=0, max=1,width ='200px'),
                                                                         sliderInput("cheatLambda", "Lambda", value=0.5, min=0, max=1,width = '200px')),
                                                        conditionalPanel(condition = "input.algorithm_typeII=='nbi'",
                                                                         sliderInput("cnbiAlpha", "Alpha", value=0.5, min=0, max=1,width ='200px'),
                                                                         sliderInput("cnbiLambda", "Lambda", value=0.5, min=0, max=1,width = '200px')),
                                                        conditionalPanel(condition = "input.algorithm_typeII=='rwr'",
                                                                         sliderInput("crwr_restart", "Restart", value=0.8, min=0, max=1,width ='200px')),
                                                        conditionalPanel(condition = "input.algorithm_typeII=='netcombo'",
                                                                         sliderInput("cnc_restart", "Restart", value=0.8, min=0, max=1,width ='200px'),
                                                                         sliderInput("cncAlpha", "Alpha", value=0.5, min=0, max=1,width ='200px'),
                                                                         sliderInput("cncLambda", "Lambda", value=0.5, min=0, max=1,width ='200px'))
                                                                         
                                                        
                                       ),
                                      busyIndicator("Calculation In progress",wait = 0),
                                       actionButton('start', label='Run Prediction',
                                                     class="btn btn-primary")
                                      
                                     #render_helpfile("Data Input", "mds/import.md")
                                       ),mainPanel( 
                                           tabsetPanel(id='datatabs',
                                                       
                                                       tabPanel("Network Properties",br(),
                                                                actionButton('netproperty', label='Calculate Properties',class="btn btn-primary"),
                                                                h3(textOutput("Data Summary", container = span)),
                                                                uiOutput("prop_table"),
                                                                fluidRow(
                                                                    column(width = 5, chartOutput("countProteins","polycharts")),
                                                                    column(width = 6, offset = 1, chartOutput("countDrugs","polycharts"))
                                                                ),
                                                       fluidRow(
                                                          column(width = 5, chartOutput("btwProteins","polycharts")),
                                                          column(width = 6, offset = 1, chartOutput("btwDrugs","polycharts"))
                                                      )),
#                                                                 showOutput("btwProteins","polycharts"),
#                                                                 showOutput("btwDrugs","polycharts")),
                                                            
                                                       tabPanel("Network Modules",
                                                                
                                                                br(),
                                                                actionButton('mods', label='Calculate Modules',class="btn btn-primary"),
                                                                #render_helpfile("Network Modules", "mds/module.md"),
                                                                uiOutput('modules'),
                                                                dataTableOutput("data_table"),
                                                                actionButton('shownet', label='Show Network',class="btn btn-primary"),
                                                                visNetworkOutput("moduleplot",height="550px")),
                                                       tabPanel("Prediction Results",
            
                                                                h4(textOutput("Prediction Results",container = span)),
            
                                                                dataTableOutput("Result"),
                                                                downloadButton("downloadResult", "Download results as csv file")),
                                                       tabPanel("networkplot",
                                                       h4("Network"),
                                                       visNetworkOutput("networkplot",height="700px"),
                                                       downloadButton("graphResult","Download Graph GML file"))
                                       )
                                       
                                       )),

                  ## Statistical Analysis TAB

                   navbarMenu(id='predtab',title="Advanced Analysis",icon=icon("gears"),
                   tabPanel("Statistical Analysis",value = "aa",
                            tags$head(
                                tags$style(HTML("
                                                h1 {
                                                font-family: 'Verdana', cursive;
                                                line-height: 1.1;
                                                font-size : 20px;
                                                color: #4863A0
                                                }"))),
                            
                            headerPanel("Perform Advanced Analysis on your Network"),
                            br(),br(),
                            sidebarPanel(width = 3,
                                # From http://stackoverflow.com/questions/19777515/r-shiny-mainpanel-display-style-and-font
                                HTML('<style type="text/css">
                                     .well { background-color: #ffffff; }
                                     </style>'),
                                h4("Get Predictive Metrics"),
                                numericInput('relinks',width = '200px', 
                                             label = 'Choose Random links to be removed',
                                             min = 1, value = 25),
                                numericInput('freqT',width = '200px',
                                             label = 'Frequency of associations between Biparite Nodes',
                                             min = 1, value = 2),
                                radioButtons(inputId="predMetrics", 
                                             label="",
                                             choices=c("Network Based Inference"="nbi","Random walk with restart"="rwr", 
                                                       "NetCombo"='nc'),
                                             selected="", inline=FALSE),
                                conditionalPanel(condition = "input.predMetrics=='nbi'",
                                                 sliderInput("pdnbiAlpha", "Alpha", value=0.5, min=0, max=1,width ='200px'),
                                                 sliderInput("pdnbiLambda", "Lambda", value=0.5, min=0, max=1,width = '200px')),
                                conditionalPanel(condition = "input.predMetrics=='rwr'",
                                                 sliderInput("pdrwrRestart", "Restart", value=0.8, min=0, max=1,width ='200px')),
                                conditionalPanel(condition = "input.predMetrics=='nc'",
                                                 sliderInput("pdcnc_restart", "Restart", value=0.8, min=0, max=1,width ='200px'),
                                                 sliderInput("pdcncAlpha", "Alpha", value=0.5, min=0, max=1,width ='200px'),
                                                 sliderInput("pdcncLambda", "Lambda", value=0.5, min=0, max=1,width ='200px')),
                                busyIndicator("Calculation In progress",wait = 0),
                                actionButton('submit', label='Submit',
                                             class="btn btn-primary")
                               # render_helpfile("Advanced Analysis", "mds/analysis.md")
                            ),mainPanel(tabPanel('Statistical Analysis',
                                                     h3(textOutput("Analysis")),
                                                     dataTableOutput("advTable"),
                                                     downloadButton("downloadadvr", "Download results as csv file")))
                            

                            
                            ),
                   
                   ## Permutation analysis Navbar menu tab
                   tabPanel("Permutation testing",
                            tags$head(
                                tags$style(HTML("
                                                h1 {
                                                font-family: 'Verdana', cursive;
                                                line-height: 1.1;
                                                font-size : 20px;
                                                color: #4863A0
                                                }"))),
                   headerPanel("Perform Random Permutation test on your network"),br(),
                   sidebarPanel(width = 3,
                                # From http://stackoverflow.com/questions/19777515/r-shiny-mainpanel-display-style-and-font
                                HTML('<style type="text/css">
                                     .well { background-color: #ffffff; }
                                     </style>'),
                                h4("Perform Permutations Analysis on your Network"),
                                numericInput('permute',width = '200px', 
                                             label = 'Choose number of random permutations',
                                             min = 5, value = 10),
                                numericInput('sig',width = '150px',
                                             label = 'Keep Significant links of pvalue',
                                             min = 0.00000000001, value =0.05),
                                radioButtons(inputId="sigMetrics", 
                                             label="",
                                             choices=c("Network Based Inference"="signbi","Random walk with restart"="sigrwr"),
                                             selected="", inline=FALSE),
                                conditionalPanel(condition = "input.sigMetrics=='signbi'",
                                                 sliderInput("sgnbiAlpha", "Alpha", value=0.5, min=0, max=1,width ='200px'),
                                                 sliderInput("sgnbiLambda", "Lambda", value=0.5, min=0, max=1,width = '200px')),
                                conditionalPanel(condition = "input.sigMetrics=='sigrwr'",
                                                 sliderInput("sgrwrRestart", "Restart", value=0.8, min=0, max=1,width ='200px')),
                                busyIndicator("Calculation In progress",wait = 0),
                                actionButton('sigSubmit', label='Submit',
                                             class="btn btn-primary")
                                #render_helpfile("Significance Analysis", "mds/significance.md")
                   ),mainPanel(tabPanel('Permutation Analysis',
                                        h3(textOutput("Permutation Analysis")),
                                        dataTableOutput("sigTable"),
                                        downloadButton("downloadSig", "Download results as csv file")))
                   
                   
                   
                   )    
                   ),

                   tabPanel("Search Drugbank", icon= icon("search"),
                            tags$head(
                                tags$style(HTML("
                                                h1 {
                                                font-family: 'Verdana', cursive;
                                                line-height: 1.1;
                                                font-size : 16px;
                                                color: #4863A0
                                                }"))),
                            headerPanel("Select Drug names/drugbank IDs to search"),br(),
                            sidebarPanel(width = 3,
                                         HTML('<style type="text/css">
                                              .well { background-color: #ffffff; }
                                              </style>'),
                                         radioButtons(inputId="search_type", 
                                                      label="",
                                                      choices=c("Search Drugs"="drugs", "Search Proteins"="proteins"),
                                                      selected="", inline=FALSE),
                                         conditionalPanel(condition = "input.search_type == 'drugs'",
                                         textInput("did", "Drugbank ID:", width = NULL)),
                                         conditionalPanel(condition = "input.search_type == 'proteins'",
                                                          textInput("pid", "Hugo Gene:", width = NULL)),
                                         busyIndicator("Search In progress",wait = 0),
#                                          radioButtons(inputId="algo_dtype", 
#                                                       label="Algorithm Type",
#                                                       choices=c("NBI"="nbi", "RWR"="rwr"),
#                                                       selected="nbi", inline=FALSE),
                                         actionButton('dSearch', label='Submit',
                                                      class="btn btn-primary")
                                         
                            ),mainPanel(tabPanel('Predicted Links',
                
                                   dataTableOutput("dtable"),
                                   downloadButton("dBdownload", "Download results as csv file")
                                   ))),
              tabPanel("Ontology & Pathway search" , icon = icon("tasks"),
                       tags$head(
                           tags$style(HTML("
                                           h1 {
                                           font-family: 'Verdana', cursive;
                                           line-height: 1.1;
                                           font-size : 16px;
                                           color: #4863A0
                                           }"))),
                            headerPanel("Search Gene Ontology and Pathway information"),br(),
                            sidebarPanel(width = 3,
                                    HTML('<style type="text/css">
                                         .well { background-color: #ffffff; }
                                         </style>'),
                                    inputTextarea('selectGene', '',8,15 ),
                                    radioButtons(inputId="gopath", 
                                                 label="Select Ontology or Pathway",
                                                 choices=c("Gene Ontology"="go","Pathway Enrichment"="pathway"),
                                                 selected="", inline=FALSE),
                                    conditionalPanel(condition = "input.gopath=='go'",
                                                     textInput("level", label = "Enter GO Level", value = 3)),
                                    busyIndicator("Search In progress",wait = 0),
                                    actionButton('genelist', label='Submit',
                                                 class="btn btn-primary")
                                    
                            ),mainPanel(tabPanel('Ontology Pathway',
                                                 
                                                 dataTableOutput("genePathway"),
                                                 downloadButton("Godownload", "Download results as csv file")
                            ))), 
              tabPanel("About", icon= icon("info-circle"),
                      HTML(markdown::markdownToHTML("mds/about.md", fragment.only=TRUE, options=c("")))
             )
                      
)
)




