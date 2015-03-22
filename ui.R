# ui

# This is code to create the GUI for our Shiny App to explore movie buzz
# Lets us pick which movies we want to plot
# and then the metric we want to see plotted

# We have to load the dataset here rather than in server.r
# This is because part of the UI below requires one of the objects
# (the list of movies). Becuase ui.r is loaded in parralel, 
# server.r hasn't had a time to load everything and generate this
# object which causes an error.
# Loading here, means it's always present before we generate UI

# GGVis loading
# Need to load here for same reason as data - without it,
# the call to the GGvis output object fails
library (ggvis)

# Load in the t10 dataset
t10 <- readRDS ("./data/t10.rds")

# create list of movies we can choose from
movieList <- sort (unique (as.character(t10$Title)))

# First, activate a fluid page that resizes with user
shinyUI (fluidPage(
  
  # Give a nice title
  titlePanel ("T-10: movie buzz analysis"),

  # Side bar section, where we select plotting options
  sidebarLayout (
    
    
    sidebarPanel (
      h4("T-10: movie buzz explorer"),
      
      br(),
      p ("Select the movies you'd like to compare:"),
      br(),
      
      # This select box allow us to pick which movie we want
      # allows multiple selections and starts empty
      selectInput ("movie",
                   "1. Pick movie(s):",
                   movieList,
                   selected=NULL, multiple=TRUE),
      br(),
      
      # Now we have radio buttons where we can pick the metric
      # that we'd like to plot
      radioButtons("metric",
                   "2. Pick the buzz metric to compare:",
                   choices=list ("Weekly buzz"= "Weekly.Buzz",
                                 "Weekly intent"="Weekly.Intent",
                                 "Cumulative buzz"="Cum.buzz",
                                 "Cumulative intent"="Cum.intent")),
      br(),
      br(),
      h5 ("Instructions:"),
      p("1. Select the movie(s). You can select multiple movies"),
      p("2. Select the metric. You can only plot one metric at at a time."),
      p("3. The app will generate a plot of the movie(s), and selected metric. 
        The plotting period is \"t-(n)\", where \"n\" is the number of weeks before
        launch of the movie."),
      p("This allow you to compare movies 10 weeks (hence T-10) before launch time-aligned,
         and therefore like-for-like"),
      p ("4: to resize the graph, click and drag handle on bottom right"),
      p ("5: to save a graph, click on cog on top right")
    ),
    
    # Main panel is empty apart from the plot
    mainPanel(
      ggvisOutput("plot"),
      
      br(),
      br(),
      
      h5 ("Metric definition:"),
      span(strong("Weekly buzz:"), "the reach of relevant Twitter conversations"), 
      br(),
      span (strong ("Weekly intent:"), "buzz where the poster expresses an intention to view the movie"),
      br(),
      span (strong("Cumulative buzz:"),"weekly buzz, but cumulative, rather than absolute per week"),
      br(),
      span(strong("Cumulative intent:"), "weekly intent, but cumulative, rather than absolute per week")
      
      
    )
  
  )
))